function newGame (tutorial)
	local g = {}

	g.tutorial = tutorial
	g.soundOn = true
	g.isFullscreen = false
	g.deathRipples = {}
	
	function g:load ()
		self.paused = false
		self.interface = newInterface()
		self.dragStartPoint = {x=0, y=0}
		self.dragging = nil
		
		self.turn_time = 60.0
		self.zoom = 1
		self:resetFlags()
		self.human = newPlayer()
		
		if self.tutorial then
			self.interface:newTutorial()
			
			self.universe_size = 10
			self.world_size = { width = 1200 + 120*self.universe_size, height = 1200 + 120*self.universe_size }
			self.offset = { x = self.world_size.width/2, y = self.world_size.height/2 }
			
			initStars(self.universe_size * 400)
			initTutorialWorld()
		else
			self.interface:newGame()
			
			self.universe_size = 10
			self.world_size = { width = 1200 + 120*self.universe_size, height = 1200 + 120*self.universe_size }
			self.offset = { x = self.world_size.width/2, y = self.world_size.height/2 }
			
			initStars(self.universe_size * 400)
			initSuns(self.universe_size)
			initPlanets(self.universe_size * 3)
		end
		
		if self.soundOn then
			if self.paused then
				gameMusic:setVolume(0.5)
			else
				gameMusic:setVolume(1)
			end
			gameMusic:rewind()
			gameMusic:play()
		end
		
		centerOnSelection()
		self.human.selectedPlanet = nil
	end
	
	function g:update ()
		if not self.paused then
			updateDeathRipples()
			updateStars()
			updateSuns()
			updatePlanets()
			
			if self.dragging == 'screen' then
				local adjMouse = adjustPos(love.mouse.getX(), love.mouse.getY())
				local d = vMul(vSub(adjMouse, self.dragStartPoint), self.zoom)
				self.offset = vAdd(self.offset, d)
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
			love.graphics.translate(self.offset.x, self.offset.y)
			
			drawDeathRipples()
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
			if not self.flags.win and not self.flags.lose then
				for _, planet in pairs(planets) do
					if collidePointCircle(adjPos, planet.location, planet.radius + UNIT_RADIUS*2) then
						self.human.selectedPlanet = planet
						selectingPlanet = true
						local friendsOnPlanet = planet:countFriends(self.human.colony)
						if friendsOnPlanet > 1 and (not self.tutorial or self.flags.allowLaunching) then
							self.dragging = 'launch'
						end
						if friendsOnPlanet == 1 then
							self.flags.oneSporeLeft = true
						end
						if planet == self.human.homeWorld then
							self.flags.selectHomeWorld = true
						end
						if self.soundOn then
							selectSound:setPitch(1*randomRealBetween(.9, 1.1))
							selectSound:play()
						end
					end
				end
			end
	
			if not selectingPlanet then
				self.dragging = 'screen'
				self.flags.shiftView = true
			end
	
			self.dragStartPoint = adjPos
		end
	end
	
	function g:mousereleased (x, y)
		local adjPos = adjustPos(x, y)
		
		local interfaceBusy = self.interface:mousereleased(x, y)
		
		if not interfaceBusy and self.dragging == 'launch' and self.human.selectedPlanet then
			local d = vMul(vSub(adjPos, self.human.selectedPlanet.location), self.zoom)
			if vMag(d) > self.human.selectedPlanet.radius + UNIT_RADIUS*4 then
				self:launchHumanSpore(adjustPos(love.mouse.getX(), love.mouse.getY()))
			end
		end
		
		self.dragging = ''
	end
	
	function g:launchHumanSpore (destination)
		if self.human.selectedPlanet:countFriends(self.human.colony) > 1 then
			local spore = self.human.selectedPlanet:findFriend(self.human.colony)
			spore:launchExplorer(destination)
			if self.soundOn then
				launchSound:setPitch(1*randomRealBetween(.9, 1.1))
				launchSound:play()
			end
		end
	end
	
	function g:togglePause ()
		self.paused = not self.paused
		
		if self.paused then
			self.flags.pause = true
			if self.interface.messages[1] and self.interface.messages[1].flag ~= 'paused' then
				self.interface.allMessages.paused.lastMessage = self.interface.messages[1]
			end
			self.interface:addMessage(self.interface.allMessages.paused)
		elseif self.interface.messages[1] and self.interface.messages[1].flag == 'paused' then
			if self.interface.allMessages.paused.lastMessage then
				self.interface:addMessage(self.interface.allMessages.paused.lastMessage)
				self.interface.allMessages.paused.lastMessage = nil
			else
				self.interface.messages[1].fading = true
				self.interface.messages[1].fadeOnClick = false
			end
		end
		
		if self.soundOn then
			if self.paused then
				gameMusic:setVolume(0.25)
			else
				gameMusic:setVolume(1)
			end
			gameMusic:play()
		end
	end
	
	function g:checkGameOver ()
		if not game.flags.win and not game.flags.lose then
			local enemyHomeworlds = 0
			for _, planet in pairs(planets) do
				if planet.isHomeWorld and planet.startingColony ~= self.human.colony then
					enemyHomeworlds = enemyHomeworlds + 1
				end
			end
			if enemyHomeworlds == 0 then
				self.flags.win = true
				game.human.selectedPlanet = nil
				gameMusic:stop()
				gameMusic:rewind()
				if self.soundOn then
					winMusic:rewind()
					winMusic:play()
				end
			elseif not self.human.homeWorld.isHomeWorld then
				self.flags.lose = true
				game.human.selectedPlanet = nil
				gameMusic:stop()
				if self.soundOn then
					loseSound:play()
				end
			end
		end
	end
	
	function g:resetFlags ()
		self.flags = {}
	end
	
	return g
end

function centerOnSelection ()
	if game.human.selectedPlanet then
		game.offset.x = (love.graphics.getWidth() / 2) - (game.human.selectedPlanet.location.x * game.zoom)
		game.offset.y = (love.graphics.getHeight() / 2) - (game.human.selectedPlanet.location.y * game.zoom)
	end
	adjustOffset()
end

function drawHalo (launchPos)
	local p = game.human.selectedPlanet
	if p then
		local haloRadius = 0
		local maxHalo = UNIT_RADIUS * 40
		local minHalo = UNIT_RADIUS * 5
		love.graphics.setColor(255, 255, 255)
	
		if launchPos then
			love.graphics.setColor(0, 170, 250)
			local d = vMul(vSub(launchPos, p.location), game.zoom)
			local dMag = vMag(d)
			haloRadius = math.max( math.min(dMag, p.radius + maxHalo), p.radius + minHalo)
			if dMag > p.radius + minHalo then
				d = vNormalize(d)
				d = vMul(d, haloRadius)
				d = vAdd(d, p.location)
				drawFilledCircle(d.x, d.y, UNIT_RADIUS/game.zoom)
			end
		elseif not game.paused and love.keyboard.isDown('lshift') then
			love.graphics.setColor(0, 170, 250)
			haloRadius = p.radius + (minHalo + maxHalo)/2
			local d = unitVectorFromAngle(LAUNCH_ANGLE)
			d = vMul(d, haloRadius)
			d = vAdd(d, p.location)
			drawFilledCircle(d.x, d.y, UNIT_RADIUS/game.zoom)
		else
			haloRadius = p.radius + minHalo
		end
	
		love.graphics.setLineWidth(1.5)
		love.graphics.circle('line', p.location.x * game.zoom, p.location.y * game.zoom, haloRadius * game.zoom, SEGMENTS*2)
	end
end