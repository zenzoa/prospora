--function saveSpores ()

function newSpore (planet, colony, position)
	local s = {}
	
	s.planet = planet
	s.colony = colony
	s.state = 'ready'
	s.position = position
	s.location = planet.location
	s.rotationAngle = 0
	s.width = 1
	
	s.velocity = newVector(0,0)
	
	function s:update ()
		
		if self.state ~= 'exploring' and self.state ~= 'placeholder' then
			self.location = self.planet:getSporeLocation(self)
		end
		
		if self.state == 'ready' then
			local isActing = randomRealBetween(0, game.turn_time*60) < 1
			if isActing then
				local isTraveling = randomRealBetween(0, 1) < self.colony.travel
				local isConnecting = isTraveling and self.colony ~= game.human.colony and self.planet:countFriends(self.colony) > 1 and randomRealBetween(0, 2) < self.colony.travel
				local isAttacking = randomRealBetween(0, self.colony.attack + self.colony.spawn) < self.colony.attack
				if isConnecting and (not game.tutorial or game.flags.allowEnemyConnections) then
					self:launchExplorer()
				elseif isTraveling then
					if isAttacking then
						self:attackAbroad()
					else
						self:spawnAbroad()
					end
				elseif isAttacking then
					self:attackLocally()
				else
					self:spawnLocally()
				end
			end
			
		elseif self.state == 'spawningLocally' then
			self:spawnLocallyUpdate()
			
		elseif self.state == 'spawningAbroad' then
			self:spawnAbroadUpdate()
			
		elseif self.state == 'attackingLocally' then
			self:attackLocallyUpdate()
			
		elseif self.state == 'attackingAbroad' then
			self:attackAbroadUpdate()
			
		elseif self.state == 'defendingLocally' then
			self:defendLocallyUpdate()
			
		elseif self.state == 'defendingAbroad' then
			self:defendAbroadUpdate()
			
		elseif self.state == 'exploring' then
			self:updateAnimationCounter()
			self.location = vAdd(self.location, vDiv(self.velocity, game.turn_time))
			self.width = self.animationCounter
			if self.animationCounter <= 0 then
				self.width = 0
				self.planet.shouldCleanupSpores = true
			end
			local planet = self:planetCollision()
			if planet and planet ~= self.planet and not areConnected(self.planet, planet) then
				table.insert(planetConnections, newConnection(self.planet, planet))
				self.state = 'dead'
				if self.colony == game.human.colony then
					game.flags.makeConnection = true
					if game.soundOn then
						hitPlanetSound:setPitch(1*randomRealBetween(.9, 1.1))
						hitPlanetSound:play()
					end
				end
			end
		end
		
		if self.state == 'dead' then
			self.planet.shouldCleanupSpores = true
		end
	end
	
	function s:draw ()
		self.colony:setToMyColor()
		local radius = UNIT_RADIUS
		local drawRegularUnit = true
		--love.graphics.setFont(fontMessageSmallest)
		
		if self.colony == game.human.colony then
			--love.graphics.print('  +', self.location.x, self.location.y)
		end
		
		if self.state == 'ready' then
			--
			
		elseif self.state == 'spawningLocally' then
			self:spawnLocallyDraw()
			--love.graphics.print('s', self.location.x, self.location.y)
			
		elseif self.state == 'spawningAbroad' then
			self:spawnAbroadDraw()
			--love.graphics.print('sa', self.location.x, self.location.y)
			
		elseif self.state == 'attackingLocally' then
			self:attackLocallyDraw()
			--love.graphics.print('a', self.location.x, self.location.y)
			
		elseif self.state == 'attackingAbroad' then
			self:attackAbroadDraw()
			drawRegularUnit = false
			--love.graphics.print('aa', self.location.x, self.location.y)
			
		elseif self.state == 'defendingLocally' then
			self:defendLocallyDraw()
			drawRegularUnit = false
			--love.graphics.print('d', self.location.x, self.location.y)
			
		elseif self.state == 'defendingAbroad' then
			drawRegularUnit = self:defendAbroadDraw()
			--love.graphics.print('da', self.location.x, self.location.y)
			
		elseif self.state == 'exploring' then
			radius = radius/2
			--love.graphics.print('e', self.location.x, self.location.y)
			
		elseif self.state == 'placeholder' then
			drawRegularUnit = false
			--love.graphics.print('x', self.location.x, self.location.y)
		end
		
		if drawRegularUnit then
			drawFilledCircle(self.location.x, self.location.y, radius)
		end
	end
	
	function s:updateAnimationCounter ()
		self.animationCounter = self.animationCounter - (1/game.turn_time)
	end
	
	function s:launchExplorer (destination)
		if self.colony == game.human.colony then
			if destination then
				self:setVelocityTo(destination)
			end
		else
			self:setCourseTo(self:pickRandomPlanet())
		end
		self.location = self.planet.location
		self.state = 'exploring'
		self.animationCounter = 1
	end
	
	--
	
	function s:spawnLocally ()
		if self.planet:isRoomAvailable() then
			self.state = 'spawningLocally'
			self.animationCounter = 1
			self.child = newSpore(self.planet, self.colony)
			self.child.state = 'placeholder'
			self.child.width = 0
			self.planet:insertSpore(self.position, self.child)
			self.child.location = self.planet:getSporeLocation(self.child)
			if game.soundOn and self.planet:onScreen(true) then
				spawnSound:setPitch(1*randomRealBetween(.9, 1.1))
				spawnSound:play()
			end
		end
	end
	function s:spawnLocallyUpdate ()
		self:updateAnimationCounter()
		self.child.width = 1 - self.animationCounter
		self.child.location = self.planet:getSporeLocation(self.child)
		if self.animationCounter <= 0 then
			self:birth()
		end
	end
	function s:spawnLocallyDraw ()
		drawFilledCircle(self.child.location.x, self.child.location.y, UNIT_RADIUS)
	end
	
	--
	
	function s:spawnAbroad ()
		local targetPlanet = self.planet:connectionWithRoom()
		if targetPlanet then
			self.state = 'spawningAbroad'
			self.animationCounter = 2
			self.child = newSpore(targetPlanet, self.colony)
			self.child.state = 'placeholder'
			self.child.width = 0
			targetPlanet:insertSpore(1, self.child)
			self.child.location = self.planet:getSporeLocation(self)
			if game.soundOn and (self.planet:onScreen(true) or targetPlanet:onScreen(true)) then
				spawnSound:setPitch(1*randomRealBetween(.9, 1.1))
				spawnSound:play()
			end
		end
	end
	function s:spawnAbroadUpdate ()
		self:updateAnimationCounter()
		if self.animationCounter > 1.5 then
			--
		elseif self.animationCounter > 0 then
			self.child.width = (1.5 - self.animationCounter)/1.5
			local d = vSub(self.child.planet.location, self.planet.location)
			local totalDistance = vMag(d)
			d = vNormalize(d)
			self.child.location = vMul(d, totalDistance * (1.5 - self.animationCounter)/1.5)
			self.child.location = vAdd(self.child.location, self.planet.location)
		else
			self:birth()
		end
	end
	function s:spawnAbroadDraw ()
		if self.animationCounter > 1.5 then
			drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS*(3-self.animationCounter))
		elseif self.animationCounter > 0 then
			drawFilledCircle(self.child.location.x, self.child.location.y, UNIT_RADIUS/2)
		end
	end
	
	--
	
	function s:attackLocally ()
		self.target = self.planet:findEnemyLocally(self.colony)
		if self.target then
			self.state = 'attackingLocally'
			self.animationCounter = 1
			self.target.state = 'defendingLocally'
			self.target.animationCounter = 1
			if game.soundOn and self.planet:onScreen(true) then
				attackedSound:setPitch(1*randomRealBetween(.9, 1.1))
				attackedSound:play()
			end
		end
	end
	function s:attackLocallyUpdate ()
		self:updateAnimationCounter()
		self.rotationAngle = TAU*self.animationCounter
		if self.animationCounter <= 0 then
			self.width = 1
			self.state = 'ready'
			self.rotationAngle = 0
		end
	end
	function s:attackLocallyDraw ()
		--
	end
	
	--
	
	function s:attackAbroad ()
		local targetSpore = self.planet:findEnemyAbroad(self.colony)
		if targetSpore and self.planet:countFriends(self.colony) > 1 then
			self.state = 'attackingAbroad'
			self.animationCounter = 2
			targetSpore.state = 'defendingAbroad'
			targetSpore.animationCounter = 1.5
			self.child = newSpore(targetSpore.planet, self.colony)
			self.child.state = 'placeholder'
			self.child.width = 0
			targetSpore.planet:insertSpore(targetSpore.position, self.child)
			if game.soundOn and (self.planet:onScreen(true) or self.child.planet:onScreen(true)) then
				attackedSound:setPitch(1*randomRealBetween(.9, 1.1))
				attackedSound:play()
			end
		end
	end
	function s:attackAbroadUpdate ()
		self:updateAnimationCounter()
		if self.animationCounter > 1 then
			self.width = self.animationCounter-1
		end
		if self.animationCounter > 0.5 then
			local d = vSub(self.child.planet.location, self.planet.location)
			local totalDistance = vMag(d)
			d = vNormalize(d)
			self.child.location = vMul(d, totalDistance * (2 - self.animationCounter)/1.5)
			self.child.location = vAdd(self.child.location, self.planet.location)
		elseif self.animationCounter <= 0.5 and self.animationCounter > 0 then
			self.child.state = 'ready'
			self.child.width = 1
		elseif self.animationCounter <= 0 then
			self.state = 'dead'
		end
	end
	function s:attackAbroadDraw ()
		if self.animationCounter > 0.5 then
			drawFilledCircle(self.child.location.x, self.child.location.y, UNIT_RADIUS/2)
		end
	end
	
	--
	
	function s:defendLocallyUpdate ()
		self:updateAnimationCounter()
		self.width = self.animationCounter
		if self.animationCounter <= 0 then
			self:death()
		end
	end
	function s:defendLocallyDraw ()
		local fade = 127*self.animationCounter
		love.graphics.setColor(255,255,255,fade)
		drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS*(3-self.animationCounter))
	end
	
	--
	
	function s:defendAbroadUpdate ()
		self:updateAnimationCounter()
		if self.animationCounter <= 0 then
			self:death()
		end
	end
	function s:defendAbroadDraw ()
		if self.animationCounter <= 1 then
			local fade = 127*self.animationCounter
			love.graphics.setColor(255,255,255,fade)
			drawFilledCircle(self.location.x, self.location.y, UNIT_RADIUS*(2-self.animationCounter))
			return false
		end
		return true
	end
	
	--
	
	function s:birth ()
		self.child.state = 'ready'
		self.child.width = 1
		self.state = 'ready'
		self.width = 1
	end
	
	function s:death ()
		self.state = 'dead'
		if self.colony == game.human.colony then
			game.flags.underAttack = true
			if not self.planet:onScreen(true) then
				addDeathRipple(self.planet)
				if game.soundOn then
					attackedSound:setPitch(1*randomRealBetween(.9, 1.1))
					attackedSound:play()
				end
			end
		end
	end
	
	function s:pickRandomPlanet ()
		local weightedPlanets = {}
		local d = 0
		for _, planet in pairs(planets) do
			if self.planet ~= planet and not areConnected(self.planet, planet) then
				d = vMag(vSub(planet.location, self.planet.location))
				local worldMag = vMag(newVector(game.world_size.width, game.world_size.height))
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