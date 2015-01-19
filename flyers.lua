function updateFlyers(planet)
	for i, flyer in pairs(planet.flyers) do
		flyer:update()
		if flyer:isDead() then
			planet.flyers[i] = nil
		end
	end
end

function drawFlyers(planet)
	for _, flyer in pairs(planet.flyers) do
		flyer:draw()
	end
end

function newFlyer (location, fixedDestination, origin, destination, color)
	local f = {}
	
	f.location = location
	f.fixedDestination = fixedDestination
	f.origin = origin
	f.destination = destination
	f.color = color
	
	f.humanLaunched = false
	f.attackDrone = false
	
	function f:update ()
		if self.fixedDestination then
			
			local dir = vSub(self.destination.location, self.origin.location)
			local totalDistance = vMag(dir)
			dir = vNormalize(dir)
			self.distancePercentage = self.distancePercentage - (0.2 / TURN_TIME)
			self.location = vMul(dir, totalDistance * (1 - self.distancePercentage))
			self.location = vAdd(self.location, self.origin.location)
			
			local p = self:collidesWithPlanet()
			if p ~= nil and p.id == self.destination.id then
				self.velocity = newVector(0, 0)
			end
			
		else
			
			self.location = vAdd(self.location, vDiv(self.velocity, TURN_TIME))
			
			local p = self:collidesWithPlanet()
			if p ~= nil and
					((self.humanLaunched and p.id ~= self.origin.id) or (not self.humanLaunched and p.id == self.destination.id))
					and not areConnected(self.origin, p) then
						table.insert(planetConnections, newPlanetConnection(self.origin, p))
						self.velocity = newVector(0, 0)
			end
			
		end
			
	end
	
	function f:draw ()
		if self.fixedDestination and
		  (self.origin.id == human.selectedPlanet.id or self.destination.id == human.selectedPlanet.id) then
			love.graphics.setColor(200, 200, 200)
		else
			love.graphics.setColor(self.color.r, self.color.g, self.color.b)
		end
		love.graphics.circle('fill', self.location.x*ZOOM, self.location.y*ZOOM, UNIT_RADIUS*0.8*ZOOM, SEGMENTS)
	end
	
	function f:setVelocityTo (location)
		self.velocity = vSub(location, self.origin.location)
		self.velocity = vNormalize(self.velocity)
		self.velocity = vMul(self.velocity, 200)
	end
	
	function f:collidesWithPlanet ()
		for _, planet in pairs(planets) do
			local distance = vSub(planet.location, self.location)
			if math.abs(vMag(distance)) < planet.radius then
				return planet
			end
		end
		return nil
	end
	
	function f:isDead ()
		return vMag(self.velocity) == 0
	end
	
	f:setVelocityTo(f.destination.location)
	if not f.fixedDestination then
		-- predict where planet will be and adjust aim
		local distanceToPlanet = vMag(vSub(f.destination.location, f.origin.location))
		local timeToTravel = distanceToPlanet / vMag(f.velocity)
		local predictedLocation = f.destination.location
		local rAngle = f.destination.rAngle
		local oAngle = f.destination.oAngle
		for i=0, timeToTravel do
			rAngle = (rAngle + f.destination.rVelocity) % TAU
			oAngle = oAngle + f.destination.oVelocity
			predictedLocation = newVector(math.cos(oAngle)*f.destination.oRadius,
																		math.sin(oAngle)*f.destination.oRadius)
			predictedLocation = vAdd(predictedLocation, f.destination.sun.location)
		end
		--local aimingError = randomVector()
		--local adjustedDistance = distanceToPlanet / vMag(newVector(WORLD_SIZE.width, WORLD_SIZE.height))
		--aimingError = vMul(aimingError, randomRealBetween(0, adjustedDistance * 100))
		f:setVelocityTo(predictedLocation)
	end
	
	f.distancePercentage = 1
	
	return f
	
end