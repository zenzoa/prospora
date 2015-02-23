function newSpore (planet, colony, position)
	local s = {}
	
	s.planet = planet
	s.colony = colony
	s.state = 'ready'
	s.position = position
	s.rotationAngle = 0
	s.width = 1
	
	s.velocity = newVector(0,0)
	
	function s:update ()
		
		if self.state ~= 'exploring' then
			self.location = self.planet:getSporeLocation(self)
		end
		
		if self.state == 'ready' then
			local isActing = randomRealBetween(0, TURN_TIME*60) < 1
			if isActing then
				local isTraveling = randomRealBetween(0, 1) < self.colony.travel
				local isConnecting = isTraveling and self.colony ~= human.colony and randomRealBetween(0, 2) < self.colony.travel
				local isAttacking = randomRealBetween(0, self.colony.attack + self.colony.spawn) < self.colony.attack
				if isConnecting then
					self:launchExplorer()
				elseif isTraveling then
					if isAttacking then
						--self:attackAbroad()
					else
						--self:spawnAbroad()
					end
				elseif isAttacking then
					self:attackLocally()
				else
					self:spawnLocally()
				end
			end
			
		elseif self.state == 'spawningLocally' then
			s:updateAnimationCounter()
			-- splitting animation, increase self.width
			self.width = 1-self.animationCounter
			if self.animationCounter <= 0 then
				self.child.state = 'ready'
				self.child.width = 1
				self.child.rotationAngle = 0
				self.width = 1
				self.rotationAngle = 0
				self.state = 'ready'
			end
			
		elseif self.state == 'spawningAbroad' then
			s:updateAnimationCounter()
			-- splitting animation, increase self.width;
			-- then show child flying across connection while self.width returns to normal and child.width increases
			if self.animationCounter <= 0 then
				self.child.state = 'ready'
				self.child = nil
				self.state = 'ready'
			end
			
		elseif self.state == 'attackingLocally' then
			s:updateAnimationCounter()
			-- move towards target, decrease self.width
			self.width = self.animationCounter
			if self.animationCounter <= 0 then
				self.position = self.target.position
				self.width = 1
				self.state = 'ready'
			end
			
		elseif self.state == 'attackingAbroad' then
			s:updateAnimationCounter()
			-- fly to new planet across connection, decreasing self.width meanwhile
			self.width = self.animationCounter
			if self.animationCounter <= 0 then
				self.planet = self.target.planet
				self.planet:insertSpore(self.target.position, self)
				self.width = 1
				self.state = 'ready'
			end
			
		elseif self.state == 'defendingLocally' then
			s:updateAnimationCounter()
			-- dying animation
			if self.animationCounter <= 0 then
				self.state = 'dead'
			end
			
		elseif self.state == 'defendingAbroad' then
			s:updateAnimationCounter()
			-- dying animation after delay for attacker to arrive
			if self.animationCounter <= 0 then
				self.state = 'dead'
			end
			
		elseif self.state == 'exploring' then
			s:updateAnimationCounter()
			self.location = vAdd(self.location, vDiv(self.velocity, TURN_TIME))
			self.width = self.animationCounter
			if self.animationCounter <= 0 then
				self.width = 0
				self.planet.shouldCleanupSpores = true
			end
			local planet = self:planetCollision()
			if planet and planet ~= self.planet and not areConnected(self.planet, planet) then
				table.insert(planetConnections, newConnection(self.planet, planet))
				self.state = 'dead'
			end
		elseif self.state == 'dead' then
			self.planet.shouldCleanupSpores = true
		end
	end
	
	function s:draw ()
		self.colony:setToMyColor()
		if self.state ~= 'placeholder' then
			drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS)
		end
		
		if self.state == 'ready' then
		elseif self.state == 'spawningLocally' then
			love.graphics.print('spawn', self.location.x*ZOOM, self.location.y*ZOOM)
			
		elseif self.state == 'spawningAbroad' then
			love.graphics.print('spawnA', self.location.x*ZOOM, self.location.y*ZOOM)
			
		elseif self.state == 'attackingLocally' then
			love.graphics.print('attack', self.location.x*ZOOM, self.location.y*ZOOM)
			
		elseif self.state == 'attackingAbroad' then
			love.graphics.print('attackA', self.location.x*ZOOM, self.location.y*ZOOM)
			
		elseif self.state == 'defendingLocally' then
			love.graphics.print('die', self.location.x*ZOOM, self.location.y*ZOOM)
			
		elseif self.state == 'defendingAbroad' then
			love.graphics.print('die', self.location.x*ZOOM, self.location.y*ZOOM)
			
		elseif self.state == 'exploring' then
			love.graphics.print('wheeee!', self.location.x*ZOOM, self.location.y*ZOOM)
		end
	end
	
	function s:updateAnimationCounter ()
		self.animationCounter = self.animationCounter - TURN_TIME/10000
	end
	
	function s:launchExplorer ()
		if self.colony == human.colony then
			self:setVelocityTo(adjustMousePos(love.mouse.getX(), love.mouse.getY()))
		else
			self:setCourseTo(self:pickRandomPlanet())
		end
		self.location = self.planet.location
		self.state = 'exploring'
		self.animationCounter = 1
	end
	
	function s:attackLocally ()
		self.target = self.planet:findEnemyLocally(self.colony)
		if self.target then
			self.state = 'attackingLocally'
			self.animationCounter = 1
			self.target.state = 'defendingLocally'
			self.target.animationCounter = 1
		end
	end
	
	function s:attackAbroad ()
		self.target = self.planet:findEnemyAbroad(self.colony)
		if self.target then
			self.state = 'attackingAbroad'
			self.animationCounter = 2
			self.target.state = 'defendingAbroad'
			self.target.animationCounter = 2
		end
	end
	
	function s:spawnLocally ()
		if self.planet:isRoomAvailable() then
			self.state = 'spawningLocally'
			self.animationCounter = 1
			self.child = newSpore(self.planet, self.colony, 0)
			self.child.state = 'placeholder'
			self.child.width = 0
			self.planet:insertSpore(self.position+1, self.child)
		end
	end
	
	function s:spawnAbroad ()
		targetPlanet = self.planet:connectionWithRoom()
		if targetPlanet then
			self.state = 'spawningAbroad'
			self.animationCounter = 2
			self.child = newSpore(targetPlanet, self.colony)
			self.child.state = 'placeholder'
			self.child.width = 0
			targetPlanet:insertSpore(self.position+1, self.child)
		end
	end
	
	function s:pickRandomPlanet ()
		local weightedPlanets = {}
		local d = 0
		for _, planet in pairs(planets) do
			if self.planet ~= planet and not areConnected(self.planet, planet) then
				d = vMag(vSub(planet.location, self.planet.location))
				local worldMag = vMag(newVector(WORLD_SIZE.width, WORLD_SIZE.height))
				d = (( (worldMag/2 - d) / worldMag )^3)*worldMag
				d = math.max(math.ceil(d), 1)
				for i=1, d do
					table.insert(weightedPlanets, planet)
				end
			end
		end
		return randomElement(weightedPlanets)
	end
	
	function s:planetCollision ()
		for _, planet in pairs(planets) do
			local distance = vSub(planet.location, self.location)
			if math.abs(vMag(distance)) < planet.radius then
				return planet
			end
		end
		return nil
	end
	
	function s:setCourseTo (planet)
		self:setVelocityTo(planet.location)
		local distanceToPlanet = vMag(vSub(planet.location, self.planet.location))
		local timeToTravel = distanceToPlanet / vMag(self.velocity)
		local predictedLocation = planet.location
		local rotationAngle = planet.rotationAngle
		local orbitAngle = planet.orbitAngle
		for i=0, timeToTravel do
			rotationAngle = (rotationAngle + planet.rotationVelocity) % TAU
			orbitAngle = orbitAngle + planet.orbitVelocity
			predictedLocation = newVector(math.cos(planet.orbitAngle)*planet.orbitRadius, math.sin(planet.orbitAngle)*planet.orbitRadius)
			predictedLocation = vAdd(predictedLocation, planet.sun.location)
		end
		self:setVelocityTo(predictedLocation)
	end
	
	function s:setVelocityTo (location)
		self.velocity = vSub(location, self.planet.location)
		self.velocity = vNormalize(self.velocity)
		self.velocity = vMul(self.velocity, 200)
	end
	
	return s
end

--[[

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

function newUnit (planet, meme)
	
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
	
	return u
	
end
]]--