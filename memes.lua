function newMeme ()
	local m = {}
	
	m.agg = randomRealBetween(0, 1)
	m.con = randomRealBetween(0, 1)
	m.fec = randomRealBetween(0, 1)
	
	local hue = randomRealBetween(0,240)
	if hue>180 then hue=hue+120 end
	hue = hue*255/360
	local sat = randomRealBetween(100,255)
	local lit = randomRealBetween(100,200)
	
	m.color = {}
	m.color.r, m.color.g, m.color.b = HSL(hue, sat, lit)
	
	--[[m.color = {
		r = randomIntegerBetween(55, 255),
		g = randomIntegerBetween(55, 255),
		b = randomIntegerBetween(55, 255)
	}]]--
	
	function m:adjustGenes ()
		local t = m.agg + m.con + m.fec
		m.agg = m.agg / t
		m.con = m.con / t
		m.fec = m.fec / t
	end
	m:adjustGenes()
	
	function m:setToMyColor (alpha)
		alpha = alpha or 255
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, alpha)
	end
	
	return m
end

function initUnits (planet, meme)
	if planet.isHomeWorld then
		meme = planet.homeWorldMeme
		for i=1, planet.unitSpaces do
			table.insert(planet.units, newUnit(planet, meme))
		end
	end
end

function updateUnits (planet)
	for i=1, planet.unitSpaces do
		if planet.units[i] then
			local theta = planet.rAngle + ((TAU / planet.unitSpaces) * i)
			planet.units[i]:update(planet, theta)
			if planet.units[i]:isDead() then
				planet.units[i] = nil
				planet:checkHomeWorld()
				checkForEndGame()
			end
		end
	end
end

function drawUnits (planet)
	for _, unit in pairs(planet.units) do
		unit:draw()
	end
end

function newUnit (planet, meme)
	local u = {}
	
	u.meme = meme
	u.planet = planet
	
	u.growing = false
	u.dying = false
	u.waiting = false
	u.flying = false
	u.flyer = {}
	u.animationCounter = 0
	
	u.location = newVector(0, 0)
	
	function u:update (planet, theta)
		self.location = self:updateLocation(theta)
		
		if self.growing then
			self.animationCounter = math.min(1, self.animationCounter + (0.4 / TURN_TIME))
			if self.animationCounter == 1 then
				self.growing = false
			end
			
		elseif self.dying then
			self.animationCounter = math.min(1, self.animationCounter + (0.4 / TURN_TIME))
			
		elseif self.flying and self.flyer ~= nil then
			self.flyer:update()
			if vMag(self.flyer.velocity) == 0 then
				if self.flyer.attackDrone then
					self.dying = true
					self.animationCounter = 0
				else
					self.growing = true
				end
				self.flying = false
				self.flyer = nil
			end
			
		elseif not self.waiting then
			-- choose if acting this frame
			if (randomRealBetween(0, TURN_TIME * FPS) < 1) then
				-- choose if being contagious
				local isTraveling = randomRealBetween(0, 1) < self.meme.con
				local isConnecting = isTraveling and randomRealBetween(0, 2) < self.meme.con
				-- choose between aggression and fecundity
				local isAttacking = randomRealBetween(0, self.meme.agg + self.meme.fec) < self.meme.agg
				local isBreeding = not isAttacking
				
				if isConnecting
					and tableSize(planet:getFriends(self.meme)) > 1
					and self.meme ~= human.meme then
						self:launchFlyer()
				elseif isBreeding and isTraveling then
					self:breedThere()
				elseif isBreeding then
					self:breedHere()
				elseif isAttacking and isTraveling then
					self:attackThere()
				elseif isAttacking then
					self:attackHere()
				end
			end
			
		end
	end
	
	function u:draw ()
		self.meme:setToMyColor()
		if self.growing then
			drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS * self.animationCounter)
		elseif self.dying then
			love.graphics.setColor(255, 255, 255, 255 * (1 - self.animationCounter))
			drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS * self.animationCounter * 4)
			self.meme:setToMyColor()
			drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS * (1 - self.animationCounter))
			
			-- alert player to attacks on their home planet
			if self.planet == human.homeWorld and self.meme == human.meme then
				love.graphics.setColor(200, 50, 50, 255 * (1 - self.animationCounter))
				love.graphics.setLineWidth(50)
				love.graphics.rectangle('line', -OFFSET.x, -OFFSET.y, love.graphics.getWidth(), love.graphics.getHeight())
				love.graphics.setColor(200, 50, 50)
				love.graphics.print('HOMEWORLD UNDER ATTACK', -OFFSET.x + love.graphics.getWidth()/2 - 140, -OFFSET.y + love.graphics.getHeight() - 100)
			end
			
		elseif self.flying and self.flyer ~= nil then
			if self.flyer.attackDrone then
				drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS)
			end
			self.flyer:draw()
		elseif not self.waiting then
			drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS)
		end
	end
	
	function u:launchFlyer ()
		local weightedPlanetIDs = {}
		local d = 0
		for _, planet in pairs(planets) do
			if self.planet.id ~= planet.id and not areConnected(self.planet, planet) then
				d = vMag(vSub(planet.location, self.planet.location))
				local worldMag = vMag(newVector(WORLD_SIZE.width, WORLD_SIZE.height))
				d = (( (worldMag/2 - d) / worldMag )^3)*worldMag
				d = math.max(math.ceil(d), 1)
				for i=1, d do
					table.insert(weightedPlanetIDs, planet.id)
				end
			end
		end
		
		local destination = planets[randomElement(weightedPlanetIDs)]
		self.flying = true
		local f = newFlyer(self.planet.location, false, self.planet, destination, self.meme.color)
		if self.meme == human.meme then
			f:setVelocityTo(adjustMousePos(love.mouse.getX(), love.mouse.getY()))
			f.humanLaunched = true
		end
		self.planet:addFlyer(f)
		
		self.dying = true
		self.animationCounter = 1
	end
	
	function u:breedHere ()
		local emptySpaces = self.planet:getEmptySpaces()
		if tableSize(emptySpaces) > 0 then
			local emptySpace = randomElement(emptySpaces)
			local u = newUnit(self.planet, self.meme)
			u.growing = true
			self.planet.units[emptySpace] = u
		end
	end
	
	function u:attackHere ()
		local enemies = self.planet:getEnemies(self.meme)
		if tableSize(enemies) > 0 then
			local target = randomElement(enemies)
			target.dying = true
			target.animationCounter = 0
		end
	end
	
	function u:breedThere ()
		local connectedPlanets = self.planet:getEmptyConnections(self.meme)
		if tableSize(connectedPlanets) > 0 then
			local destination = randomElement(connectedPlanets)
			local emptySpace = randomElement(destination:getEmptySpaces())
			local u = newUnit(destination, self.meme)
			u.flying = true
			u.flyer = newFlyer(self.location, true, self.planet, destination, {r=100, g=100, b=100})
			destination.units[emptySpace] = u
		else
			self:breedHere()
		end
	end
	
	function u:attackThere ()
		local connectedPlanets = self.planet:getEnemyConnections(self.meme)
		if tableSize(connectedPlanets) > 0 then
			local destination = randomElement(connectedPlanets)
			local enemy = randomElement(destination:getEnemies(self.meme))
			enemy.flying = true
			enemy.flyer = newFlyer(self.location, true, self.planet, destination, {r=100, g=100, b=100})
			enemy.flyer.attackDrone = true
		else
			self:attackHere()
		end
	end
	
	function u:isDead ()
		return self.dying and self.animationCounter == 1
	end
	
	function u:isBusy ()
		return self.flying or self.growing or self.dying or self.waiting
	end
	
	function u:updateLocation (theta)
		local d = self.planet.radius + UNIT_RADIUS
		local v = newVector(self.planet.location.x + math.cos(theta) * d,
												self.planet.location.y + math.sin(theta) * d)
		return v
	end
	
	return u
	
end
