function newConnection (planetA, planetB)
	local c = {}
	
	c.a = planetA
	c.b = planetB
	
	planetA.shouldUpdateConnections = true
	planetB.shouldUpdateConnections = true
	
	function c:draw ()
		if self.a == human.selectedPlanet or self.b == human.selectedPlanet then
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
		if (c.a == planetA and c.b == planetB)
			or (c.a == planetB and c.b == planetA) then
				return true
		end
	end
	return false
end