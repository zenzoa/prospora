planets = {}
planetConnections = {}

OCCUPATION_RATE = 0.5

function initPlanets (numPlanets)
	planets = {}
	planetConnections = {}
	startingMemes = math.ceil(numPlanets * OCCUPATION_RATE)
	for i=1, numPlanets do
		local randomSun = suns[randomIntegerBetween(1, tableSize(suns))]
		if i == 1 then
			planets[i] = newPlanet(i, randomSun, 6, true, human.meme)
			human.selectedPlanet = planets[i]
			human.homeWorld = planets[i]
		elseif i <= startingMemes then
			planets[i] = newPlanet(i, randomSun, randomIntegerBetween(3, 12), true, newMeme())
		else
			planets[i] = newPlanet(i, randomSun, randomIntegerBetween(3, 12), false, newMeme())
		end
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

function newPlanet (id, sun, unitSpaces, isHomeWorld, meme)
	local p = {}
	
	p.id = id
	p.sun = sun
	p.unitSpaces = unitSpaces
	
	p.isHomeWorld = isHomeWorld
	p.homeWorldMeme = meme
	
	p.oRadius = p.sun:newOrbit()
	p.oAngle = randomRealBetween(0, TAU)
	p.oVelocity = randomRealBetween(PI/100, PI/20)
	
	p.location = newVector(math.cos(p.oAngle) * p.oRadius,
												 math.sin(p.oAngle) * p.oRadius)
	p.location = vAdd(p.location, p.sun.location)
	p.radius = (p.unitSpaces * UNIT_RADIUS) / PI
	
	p.rAngle = randomRealBetween(0, TAU)
	p.rVelocity = randomRealBetween(-0.5, 0.5)
	
	p.units = {}
	p.flyers = {}
	initUnits(p, meme)
	
	function p:update ()
		self.rAngle = (self.rAngle + (self.rVelocity / TURN_TIME)) % TAU
		self.oAngle = self.oAngle + (self.oVelocity / TURN_TIME)
		
		self.location = newVector(math.cos(self.oAngle) * self.oRadius,
															math.sin(self.oAngle) * self.oRadius)
		self.location = vAdd(self.location, self.sun.location)
		
		updateUnits(self)
		updateFlyers(self)
	end
	
	function p:draw ()
		-- draw orbit
		love.graphics.setColor(255, 255, 255, 10)
		love.graphics.setLineWidth(1)
		love.graphics.circle('line', self.sun.location.x*ZOOM, self.sun.location.y*ZOOM, self.oRadius*ZOOM, SEGMENTS*2)
		
		-- draw homeworld indicator
		if self.isHomeWorld then
			self.homeWorldMeme:setToMyColor(150)
			love.graphics.setLineWidth(1)
			love.graphics.circle('line', self.location.x*ZOOM, self.location.y*ZOOM, (self.radius+UNIT_RADIUS*4)*ZOOM, SEGMENTS)
		end
		
		-- draw planet
		if self.id == human.selectedPlanet.id then
			love.graphics.setColor(200, 200, 200)
		else
			love.graphics.setColor(100, 100, 100)
		end
		drawFilledCircle(self.location.x, self.location.y, self.radius)
		
		-- draw memes
		drawUnits(self)
		drawFlyers(self)
	end
	
	function p:checkHomeWorld ()
		-- check to see if homeworld has been emptied of its original meme
		if self.isHomeWorld then
			local localMemes = 0
			for i=1, self.unitSpaces do
				if self.units[i] and self.units[i].meme == self.homeWorldMeme then
					localMemes = localMemes + 1
				end
			end
			-- if meme has been eradicated from its homeworld, kill all units of that meme everywhere
			if localMemes == 0 then
				self.isHomeWorld = false
				for _, planet in pairs(planets) do
					for i=1, planet.unitSpaces do
						if planet.units[i] and planet.units[i].meme == self.homeWorldMeme then
							planet.units[i].dying = true
							planet.units[i].animationCounter = 0
						end
					end
				end
			end
		end
	end
	
	function p:getConnections ()
		local connectedPlanets = {}
		for _, c in pairs(planetConnections) do
			if c.a.id == self.id then
				table.insert(connectedPlanets, c.b)
			elseif c.b.id == self.id then
				table.insert(connectedPlanets, c.a)
			end
		end
		return connectedPlanets
	end
	
	function p:removeConnections ()
		for _, c in pairs(planetConnections) do
			if c.a.id ~= self.id and c.b.id ~= self.id then
				c = nil
			end
		end
	end
	
	function p:getEmptyConnections (meme)
		local connectedPlanets = {}
		for _, c in pairs(planetConnections) do
			if c.a.id == self.id and tableSize(c.b:getEmptySpaces()) > 0 then --and (not c.b.isHomeWorld or c.b.homeWorldMeme == meme) then
				table.insert(connectedPlanets, c.b)
			elseif c.b.id == self.id and tableSize(c.a:getEmptySpaces()) > 0 then -- and (not c.a.isHomeWorld or c.a.homeWorldMeme == meme) then
				table.insert(connectedPlanets, c.a)
			end
		end
		return connectedPlanets
	end
	
	function p:getEnemyConnections (meme)
		local connectedPlanets = {}
		for _, c in pairs(planetConnections) do
			if c.a.id == self.id and tableSize(c.b:getEnemies(meme)) > 0 then
				table.insert(connectedPlanets, c.b)
			elseif c.b.id == self.id and tableSize(c.a:getEnemies(meme)) > 0 then
				table.insert(connectedPlanets, c.a)
			end
		end
		return connectedPlanets
	end
	
	function p:getFriends (meme)
		local friends = {}
		for i=1, self.unitSpaces do
			if self.units[i] and not self.units[i]:isBusy() and meme == self.units[i].meme then
				table.insert(friends, self.units[i])
			end
		end
		return friends	
	end
	
	function p:getEnemies (meme)
		local enemies = {}
		for i=1, self.unitSpaces do
			if self.units[i] and not self.units[i]:isBusy() and self.units[i].meme ~= meme then
				table.insert(enemies, self.units[i])
			end
		end
		return enemies		
	end
	
	function p:getEmptySpaces ()
		local emptySpaces = {}
		for i=1, self.unitSpaces do
			if self.units[i] == nil then
				table.insert(emptySpaces, i)
			end
		end
		return emptySpaces
	end
	
	function p:addFlyer (newFlyer)
		table.insert(self.flyers, newFlyer)
	end
	
	return p
end

--

function newPlanetConnection (planetA, planetB)
	local c = {}
	
	c.a = planetA
	c.b = planetB
	
	function c:draw ()
		if self.a.id == human.selectedPlanet.id or self.b.id == human.selectedPlanet.id then
			love.graphics.setColor(200, 200, 200)
			love.graphics.setLineWidth(1.5)
		else
			love.graphics.setColor(100, 100, 100)
		end
		love.graphics.setLineWidth(1)
		love.graphics.line(self.a.location.x*ZOOM, self.a.location.y*ZOOM, self.b.location.x*ZOOM, self.b.location.y*ZOOM)
	end
	
	return c
end

function areConnected (planetA, planetB)
	for _, c in pairs(planetConnections) do
		if (c.a.id == planetA.id and c.b.id == planetB.id)
			or (c.a.id == planetB.id and c.b.id == planetA.id) then
				return true
		end
	end
	return false
end
