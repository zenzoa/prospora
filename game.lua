function newGame ()
	local g = {}
	
	g.interface = newInterface()
	g.dragStartPoint = {x=0, y=0}
	
	function g:load ()
		self.paused = false
		self.interface = newInterface()
		self.dragStartPoint = {x=0, y=0}
		self.dragging = nil
		
		TURN_TIME = 60.0
		ZOOM = 1
		resetFlags()
		human = newPlayer()
		
		if TUTORIAL then
			self.interface:newTutorial()
			
			UNIVERSE_SIZE = 10
			WORLD_SIZE = { width = 1200 + 120*UNIVERSE_SIZE, height = 1200 + 120*UNIVERSE_SIZE }
			OFFSET = { x = WORLD_SIZE.width/2, y = WORLD_SIZE.height/2 }
			
			initStars(UNIVERSE_SIZE * 400)
			initTutorialWorld()
		else
			self.interface:newGame()
			
			UNIVERSE_SIZE = 10
			WORLD_SIZE = { width = 1200 + 120*UNIVERSE_SIZE, height = 1200 + 120*UNIVERSE_SIZE }
			OFFSET = { x = WORLD_SIZE.width/2, y = WORLD_SIZE.height/2 }
			
			initStars(UNIVERSE_SIZE * 400)
			initSuns(UNIVERSE_SIZE)
			initPlanets(UNIVERSE_SIZE * 3)
		end
		
		if not self.paused and soundOn then
			gameMusic:rewind()
			gameMusic:play()
		else
			gameMusic:pause()
		end
	
		centerOnSelection()
		human.selectedPlanet = nil
	end
	
	function g:update ()
		if not self.paused then
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
		post_effect(function()
			love.graphics.setColor(51, 51, 51)
			love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
			
			love.graphics.push()
			love.graphics.translate(OFFSET.x, OFFSET.y)
			
			drawSuns()
			drawStars()
			drawPlanets()
			
			if not self.paused and self.dragging == 'launch' then
				drawHalo(adjustPos(love.mouse.getX(), love.mouse.getY()))
			else
				drawHalo()
			end
			
			love.graphics.pop()
			
			self.interface:draw()
		end)
	end
	
	function g:mousepressed (x, y)
		local touchPos = {x = x, y = y}
		local adjPos = adjustPos(x, y)
		
		local interfaceBusy = self.interface:mousepressed(x, y)
		
		if not interfaceBusy then
			local selectingPlanet = false
			for _, planet in pairs(planets) do
				if collidePointCircle(adjPos, planet.location, planet.radius + UNIT_RADIUS*2) then
					human.selectedPlanet = planet
					selectingPlanet = true
					local friendsOnPlanet = planet:countFriends(human.colony)
					if friendsOnPlanet > 1 and (not TUTORIAL or flags.allowLaunching) then
						self.dragging = 'launch'
					end
					if friendsOnPlanet == 1 then
						flags.oneSporeLeft = true
					end
					if planet == human.homeWorld then
						flags.selectHomeWorld = true
					end
					if soundOn then
						selectSound:setPitch(1*randomRealBetween(.9, 1.1))
						selectSound:play()
					end
				end
			end
	
			if not selectingPlanet then
				-- check with interface elements
				self.dragging = 'screen'
				flags.shiftView = true
			end
	
			self.dragStartPoint = adjPos
		end
	end
	
	function g:mousereleased (x, y)
		local adjPos = adjustPos(x, y)
		
		local interfaceBusy = self.interface:mousereleased(x, y)
		
		if not interfaceBusy and self.dragging == 'launch' and human.selectedPlanet then
			local d = vMul(vSub(adjPos, human.selectedPlanet.location), ZOOM)
			if vMag(d) > human.selectedPlanet.radius + UNIT_RADIUS*4 then
				if human.selectedPlanet:countFriends(human.colony) > 1 then
					local spore = human.selectedPlanet:findFriend(human.colony)
					spore:launchExplorer()
					if soundOn then
						launchSound:setPitch(1*randomRealBetween(.9, 1.1))
						launchSound:play()
					end
				end
			end
		end
		
		self.dragging = ''
	end
	
	function g:togglePause ()
		self.paused = not self.paused
		
		if self.paused then
			if self.interface.messages[1] then
				self.interface.allMessages.paused.lastMessage = self.interface.messages[1]
			end
			self.interface:addMessage(self.interface.allMessages.paused)
		elseif self.interface.messages[1] and self.interface.messages[1].flag == 'paused' then
			if self.interface.allMessages.paused.lastMessage then
				self.interface:addMessage(self.interface.allMessages.paused.lastMessage)
				self.interface.allMessages.paused.lastMessage = nil
			else
				self.interface.messages[1].fading = true
			end
		end
		
		if not self.paused and soundOn then
			gameMusic:play()
		else
			gameMusic:pause()
			flags.pause = true
		end
	end
	
	function g:gameOver ()
		local noEnemyHomeworlds = true
		for _, planet in pairs(planets) do
			if planet.isHomeWorld and planet.homeWorldMeme ~= human.colony then
				noEnemyHomeworlds = false
			end
		end
		if noEnemyHomeworlds then
			flags.win = true
		elseif not human.homeWorld.isHomeWorld then
			flags.lose = true
		end
	end
	
	return g
end

function centerOnSelection ()
	if human.selectedPlanet then
		OFFSET.x = (love.graphics.getWidth() / 2) - (human.selectedPlanet.location.x * ZOOM)
		OFFSET.y = (love.graphics.getHeight() / 2) - (human.selectedPlanet.location.y * ZOOM)
	end
	adjustOffset()
end

function drawHalo (launchPos)
	local p = human.selectedPlanet
	if p then
		local haloRadius = 0
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
end