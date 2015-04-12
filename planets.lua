function initPlanets (numPlanets)
	planets = {}
	planetConnections = {}
	startingColonies = math.ceil(numPlanets / 2)
	for i=1, numPlanets do
		local sun = suns[randomIntegerBetween(1, tableSize(suns))]
		local planet = newPlanet(sun)
		if i == 1 then
			-- create player homeworld
			planet.isHomeWorld = true
			planet.startingColony = human.colony
			planet.maxSpores = 6
			human.selectedPlanet = planet
		elseif i <= startingColonies then
			-- create ai homeworlds
			planet.isHomeWorld = true
		end
		planet:initSpores()
		table.insert(planets, planet)
	end
end

function updatePlanets ()
	for _, planet in pairs(planets) do
		planet:update()
	end
end

function drawPlanets ()
	for _, planetConnection in pairs(planetConnections) do
		planetConnection:draw()
	end
	
	for _, planet in pairs(planets) do
		planet:draw()
	end
end

function newPlanet (sun)
	local p = {}
	
	p.startingColony = newColony()
	p.maxSpores = randomIntegerBetween(3, 12)
	p.spores = {}
	p.sporesOffPlanet = {}
	p.shouldCleanupSpores = false
	p.sporeWidthAngle = 0
	
	p.connections = {}
	p.shouldUpdateConnections = false
	
	p.sun = sun
	
	p.radius = p.maxSpores * UNIT_RADIUS / PI
	p.rotationAngle = randomRealBetween(0, TAU)
	p.rotationVelocity = randomRealBetween(-0.5, 0.5)
	p.orbitRadius = p.sun:newOrbit()
	p.orbitAngle = randomRealBetween(0, TAU)
	p.orbitVelocity = randomRealBetween(PI/100, PI/20)
	p.location = newVector(math.cos(p.orbitAngle) * p.orbitRadius, math.sin(p.orbitAngle) * p.orbitRadius)
	p.location = vAdd(p.location, p.sun.location)
	
	p.isHomeWorld = false
	
	function p:initSpores ()
		if self.isHomeWorld then
			for i=1, self.maxSpores do
				table.insert(self.spores, newSpore(self, self.startingColony, i))
			end
			self.radius = self.maxSpores * UNIT_RADIUS / PI
		end
	end
	
	function p:update ()
		self.rotationAngle = (self.rotationAngle + (self.rotationVelocity / TURN_TIME)) % TAU
		self.orbitAngle = self.orbitAngle + (self.orbitVelocity / TURN_TIME)
		self.location = newVector(math.cos(self.orbitAngle) * self.orbitRadius,
															math.sin(self.orbitAngle) * self.orbitRadius)
		self.location = vAdd(self.location, self.sun.location)
		
		local sporeWidthSum = 0
		for _, spore in pairs(self.spores) do
			spore:update()
			sporeWidthSum = sporeWidthSum + spore.width
		end
		self.sporeWidthAngle = TAU / sporeWidthSum

		for _, spore in pairs(self.sporesOffPlanet) do
			spore:update()
		end
		
		if self.shouldCleanupSpores then self:cleanupSpores() end
		if self.shouldUpdateConnections then self:updateConnections() end
	end
	
	function p:draw ()
		-- draw orbit
		love.graphics.setColor(255, 255, 255, 10)
		love.graphics.setLineWidth(1)
		love.graphics.circle('line', self.sun.location.x*ZOOM, self.sun.location.y*ZOOM, self.orbitRadius*ZOOM, SEGMENTS*2)
		
		-- draw shadow
		love.graphics.setColor(0, 0, 0, 20)
		drawFilledCircle(self.location.x, self.location.y, self.radius*1.1)
		
		-- draw homeworld indicator
		if self.isHomeWorld then
			self.startingColony:setToMyColor(150)
			love.graphics.setLineWidth(1)
			love.graphics.circle('line', self.location.x*ZOOM, self.location.y*ZOOM, (self.radius+UNIT_RADIUS*4)*ZOOM, SEGMENTS)
		end
		
		-- draw spores
		for _, spore in pairs(self.spores) do
			spore:draw()
		end
		for _, spore in pairs(self.sporesOffPlanet) do
			spore:draw()
		end
		
		-- draw planet
		if self.id == human.selectedPlanet.id then
			love.graphics.setColor(200, 200, 200)
		else
			love.graphics.setColor(100, 100, 100)
		end
		drawFilledCircle(self.location.x, self.location.y, self.radius)
		
		--love.graphics.print(tableSize(self.spores), (self.location.x+self.radius)*ZOOM, (self.location.y+self.radius)*ZOOM)
	end
	
	function p:getSporeLocation (mySpore)
		local sporeAngle = self.rotationAngle + mySpore.rotationAngle
		for _, spore in pairs(self.spores) do
			if spore.position < mySpore.position then
				sporeAngle = sporeAngle + (self.sporeWidthAngle * spore.width)
			end
		end
		local d = self.radius + UNIT_RADIUS
		local v = newVector(self.location.x+math.cos(sporeAngle)*d, self.location.y+math.sin(sporeAngle)*d)
		return v
	end
	
	function p:updateConnections ()
		self.connections = {}
		for _, c in pairs(planetConnections) do
			if c.a == self then
				table.insert(self.connections, c.b)
			elseif c.b == self then
				table.insert(self.connections, c.a)
			end
		end
		self.shouldUpdateConnections = false
	end
	
	function p:isRoomAvailable ()
		return tableSize(self.spores) < self.maxSpores
	end
	
	function p:connectionWithRoom ()
		local connectionsWithRoom = {}
		for _, planet in pairs(self.connections) do
			if planet:isRoomAvailable() then
				table.insert(connectionsWithRoom, planet)
			end
		end
		return randomElement(connectionsWithRoom)
	end
	
	function p:listEnemies (friendlyColony)
		local enemies = {}
		for _, spore in pairs(self.spores) do
			if spore.state == 'ready' and spore.colony ~= friendlyColony then
				table.insert(enemies, spore)
			end
		end
		return enemies
	end
	
	function p:findEnemyLocally (friendlyColony)
		local enemies = self:listEnemies(friendlyColony)
		if enemies == {} then
			return nil
		else
			return randomElement(enemies)
		end
	end
	
	function p:findEnemyAbroad (friendlyColony)
		local enemies = {}
		for _, planet in pairs(self.connections) do
			appendToTable(enemies, planet:listEnemies())
		end
		if enemies == {} then
			return nil
		else
			return randomElement(enemies)
		end
	end
	
	function p:countFriends (friendlyColony)
		local friendCount = 0
		for _, spore in pairs(self.spores) do
			if spore.state == 'ready' and spore.colony == friendlyColony then
				friendCount = friendCount + 1
			end
		end
		return friendCount
	end
	
	function p:findFriend (friendlyColony)
		local friends = {}
		for _, spore in pairs(self.spores) do
			if spore.state == 'ready' and spore.colony == friendlyColony then
				table.insert(friends, spore)
			end
		end
		return randomElement(friends)
	end
	
	function p:insertSpore (toPosition, newSpore)
		table.insert(self.spores, toPosition, newSpore)
		self:cleanupSpores()
	end
	
	function p:cleanupSpores ()
		local cleanSporeList = {}
		for _,spore in pairs(self.spores) do
			if spore.state == 'exploring' and spore.width == 0 then
				table.insert(self.sporesOffPlanet, spore)
			elseif spore.state ~= 'dead' and spore.planet == self then
				table.insert(cleanSporeList, spore)
			end
		end
		for i,spore in pairs(cleanSporeList) do
			spore.position = i
		end
		self.spores = cleanSporeList
		
		local cleanSporeOffPlanetList = {}
		for _,spore in pairs(self.sporesOffPlanet) do
			if spore.state ~= 'dead' and spore.planet == self then
				table.insert(cleanSporeOffPlanetList, spore)
			end
		end
		self.sporesOffPlanet = cleanSporeOffPlanetList
		
		self.shouldCleanupSpores = false
	end
	
	return p
end