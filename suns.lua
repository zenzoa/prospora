suns = {}
MAX_ATTEMPTS = 1000

function initSuns (numSuns)
	suns = {}
	for i=1, numSuns do
		local attempts = 0
		local s = nil
		while attempts < MAX_ATTEMPTS do
			local radius = math.random(20, 50)
			local orbit = radius * 7
			local location = newVector(math.random(orbit, WORLD_SIZE.width - orbit), math.random(orbit, WORLD_SIZE.height - orbit))
			s = newSun(location, radius)
			
			local overlaps = false
			for _, sun in pairs(suns) do
				if sun ~= nil and collideCircles(sun.location, sun.maxOrbit, s.location, s.maxOrbit) then
					overlaps = true
				end
			end
			if not overlaps then attempts = MAX_ATTEMPTS end
			
			attempts = attempts + 1
		end
			
		suns[i] = s
	end
end

function updateSuns ()
	for _, sun in pairs(suns) do
		sun:update()
	end
end

function drawSuns ()
	for _, sun in pairs(suns) do
		sun:draw()
	end
end

function newSun (location, radius)
	local s = {}
	
	s.location = location
	s.radius = radius
	s.corona = randomRealBetween(0, radius)
	s.maxOrbit = radius*7
	
	function s:update ()
		self.corona = self.corona + randomRealBetween(-0.3, 0.3)
		self.corona = math.max(0, math.min(self.radius, self.corona))
	end
	
	function s:draw ()
		love.graphics.setColor(255, 255, 255, 177)
		drawFilledCircle(self.location.x, self.location.y, self.radius+self.corona)
		love.graphics.setColor(255, 255, 255, 255)
		drawFilledCircle(self.location.x, self.location.y, self.radius)
	end
	
	s.newOrbit = function (self)
		local attempts = 0
		local orbit = nil
		while (attempts < MAX_ATTEMPTS) do
			local overlaps = false
			orbit = randomRealBetween((self.radius * 1.5) + self.corona, self.maxOrbit)
			for _, planet in pairs(planets) do
				if planet ~= nil
					and planet.parentSun == self
					and math.abs(planet.orbitalRadius - orbit) < planet.radius * 2 then
					overlaps = true
				end
			end
			if not overlaps then attempts = MAX_ATTEMPTS end
			attempts = attempts + 1
		end
		return orbit
	end
	
	return s
end

