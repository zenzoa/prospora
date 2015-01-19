gameMode = newScreenMode()

gameMode.barWidth = love.graphics.getWidth() * 0.5
gameMode.handleAgg = {}
gameMode.handleCon = {}
gameMode.handleFec = {}
gameMode.handleZoom = {}
gameMode.handleTime = {}
gameMode.handlePause = {}

gameMode.dragging = ''

function gameMode:load ()
	WORLD_SIZE = { width = 1200 + 120*UNIVERSE_SIZE, height = 1200 + 120*UNIVERSE_SIZE }
	OFFSET = { x = WORLD_SIZE.width/2, y = WORLD_SIZE.height/2 }
	TURN_TIME = 30.0
	ZOOM = 0.5
	
	human = newPlayer()
	
	-- setup the game world
	initStars(UNIVERSE_SIZE * 400)
	initSuns(UNIVERSE_SIZE)
	initPlanets(UNIVERSE_SIZE * 3)
	
	self:updateInterface()
	centerOnSelection()
	adjustOffset()
	
	resetMusic()
	if soundOn then gameMusic:play() end
end

function gameMode:update ()
	updateStars()
	updateSuns()
	updatePlanets()
	
	self:updateInterface()
	self:checkDragging()
end

function gameMode:draw ()
	-- draw game world
	love.graphics.push()
	love.graphics.translate(OFFSET.x, OFFSET.y)
	drawStars()
	drawSuns()
	drawPlanets()
	drawHalo()
	love.graphics.pop()
	
	-- draw bars
	love.graphics.setColor(255, 255, 255, 50)
	love.graphics.setLineWidth(30)
	love.graphics.line(0, self.handleAgg.y, self.handleAgg.x - 10, self.handleAgg.y)
	love.graphics.line(0, self.handleFec.y, self.handleFec.x - 10, self.handleFec.y)
	love.graphics.line(0, self.handleCon.y, self.handleCon.x - 10, self.handleCon.y)
	
	love.graphics.setLineWidth(36)
	love.graphics.line(self.handleZoom.x+18, self.handleZoom.y, love.graphics.getWidth(), self.handleZoom.y)
	love.graphics.line(0, self.handleTime.y, self.handleTime.x-17, self.handleTime.y)
	
	-- draw bar handles
	love.graphics.setLineWidth(16)
	if self.dragging == 'agg' then love.graphics.setColor(0, 170, 250) else love.graphics.setColor(0, 170, 250, 150) end
	love.graphics.line(self.handleAgg.x, self.handleAgg.y-15, self.handleAgg.x, self.handleAgg.y+15)
	if self.dragging == 'fec' then love.graphics.setColor(0, 170, 250) else love.graphics.setColor(0, 170, 250, 150) end
	love.graphics.line(self.handleFec.x, self.handleFec.y-15, self.handleFec.x, self.handleFec.y+15)
	if self.dragging == 'con' then love.graphics.setColor(0, 170, 250) else love.graphics.setColor(0, 170, 250, 150) end
	love.graphics.line(self.handleCon.x, self.handleCon.y-15, self.handleCon.x, self.handleCon.y+15)
	
	-- draw labels
	love.graphics.setColor(255, 255, 255)
	love.graphics.print('ATTACK', 5, self.handleAgg.y-10)
	love.graphics.print('SPAWN', 5, self.handleFec.y-10)
	love.graphics.print('TRAVEL', 5, self.handleCon.y-10)
	
	-- draw zoom handle
	if self.dragging == 'zoom' then
		love.graphics.setColor(0, 170, 250)
	else
		love.graphics.setColor(0, 170, 250, 150)
	end
	love.graphics.setLineWidth(36)
	love.graphics.line(self.handleZoom.x-14, self.handleZoom.y, self.handleZoom.x+16, self.handleZoom.y)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(3)
	love.graphics.circle('line', self.handleZoom.x, self.handleZoom.y-3, 8, SEGMENTS)
	love.graphics.setLineWidth(5)
	love.graphics.line(self.handleZoom.x+6, self.handleZoom.y+5, self.handleZoom.x+12, self.handleZoom.y+13)
	
	-- draw time handle
	if self.dragging == 'time' then
		love.graphics.setColor(0, 170, 250)
	else
		love.graphics.setColor(0, 170, 250, 150)
	end
	love.graphics.setLineWidth(36)
	love.graphics.line(self.handleTime.x-15, self.handleTime.y, self.handleTime.x+15, self.handleTime.y)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(3)
	love.graphics.circle('line', self.handleTime.x, self.handleTime.y, 11, SEGMENTS)
	love.graphics.setLineWidth(2)
	love.graphics.line(self.handleTime.x, self.handleTime.y, self.handleTime.x, self.handleTime.y-12)
	love.graphics.line(self.handleTime.x, self.handleTime.y, self.handleTime.x+9, self.handleTime.y-3)
	
	-- draw pause button
	if self.dragging == 'pause' then
		love.graphics.setColor(0, 170, 250)
	else
		love.graphics.setColor(0, 170, 250, 150)
	end
	love.graphics.circle('fill', self.handlePause.x, self.handlePause.y, 20, SEGMENTS)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(5)
	love.graphics.line(self.handlePause.x-6, self.handlePause.y-9, self.handlePause.x-6, self.handlePause.y+9)
	love.graphics.line(self.handlePause.x+6, self.handlePause.y-9, self.handlePause.x+6, self.handlePause.y+9)
end

function gameMode:mousepressed(x, y)
	local mousePos = {x = x, y = y}
	local adjMouse = adjustMousePos(x, y)
	
	selectingPlanet = false
	for _, planet in pairs(planets) do
		if collidePointCircle(adjMouse, planet.location, planet.radius + UNIT_RADIUS*2) then
					human.selectedPlanet = planet
					selectingPlanet = true
					if tableSize(planet:getFriends(human.meme)) > 1 then
						self.dragging = 'launch'
					end
					selectSound:rewind()
					if soundOn then selectSound:play() end
		end
	end
	
	if not selectingPlanet then
		if collidePointCircle(mousePos, self.handleAgg, 15) then
			self.dragging = 'agg'
		elseif collidePointCircle(mousePos, self.handleCon, 15) then
			self.dragging = 'con'
		elseif collidePointCircle(mousePos, self.handleFec, 15) then
			self.dragging = 'fec'
		elseif collidePointCircle(mousePos, self.handleZoom, 20) then
			self.dragging = 'zoom'
		elseif collidePointCircle(mousePos, self.handleTime, 20) then
			self.dragging = 'time'
		elseif collidePointCircle(mousePos, self.handlePause, 20) then
			buttonSound:rewind()
			if soundOn then buttonSound:play() end
			self.dragging = 'pause'
		else
			self.dragging = 'screen'
		end
	end
	
	self.dragStartPoint = adjMouse
end

function gameMode:mousereleased (x, y)
	local adjMouse = adjustMousePos(x, y)
	if self.dragging == 'launch' then
		local d = vMul(vSub(adjMouse, human.selectedPlanet.location), ZOOM)
		if vMag(d) > human.selectedPlanet.radius + UNIT_RADIUS*4 then
			local friends = human.selectedPlanet:getFriends(human.meme)
			if tableSize(friends) > 1 then
				local u = randomElement(friends)
				u:launchFlyer()
				launchSound:rewind()
				if soundOn then launchSound:play() end
			end
		end
	elseif self.dragging == 'pause' then
		switchToMode(pauseMode)
	end
	self.dragging = ''
end

function gameMode:checkDragging ()
	local adjMouse = adjustMousePos(love.mouse.getX(), love.mouse.getY())
	local newGeneLevel = math.max(0.01, math.min(0.99, (love.mouse.getX()-120) / self.barWidth))
	
	if self.dragging == 'screen' then
		local d = vMul(vSub(adjMouse, self.dragStartPoint), ZOOM)
		OFFSET = vAdd(OFFSET, d)
		adjustOffset()
	elseif self.dragging == 'agg' then
		human.meme.agg = newGeneLevel
		human.meme:adjustGenes()
	elseif self.dragging == 'con' then
		human.meme.con = newGeneLevel
		human.meme:adjustGenes()
	elseif self.dragging == 'fec' then
		human.meme.fec = newGeneLevel
		human.meme:adjustGenes()
	elseif self.dragging == 'zoom' then
		ZOOM = 1.33 - math.min(1.0, math.max(0.33, (love.graphics.getWidth()-love.mouse.getX()+37) / (self.barWidth/2)))
		centerOnSelection()
		adjustOffset()
	elseif self.dragging == 'time' then
		TURN_TIME = math.max(10, 60 - (60 * (math.min(love.mouse.getX()-30, self.barWidth/2)) / (self.barWidth/2)))
	end
end

function gameMode:updateInterface ()
	self.handleAgg = newVector(self.barWidth * human.meme.agg + 120, 20)
	self.handleFec = newVector(self.barWidth * human.meme.fec + 120, 60)
	self.handleCon = newVector(self.barWidth * human.meme.con + 120, 100)
	self.handleZoom = newVector(love.graphics.getWidth() - ((1.0 - ZOOM) * (self.barWidth/2)) - 30, love.graphics.getHeight() - 30)
	self.handleTime = newVector((self.barWidth/2)*(1-(TURN_TIME/60)) + 30, love.graphics.getHeight() - 30)
	self.handlePause = newVector(love.graphics.getWidth() / 2, love.graphics.getHeight() - 30)
end