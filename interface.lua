function newInterface ()
	local i = {}
	
	i.attackSlider = newSlider('attack', 1)
	i.spawnSlider = newSlider('spawn', 2)
	i.travelSlider = newSlider('travel', 3)
	i.sliders = {i.attackSlider, i.spawnSlider, i.travelSlider}
	
	i.messages = {}
	i.allMessages = {}
	
	function i:update ()
		for _, s in pairs(self.sliders) do
			s:update()
		end
	
		for i, m in pairs(self.messages) do
			if m:update() then
				table.remove(self.messages, i)
			end
		end
		
		if not game.paused then
			if game.tutorial then
				self:checkFlags()
			else
				if game.flags.win then
					self:addMessage(self.allMessages.win)
				elseif game.flags.lose then
					self:addMessage(self.allMessages.lose)
				end
			end
		end
	end
	
	function i:draw ()
		for _, s in pairs(self.sliders) do
			s:draw()
		end
	
		for _, m in pairs(self.messages) do
			m:draw()
		end
	end
	
	function i:mousepressed (x, y)
		local busy = false
		
		if self.messages[1] and self.messages[1]:press(x, y) then busy = true end
	
		for _, s in pairs(self.sliders) do
			if x >= s.actArea.x and x <= s.actArea.x+s.actArea.width and y >= s.actArea.y and y <= s.actArea.y+s.actArea.height then
				s:press(x, y)
				busy = true
			end
		end
		
		return busy
	end
	
	function i:mousereleased (x, y)
		local busy = false
		
		if self.messages[1] and self.messages[1]:release(x, y) then busy = true end
		
		for _, s in pairs(self.sliders) do
			if s:release(x, y) then busy = true end
		end
			
		return busy
	end
	
	function i:newGame ()
		self.messages = {}
		self.allMessages = self:createMessages()
	end
	
	function i:newTutorial ()
		self.messages = {}
		self.allMessages = createTutorialMessages()
		self:addMessage(self.allMessages.selectHomeWorld)
	end
	
	function i:addMessage(newMessage)
		for i, m in pairs(self.messages) do
			if m == newMessage then
				table.remove(self.messages, i)
			else
				m.fading = true
				m.fadeOnClick = false
			end
		end
		newMessage.fading = false
		newMessage.opacity = 1
		newMessage.selectedButton = 0
		if newMessage.hotspot then
			newMessage.hotspot.opacity = 1
		end
		table.insert(self.messages, 1, newMessage)
	end
	
	function i:createMessages()
		local m = {}
		
		--
		
		m.paused = newMessage('paused', strings.paused)
		
		local returnToGameButton = function (self)
				game:togglePause()
			end
		m.paused:addButton('> ' .. strings.returnToGame, returnToGameButton)
		
		local soundToggleButton = function (self)
				if game.soundOn then
					game.soundOn = false
					self.text = '> ' .. strings.soundOn
					gameMusic:pause()
				else
					game.soundOn = true
					self.text = '> ' .. strings.soundOff
					gameMusic:play()
				end
			end
		local soundToggleString = strings.soundOn
		if game.soundOn then soundToggleString = strings.soundOff end
		m.paused:addButton('> ' .. soundToggleString, soundToggleButton)
		
		local fullscreenToggleButton = function (self)
				toggleFullscreen()
				if game.isFullscreen then
					self.text = '> ' .. strings.fullscreenOff
				else
					self.text = '> ' .. strings.fullscreenOn
				end
			end
		local fullscreenToggleString = strings.fullscreenOn
		if game.isFullscreen then fullscreenToggleString = strings.fullscreenOff end
		m.paused:addButton('> ' .. fullscreenToggleString, fullscreenToggleButton)
		
		local creditsButton = function (self)
				game.interface.allMessages.credits.fading = false
				game.interface.allMessages.credits.opacity = 1
				game.interface.messages[1] = game.interface.allMessages.credits
			end
		m.paused:addButton('> ' .. strings.credits, creditsButton)
		
		local newGameButton = function (self)
				game = newGame(false)
				game:load()
			end
		m.paused:addButton('< ' .. strings.newGame .. ' >', newGameButton, 'left')
		
		local newTutorialButton = function (self)
				game = newGame(true)
				game:load()
			end
		m.paused:addButton('< ' .. strings.newTutorial .. ' >', newTutorialButton, 'center')
		
		local newQuitButton = function (self)
				love.event.quit()
			end
		m.paused:addButton('< ' .. strings.quit .. ' >', newQuitButton, 'right')
		
		--
		
		m.win = newMessage('win', strings.win)
		m.win:addButton('< ' .. strings.newGame .. ' >', newGameButton, 'left')
		m.win:addButton('< ' .. strings.newTutorial .. ' >', newTutorialButton, 'center')
		m.win:addButton('< ' .. strings.quit .. ' >', newQuitButton, 'right')
		
		--
		
		m.lose = newMessage('lose', strings.lose)
		m.lose:addButton('< ' .. strings.newGame .. ' >', newGameButton, 'left')
		m.lose:addButton('< ' .. strings.newTutorial .. ' >', newTutorialButton, 'center')
		m.lose:addButton('< ' .. strings.quit .. ' >', newQuitButton, 'right')
		
		--
		
		m.winTutorial = newMessage('win', strings.winTutorial)
		m.winTutorial:addButton('> ' .. strings.restartTutorial, newTutorialButton)
		m.winTutorial:addButton('> ' .. strings.startFullGame, newGameButton)
		m.winTutorial:addButton('< ' .. strings.quit .. ' >', newQuitButton, 'right')
		
		--
		
		m.loseTutorial = newMessage('lose', strings.loseTutorial)
		m.loseTutorial:addButton('> ' .. strings.restartTutorial, newTutorialButton)
		m.loseTutorial:addButton('> ' .. strings.startFullGame, newGameButton)
		m.loseTutorial:addButton('< ' .. strings.quit .. ' >', newQuitButton, 'right')
		
		--
		
		m.credits = newMessage('paused', strings.creditsText)
		local returnButton = function (self)
				game.interface.allMessages.paused.fading = false
				game.interface.allMessages.paused.opacity = 1
				game.interface.messages[1] = game.interface.allMessages.paused
			end
		m.credits:addButton('> ' .. 'Return to Menu', returnButton)
		
		--
		
		return m
	end
	
	function i:checkFlags()
		if game.flags.selectHomeWorld then
			game.flags.allowLaunching = true
			if self.messages[1] and self.messages[1].flag == 'selectHomeWorld' then
				self:addMessage(self.allMessages.makeConnection)
			elseif game.flags.makeConnection then
				if self.messages[1] and self.messages[1].flag == 'makeConnection' then
					self:addMessage(self.allMessages.increaseTravel)
					game.flags.increaseTravel = false
				elseif game.flags.increaseTravel then
					if self.messages[1] and self.messages[1].flag == 'increaseTravel' then
						self:addMessage(self.allMessages.shiftView)
					elseif game.flags.shiftView then
						if self.messages[1] and self.messages[1].flag == 'shiftView' then
							self.messages[1].fading = true
						elseif game.flags.enemyHomeInView then
							game.flags.allowEnemyConnections = true
							if not self.allMessages.enemyHomeInView.alreadyShown then
								self:addMessage(self.allMessages.enemyHomeInView)
								self.allMessages.enemyHomeInView.alreadyShown = true
							end
							if game.flags.underAttack then
								if not self.allMessages.increaseAttack.alreadyShown then
									self:addMessage(self.allMessages.increaseAttack)
									self.allMessages.increaseAttack.alreadyShown = true
									game.flags.increaseAttack = false
								end
								if game.flags.increaseAttack then
									if self.messages[1] and self.messages[1].flag == 'increaseAttack' then
										self:addMessage(self.allMessages.pause)
										game.flags.pause = false
									end
									if game.flags.pause then
										if self.messages[1] and self.messages[1].flag == 'pause' then
											self.messages[1].fading = true
										end
									end
								end
							end
						end
					end
				end
			end
			if game.flags.oneSporeLeft then
				if not self.messages[1] and not self.allMessages.increaseSpawn.alreadyShown then
					self:addMessage(self.allMessages.increaseSpawn)
					self.allMessages.increaseSpawn.alreadyShown = true
					game.flags.increaseSpawn = false
				end
				if game.flags.increaseSpawn then
					if self.messages[1] and self.messages[1].flag == 'increaseSpawn' then
						self.messages[1].fading = true
					end
				end
			end
		end
		if game.flags.win then
			self:addMessage(self.allMessages.winTutorial)
		elseif game.flags.lose then
			self:addMessage(self.allMessages.loseTutorial)
		end
	end
	
	return i
end

function newMessage (flag, text)
	local m = {}
	m.flag = flag
	
	m.pressed = false
	
	m.text = text
	m.buttons = {}
	m.hotspot = nil
	
	m.opacity = 1
	m.fading = false
	m.menuHeight = 0
	m.menuY = 0
	m.lineHeight = FONT_SIZE*2
	
	m.selectedButton = 0
	
	function m:selectNextButton (attempts)
		self.selectedButton = self.selectedButton + 1
		if self.selectedButton > tableSize(self.buttons) then
			self.selectedButton = 0
		elseif self.selectedButton > 0 and not self.buttons[self.selectedButton].func then
			if not attempts then attempts = 0 end
			if attempts < tableSize(self.buttons) then
				self:selectNextButton(attempts+1)
			else
				return false
			end
		end
		if attempts and self.selectedButton == 0 then
			return false
		end
		return true
	end
	
	function m:selectPrevButton (attempts)
		self.selectedButton = self.selectedButton - 1
		if self.selectedButton < 0 then
			self.selectedButton = tableSize(self.buttons)
		end
		if self.selectedButton > 0 and not self.buttons[self.selectedButton].func then
			if not attempts then attempts = 0 end
			if attempts < tableSize(self.buttons) then
				self:selectPrevButton(attempts+1)
			else
				return false
			end
		end
		if attempts and self.selectedButton == 0 then
			return false
		end
		return true
	end
	
	function m:activateSelectedButton ()
		if self.selectedButton > 0 and self.selectedButton <= tableSize(self.buttons) then
			local b = self.buttons[self.selectedButton]
			if b.func and not self.fading then
				if game.soundOn then
					buttonSound:setPitch(1*randomRealBetween(.99, 1.01))
					buttonSound:play()
				end
				b:func()
			end
		end
		self.selectedButton = 0
	end
	
	function m:update ()
		if self.hotspot then
			self.hotspot.fading = self.fading
			self.hotspot:update()
		end
		
		self:updatePosition()
		if self.fading then
			if self.fadeOnClick then
				self.opacity = self.opacity * .997
			else
				self.opacity = self.opacity * .95
			end
			if self.opacity < .01 then
				return true
			end
		end
	end
	
	function m:draw ()
		if self.hotspot then self.hotspot:draw() end
		
		local y = self.menuY
		love.graphics.setColor(0,0,0, 127*self.opacity)
		love.graphics.rectangle('fill', 0, y, love.graphics.getWidth(), self.menuHeight)
		
		y = y + self.lineHeight/2
		love.graphics.setFont(fontMessage)
		love.graphics.setColor(255,255,255, 255*self.opacity)
		love.graphics.printf(self.text, 100, y, love.graphics.getWidth()-200, 'left')
		
		y = y + self.lineHeight*self:countLines()
		for i, b in pairs(self.buttons) do
			if b.align then
				love.graphics.setFont(fontMessageSmallest)
			else
				love.graphics.setFont(fontMessageSmall)
			end
			
			local hover = b.func and not self.fading and love.mouse.getY() > y and love.mouse.getY() < y + FONT_SIZE
			if hover and b.align then
				hover = false
				if b.align == 'left' then
					hover = love.mouse.getX() < love.graphics.getWidth()*.33
				elseif b.align == 'center' then
					hover = love.mouse.getX() > love.graphics.getWidth()*.33 and love.mouse.getX() < love.graphics.getWidth()*.66
				elseif b.align == 'right' then
					hover = love.mouse.getX() > love.graphics.getWidth()*.66
				end
			end
			if hover then
				self.selectedButton = 0
			end
			if hover or (self.selectedButton == i and not self.fading) then
				love.graphics.setColor(0, 170, 250, 255*self.opacity)
			else
				love.graphics.setColor(255,255,255, 255*self.opacity)
			end
			
			love.graphics.printf(b.text, 100, y, love.graphics.getWidth()-200, b.align)
			if not b.align then y = y + self.lineHeight end
		end
	end
	
	function m:updatePosition ()
		local numButtons = 0
		for _, b in pairs(self.buttons) do
			if not b.align then
				numButtons = numButtons + 1
			elseif b.align == 'right' then
				numButtons = numButtons + 0.5
			end
		end
		self.menuHeight = (numButtons+self:countLines()+1) * self.lineHeight
		self.menuY = love.graphics.getHeight() - self.menuHeight
	end
	
	function m:addButton (text, func, align)
		table.insert(self.buttons, {text=text, func=func, align=align})
	end
	
	function m:press (x, y)
		if self.hotspot and collidePointCircle(newVector(x,y), self.hotspot.positionFunction(), self.hotspot.r*1.5) then
			self.hotspot:press(x, y)
		end

		local buttonY = self.menuY + self.lineHeight/2 + self.lineHeight*self:countLines()
		for _, b in pairs(self.buttons) do
			b.pressed = b.func and not self.fading and y > buttonY and y < buttonY + FONT_SIZE
			if b.pressed and b.align then
				b.pressed = false
				if b.align == 'left' then
					b.pressed = x < love.graphics.getWidth()*.33
				elseif b.align == 'center' then
					b.pressed = x > love.graphics.getWidth()*.33 and x < love.graphics.getWidth()*.66
				elseif b.align == 'right' then
					b.pressed = x > love.graphics.getWidth()*.66
				end
			end
			if b.pressed and game.soundOn then
				buttonSound:setPitch(1*randomRealBetween(.99, 1.01))
				buttonSound:play()
			end
			if not b.align then buttonY = buttonY + self.lineHeight end
		end
	end
	
	function m:release (x, y)
		local buttonY = self.menuY + self.lineHeight/2 + self.lineHeight*self:countLines()
		for _, b in pairs(self.buttons) do
			local hover = b.func and not self.fading and y > buttonY and y < buttonY + FONT_SIZE
			if hover and b.align then
				hover = false
				if b.align == 'left' then
					hover = x < love.graphics.getWidth()*.33
				elseif b.align == 'center' then
					hover = x > love.graphics.getWidth()*.33 and x < love.graphics.getWidth()*.66
				elseif b.align == 'right' then
					hover = x > love.graphics.getWidth()*.66
				end
			end
			if b.pressed and hover then
				b:func()
			end
			if not b.align then buttonY = buttonY + self.lineHeight end
		end
		
		if self.hotspot and self.hotspot.pressed then self.hotspot:release(x,y) end
		
		if self.fadeOnClick then
			self.fading = true
			if self.hotspot then self.hotspot.fading = true end
		end
	end
	
	function m:countLines()
		return math.min(8, 1+select(2, self.text:gsub('\n', '\n')))
	end

	m:updatePosition()
	
	return m
end

function newHotSpot (positionFunction)
	local h = {}
	h.type = 'hotspot'
	h.positionFunction = positionFunction
	h.r = 30
	h.expand = 0
	h.pressed = false
	h.opacity = 1
	h.fading = false
	
	function h:update ()
		if self.fading then
			self.opacity = self.opacity * .9
			if self.opacity <= 0.1 then
				return true
			end
		end
		self.expand = self.expand + TAU/60
		if self.expand > TAU then self.expand = 0 end
	end
	
	function h:draw ()
		love.graphics.setColor(255,255,255,self.opacity*127)
		local pos, newR = self.positionFunction()
		local r = newR or self.r
		if self.pressed then
			r = r*1.5
		else
			r = r + r*(1+math.sin(self.expand))*.1
		end
		drawFilledCircle(pos.x, pos.y, r)
	end
	
	function h:press (x, y)
		self.pressed = true
		if game.soundOn then
			buttonSound:setPitch(1*randomRealBetween(.9, 1.1))
			buttonSound:play()
		end
	end
	
	function h:release (x, y)
		self.pressed = false
	end
	
	return h
end

function newSlider (stat, order)
	local s = {}
	
	s.type = 'slider'
	s.order = order
	s.pos = newVector(0,0)
	s.stat = stat
	s.actArea = {x=0, y=0, width=45, height=15}
	s.pressed = false
	s.sliderWidth = 0
	
	function s:update ()
		self.pos.y = self.order * math.max(love.graphics.getHeight()*.05, 20)
		local maxWidth = love.graphics.getWidth() - self.actArea.width*1.5
		
		if self.pressed then
			local adjTouchX = love.mouse.getX() - self.actArea.width/2
			local newX = math.max(math.min(adjTouchX, maxWidth), 0)
			local newGeneStat = newX/maxWidth
			game.human.colony[stat] = newGeneStat
			game.human.colony:adjustGenes()
			if self.stat == 'spawn' then
				game.flags.increaseSpawn = true
			elseif self.stat == 'attack' then
				game.flags.increaseAttack = true
			elseif self.stat == 'travel' then
				game.flags.increaseTravel = true
			end
		end
		
		self.sliderWidth = game.human.colony[stat] * maxWidth
		self.actArea.x = self.pos.x + self.sliderWidth
		self.actArea.y = self.pos.y - self.actArea.height/2
	end
	
	function s:draw ()
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 255, 255, 127)
		love.graphics.line(self.pos.x, self.pos.y, love.graphics.getWidth(), self.pos.y)

		love.graphics.setColor(0, 170, 250)
		love.graphics.setFont(font)
		love.graphics.print(strings[self.stat], 3, self.pos.y-18)
		
		if self.pressed then
			love.graphics.setLineWidth(3)
		else
			love.graphics.setLineWidth(2)
		end
		love.graphics.setColor(0, 0, 0, 50)
		love.graphics.line(self.pos.x, self.pos.y+2, self.pos.x + self.sliderWidth, self.pos.y)
		love.graphics.setColor(0, 170, 250)
		love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.sliderWidth, self.pos.y)
		
		if self.pressed then
			love.graphics.setColor(0, 0, 0, 50)
			love.graphics.rectangle('fill', self.actArea.x+2, self.actArea.y+2, self.actArea.width, self.actArea.height)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', self.actArea.x-1, self.actArea.y-1, self.actArea.width+2, self.actArea.height+2)
			love.graphics.setColor(0, 0, 0, 10)
			love.graphics.rectangle('fill', self.actArea.x+2, self.actArea.y+2, self.actArea.width-4, self.actArea.height-4)
		else
			love.graphics.setColor(0, 0, 0, 50)
			love.graphics.rectangle('fill', self.actArea.x+2, self.actArea.y+2, self.actArea.width, self.actArea.height)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', self.actArea.x, self.actArea.y, self.actArea.width, self.actArea.height)
		end
	end
	
	function s:press (x, y)
		self.pressed = true
		if game.soundOn then
			buttonSound:setPitch(1*randomRealBetween(.99, 1.01))
			buttonSound:play()
		end
	end
	
	function s:release (x, y)
		if self.pressed then
			self.pressed = false
			return true
		end
	end
	
	function s:getCenter ()
		local x = self.actArea.x + self.actArea.width/2
		local y = self.actArea.y + self.actArea.height/2
		return newVector(x,y)
	end
	
	return s
end
	