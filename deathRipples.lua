function newDeathRipple (planetOfOrigin)
	local r = {}
	
	r.location = planetOfOrigin.location
	r.radius = 0
	r.maxRadius = math.max(game.world_size.width, game.world_size.height)/2
	
	function r:update ()
		self.radius = self.radius + 10
		if self.radius > self.maxRadius then
			return true
		end
	end
	
	function r:draw ()
		local opacity = 1 - (self.radius / self.maxRadius)
		love.graphics.setColor(255, 220, 200, 127*opacity)
		drawFilledCircle(self.location.x, self.location.y, self.radius)
	end
	
	return r
end

function addDeathRipple(planet)
	table.insert(game.deathRipples, newDeathRipple(planet))
end

function updateDeathRipples()
	for i, ripple in pairs(game.deathRipples) do
		if ripple:update() then
			table.remove(game.deathRipples, 1)
		end
	end
end

function drawDeathRipples()
	for i, ripple in pairs(game.deathRipples) do
		ripple:draw()
	end
end