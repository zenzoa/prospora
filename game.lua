function newGame ()
	local g = {}
	
	g.paused = false
	g.interface = newInterface()
	g.dragStartPoint = {x=0, y=0}
	g.dragging = nil
	
	function g:load ()
		STARTED = true
		UNIVERSE_SIZE = 10
		WORLD_SIZE = { width = 1200 + 120*UNIVERSE_SIZE, height = 1200 + 120*UNIVERSE_SIZE }
		OFFSET = { x = WORLD_SIZE.width/2, y = WORLD_SIZE.height/2 }
		TURN_TIME = 60.0
		ZOOM = 1
	
		human = newPlayer()
	
		-- setup the game world
		initStars(UNIVERSE_SIZE * 400)
		initSuns(UNIVERSE_SIZE)
		initPlanets(UNIVERSE_SIZE * 3)
	
		centerOnSelection()
		adjustOffset()
	
		--resetMusic()
		if soundOn then gameMusic:play() end
	end
	
	function g:update ()
		if not paused then
			updateStars()
			updateSuns()
			updatePlanets()
			
			if self.dragging == 'screen' then
				local adjMouse = adjustPos(love.mouse.getX(), love.mouse.getY())
				local d = vMul(vSub(adjMouse, self.dragStartPoint), ZOOM)
				OFFSET = vAdd(OFFSET, d)
				adjustOffset()
			end
		end
		self.interface:update()
	end
	
	function g:draw ()
		if not paused then
			post_effect:draw(function()
				love.graphics.setColor(51, 51, 51)
				love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
				love.graphics.push()
				love.graphics.translate(OFFSET.x, OFFSET.y)
				drawSuns()
				drawStars()
				drawPlanets()
				if self.dragging == 'launch' then
					drawHalo(adjustPos(love.mouse.getX(), love.mouse.getY()))
				else
					drawHalo()
				end
				love.graphics.pop()
			end)
		end
		self.interface:draw()
	end
	
	function g:mousepressed (x, y)

		local touchPos = {x = x, y = y}
		local adjPos = adjustPos(x, y)
	
		local selectingPlanet = false
		for _, planet in pairs(planets) do
			if collidePointCircle(adjPos, planet.location, planet.radius + UNIT_RADIUS*2) then
						human.selectedPlanet = planet
						selectingPlanet = true
						if planet:countFriends(human.colony) > 1 then
							self.dragging = 'launch'
						end
						selectSound:rewind()
						if soundOn then selectSound:play() end
			end
		end
	
		if not selectingPlanet then
			-- check with interface elements
			self.dragging = 'screen'
		end
	
		self.dragStartPoint = adjPos
	end
	
	function g:mousereleased (x, y)
		local adjPos = adjustPos(x, y)
		if self.dragging == 'launch' then
			local d = vMul(vSub(adjPos, human.selectedPlanet.location), ZOOM)
			if vMag(d) > human.selectedPlanet.radius + UNIT_RADIUS*4 then
				if human.selectedPlanet:countFriends(human.colony) > 1 then
					local spore = human.selectedPlanet:findFriend(human.colony)
					spore:launchExplorer()
					if soundOn then launchSound:play() end
				end
			end
		end
		self.dragging = ''
	end
	
	return g
end

function newInterface ()
	local i = {}
	
	function i:update ()
		--
	end
	
	function i:draw ()
		-- draw every element
	end
	
	return i
end

function newElement (triggered, text, activate, fontsize)
	local e = {}
	
	e.triggered = triggered
	e.completed = completed
	e.text = text
	
	e.fontsize = 20 or fontsize
	e.width = string.len(e.text) * self.fontsize
	e.height = e.fontsize
	
	function e:draw ()
		local x = (love.window.getWidth() - self.width)*0.5
		local y = (love.window.getHeight() - self.height)*0.8
		local buffer = self.fontsize/2
		love.graphics.setColor(0,0,0,127)
		love.graphics.rectangle('fill', x-buffer, y-buffer, self.width+buffer*2, self.height+buffer*2)
		if self.fontsize > FONT_SIZE then love.graphics.setFont(fontLarge) else love.graphics.setFont(font) end
		if self.activate then love.graphics.setColor(0, 170, 250) else love.graphics.setColor(255, 255, 255) end
		love.graphics.print(self.text, x, y)
	end
	
	function e:pushed (x, y)
		return x >= self.location.x and x <= self.location.x+self.width and y >= self.location.y and y <= self.location.y+self.height
	end
	
	return e
end

--[[welcomeMessage = newElement(
	function() return STARTED end,
	'welcome to prospora', --strings.welcome,
	nil,
	FONT_SIZE*2
)
	
skipTutorial = newElement(
	function() return NEW_PLAYER end,
	'skip tutorial', --strings.skipTutorial,
	function ()
		NEW_PLAYER = false
		--change game state
	end
)]]--

function centerOnSelection ()
	OFFSET.x = (love.graphics.getWidth() / 2) - (human.selectedPlanet.location.x * ZOOM)
	OFFSET.y = (love.graphics.getHeight() / 2) - (human.selectedPlanet.location.y * ZOOM)
end

function drawHalo (launchPos)
	local haloRadius = 0
	local p = human.selectedPlanet
	local maxHalo = UNIT_RADIUS * 40
	local minHalo = UNIT_RADIUS * 5
	love.graphics.setColor(255, 255, 255)
	
	if launchPos then
		love.graphics.setColor(0, 170, 250)
		local d = vMul(vSub(launchPos, p.location), ZOOM)
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

--[[

gameMode = newScreenMode()

gameMode.barWidth = love.graphics.getWidth() * 0.5
gameMode.handleAttack = {}
gameMode.handleTravel = {}
gameMode.handleSpawn = {}
gameMode.handleZoom = {}
gameMode.handleTime = {}
gameMode.handlePause = {}

gameMode.dragging = ''

function gameMode:load ()
	WORLD_SIZE = { width = 1200 + 120*UNIVERSE_SIZE, height = 1200 + 120*UNIVERSE_SIZE }
	OFFSET = { x = WORLD_SIZE.width/2, y = WORLD_SIZE.height/2 }
	TURN_TIME = 60.0
	ZOOM = 1
	
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
	love.graphics.line(0, self.handleAttack.y, self.handleAttack.x - 10, self.handleAttack.y)
	love.graphics.line(0, self.handleSpawn.y, self.handleSpawn.x - 10, self.handleSpawn.y)
	love.graphics.line(0, self.handleTravel.y, self.handleTravel.x - 10, self.handleTravel.y)
	
	if advancedControls then
		love.graphics.setLineWidth(36)
		love.graphics.line(self.handleZoom.x+18, self.handleZoom.y, love.graphics.getWidth(), self.handleZoom.y)
		love.graphics.line(0, self.handleTime.y, self.handleTime.x-17, self.handleTime.y)
	end
	
	-- draw bar handles
	love.graphics.setLineWidth(16)
	if self.dragging == 'attack' then love.graphics.setColor(0, 170, 250) else love.graphics.setColor(0, 170, 250, 150) end
	love.graphics.line(self.handleAttack.x, self.handleAttack.y-15, self.handleAttack.x, self.handleAttack.y+15)
	if self.dragging == 'spawn' then love.graphics.setColor(0, 170, 250) else love.graphics.setColor(0, 170, 250, 150) end
	love.graphics.line(self.handleSpawn.x, self.handleSpawn.y-15, self.handleSpawn.x, self.handleSpawn.y+15)
	if self.dragging == 'travel' then love.graphics.setColor(0, 170, 250) else love.graphics.setColor(0, 170, 250, 150) end
	love.graphics.line(self.handleTravel.x, self.handleTravel.y-15, self.handleTravel.x, self.handleTravel.y+15)
	
	-- draw labels
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(strings.attack, 5, self.handleAttack.y-10)
	love.graphics.print(strings.spawn, 5, self.handleSpawn.y-10)
	love.graphics.print(strings.travel, 5, self.handleTravel.y-10)
	
	if advancedControls then
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
	end
	
	-- draw pause button
	if self.dragging == 'pause' then
		love.graphics.setColor(0, 170, 250)
	else
		love.graphics.setColor(0, 170, 250, 150)
	end
	--drawFilledCircle(self.handlePause.x/ZOOM, self.handlePause.y/ZOOM, 20/ZOOM)
	love.graphics.rectangle('fill', self.handlePause.x-20, self.handlePause.y-20, 40, 40)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(6)
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
					if planet:countFriends(human.colony) > 1 then
						self.dragging = 'launch'
					end
					selectSound:rewind()
					if soundOn then selectSound:play() end
		end
	end
	
	if not selectingPlanet then
		if collidePointCircle(mousePos, self.handleAttack, 15) then
			self.dragging = 'attack'
		elseif collidePointCircle(mousePos, self.handleTravel, 15) then
			self.dragging = 'travel'
		elseif collidePointCircle(mousePos, self.handleSpawn, 15) then
			self.dragging = 'spawn'
		elseif advancedControls and collidePointCircle(mousePos, self.handleZoom, 20) then
			self.dragging = 'zoom'
		elseif advancedControls and collidePointCircle(mousePos, self.handleTime, 20) then
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
			if human.selectedPlanet:countFriends(human.colony) > 1 then
				local spore = human.selectedPlanet:findFriend(human.colony)
				spore:launchExplorer()
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
	elseif self.dragging == 'attack' then
		human.colony.attack = newGeneLevel
		human.colony:adjustGenes()
	elseif self.dragging == 'travel' then
		human.colony.travel = newGeneLevel
		human.colony:adjustGenes()
	elseif self.dragging == 'spawn' then
		human.colony.spawn = newGeneLevel
		human.colony:adjustGenes()
	elseif self.dragging == 'zoom' then
		ZOOM = 1.33 - math.min(1.0, math.max(0.33, (love.graphics.getWidth()-love.mouse.getX()+37) / (self.barWidth/2)))
		centerOnSelection()
		adjustOffset()
	elseif self.dragging == 'time' then
		TURN_TIME = math.max(10, 60 - (60 * (math.min(love.mouse.getX()-30, self.barWidth/2)) / (self.barWidth/2)))
	end
end

function gameMode:updateInterface ()
	self.handleAttack = newVector(self.barWidth * human.colony.attack + 120, 20)
	self.handleSpawn = newVector(self.barWidth * human.colony.spawn + 120, 60)
	self.handleTravel = newVector(self.barWidth * human.colony.travel + 120, 100)
	self.handleZoom = newVector(love.graphics.getWidth() - ((1.0 - ZOOM) * (self.barWidth/2)) - 30, love.graphics.getHeight() - 30)
	self.handleTime = newVector((self.barWidth/2)*(1-(TURN_TIME/60)) + 30, love.graphics.getHeight() - 30)
	self.handlePause = newVector(love.graphics.getWidth() - 25, 25)
end]]--