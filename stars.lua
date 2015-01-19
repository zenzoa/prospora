stars = {}

function initStars (numStars)
	stars = {}
	for i=1, numStars do
		stars[i] = newStar()
	end
end

function updateStars ()
	for _, star in pairs(stars) do
		star:update()
	end
end

function drawStars ()
	for _, star in pairs(stars) do
		star:draw()
	end
end

function newStar ()
	local s = {}
	
	s.location = newVector(math.random(0, WORLD_SIZE.width), math.random(0, WORLD_SIZE.height))
	s.glitter = math.random(60, 150)
	
	function s:update ()
		self.glitter = self.glitter + randomIntegerBetween(-5, 5)
		self.glitter = math.max(60, math.min(150, self.glitter))
	end
	
	function s:draw ()
		love.graphics.setColor(self.glitter, self.glitter, self.glitter)
		love.graphics.circle('fill', self.location.x*ZOOM, self.location.y*ZOOM, 0.5)
	end
	
	return s
end

