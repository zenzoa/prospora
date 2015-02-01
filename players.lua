-- for future multiplayer, other players are not distinguished for being human; they show up as a random color on your screen like all the NPCs. Bwahaha!

function newPlayer ()
	local p = {}
	
	p.meme = newMeme()
	p.meme.color = { r=50, g=186, b=250 }
	p.selectedPlanet = nil
	p.homeWorld = nil
	p.homeUnderAttack = false
	
	return p
	
end

function centerOnSelection ()
	OFFSET.x = (love.graphics.getWidth() / 2) - (human.selectedPlanet.location.x * ZOOM)
	OFFSET.y = (love.graphics.getHeight() / 2) - (human.selectedPlanet.location.y * ZOOM)
end

function drawHalo ()
	local haloRadius = 0
	local p = human.selectedPlanet
	local maxHalo = UNIT_RADIUS * 40
	local minHalo = UNIT_RADIUS * 5
	love.graphics.setColor(0, 170, 250)
	
	if gameMode.dragging == 'launch' then
		local adjMouse = adjustMousePos(love.mouse.getX(), love.mouse.getY())
		local d = vMul(vSub(adjMouse, p.location), ZOOM)
		local dMag = vMag(d)
		haloRadius = math.max( math.min(dMag, p.radius + maxHalo), p.radius + minHalo)
		if dMag > p.radius + minHalo then
			d = vNormalize(d)
			d = vMul(d, haloRadius)
			d = vAdd(d, p.location)
			drawFilledCircle(d.x, d.y, UNIT_RADIUS/ZOOM)
		end
		
	else
		haloRadius = p.radius + minHalo
	end
	
	love.graphics.setLineWidth(1.5)
	love.graphics.circle('line', p.location.x * ZOOM, p.location.y * ZOOM, haloRadius * ZOOM, SEGMENTS*2)
	
end