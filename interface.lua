--[[

Later opens (start up previous game - could be tutorial! - if there is one, or new game if there isn't, paused)
or Paused:
Prospora
- return to game
- turn sound on/off
- about
(make sure these are separated from the main menu options to prevent easy exiting, maybe smaller along bottom of screen)
- new game
- new tutorial
- quit

]]--

function newInterface ()
	local i = {}
	
	i.attackSlider = newSlider('attack', 1)
	i.spawnSlider = newSlider('spawn', 2)
	i.travelSlider = newSlider('travel', 3)
	i.sliders = {i.attackSlider, i.spawnSlider, i.travelSlider}
	
	i.messages = {}
	i.allMessages = {}
	
	i.titleOpacity = .8
	
	function i:update ()
		if self.titleOpacity > 0 then
			self.titleOpacity = self.titleOpacity - 0.003
		end

		for _, s in pairs(self.sliders) do
			s:update()
		end
	
		for i, m in pairs(self.messages) do
			if m:update() then
				table.remove(self.messages, i)
			end
		end
		
		if TUTORIAL then self:checkFlags() end
	end
	
	function i:draw ()
		for _, s in pairs(self.sliders) do
			s:draw()
		end
	
		for _, m in pairs(self.messages) do
			m:draw()
		end
		
		love.graphics.setColor(0,0,0, 255*self.titleOpacity)
		love.graphics.rectangle('fill', 0,0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255, 255*self.titleOpacity)
		love.graphics.setFont(fontTitle)
		love.graphics.printf(strings.prospora, 0, love.graphics.getHeight()/2-FONT_SIZE*4, love.graphics.getWidth(), 'center')
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
	
	function i:addMessage(newMessage)
		for _, m in pairs(self.messages) do
			m.fading = true
			if m.hotspot then m.hotspot.fading = true end
		end
		table.insert(self.messages, 1, newMessage)
	end
	
	function i:newGame ()
		self.messages = {}
	end
	
	function i:newTutorial ()
		
		self.messages = {}
		self.allMessages = createTutorialMessages()
		self:addMessage(self.allMessages.selectHomeWorld)
		
	end
	
	function i:checkFlags()
		if flags.selectHomeWorld then
			flags.allowLaunching = true
			if self.messages[1] and self.messages[1].flag == 'selectHomeWorld' then
				self:addMessage(self.allMessages.makeConnection)
			elseif flags.makeConnection then
				if self.messages[1] and self.messages[1].flag == 'makeConnection' then
					self:addMessage(self.allMessages.increaseTravel)
					flags.increaseTravel = false
				elseif flags.increaseTravel then
					if self.messages[1] and self.messages[1].flag == 'increaseTravel' then
						self:addMessage(self.allMessages.shiftView)
					elseif flags.shiftView then
						if self.messages[1] and self.messages[1].flag == 'shiftView' then
							self.messages[1].fading = true
						elseif flags.enemyHomeInView then
							flags.allowEnemyConnections = true
							if not self.allMessages.enemyHomeInView.alreadyShown then
								self:addMessage(self.allMessages.enemyHomeInView)
								self.allMessages.enemyHomeInView.alreadyShown = true
							end
							if flags.underAttack then
								if not self.allMessages.increaseAttack.alreadyShown then
									self:addMessage(self.allMessages.increaseAttack)
									self.allMessages.increaseAttack.alreadyShown = true
									flags.increaseAttack = false
								end
								if flags.increaseAttack then
									if self.messages[1] and self.messages[1].flag == 'increaseAttack' then
										self:addMessage(self.allMessages.pause)
									end
								end
							end
						end
					end
				end
			end
			if flags.oneSporeLeft then
				if not self.messages[1] and not self.allMessages.increaseSpawn.alreadyShown then
					self:addMessage(self.allMessages.increaseSpawn)
					self.allMessages.increaseSpawn.alreadyShown = true
					flags.increaseSpawn = false
				end
				if flags.increaseSpawn then
					if self.messages[1] and self.messages[1].flag == 'increaseSpawn' then
						self.messages[1].fading = true
					end
				end
			end
		end
		if flags.win then
		elseif flags.lose then
		end
	end
	
	return i
end

function newMessage (flag, text)
	local m = {}
	m.flag = flag
	
	m.pressed = false
	m.pauseGame = false
	
	m.text = text
	m.buttons = {}
	m.hotspot = nil
	
	m.opacity = 1
	m.fading = false
	m.menuHeight = 0
	m.menuY = 0
	m.lineHeight = FONT_SIZE*2
	
	function m:update ()
		if self.hotspot then self.hotspot:update() end
		
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
		for _, b in pairs(self.buttons) do
			love.graphics.setFont(fontMessageSmall)
			if b.func and love.mouse.getY() > y and love.mouse.getY() < y + FONT_SIZE then
				love.graphics.setColor(0, 170, 250, 255*self.opacity)
			else
				love.graphics.setColor(255,255,255, 255*self.opacity)
			end
			love.graphics.printf(b.text, 100, y, love.graphics.getWidth()-200, 'left')
			y = y + self.lineHeight
		end
	end
	
	function m:updatePosition ()
		local numButtons = tableSize(self.buttons)
		self.menuHeight = (numButtons+self:countLines()+1) * self.lineHeight
		self.menuY = love.graphics.getHeight() - self.menuHeight
	end
	
	function m:addButton (text, func)
		table.insert(self.buttons, {text=text, func=func})
	end
	
	function m:press (x, y)
		if self.hotspot and collidePointCircle(newVector(x,y), self.hotspot.positionFunction(), self.hotspot.r*1.5) then
			self.hotspot:press(x, y)
		end

		local buttonY = self.menuY + self.lineHeight/2 + self.lineHeight*self:countLines()
		for _, b in pairs(self.buttons) do
			if y > buttonY and y < buttonY + FONT_SIZE then
				b.pressed = true
				if soundOn then
					buttonSound:setPitch(1*randomRealBetween(.99, 1.01))
					buttonSound:play()
				end
			end
			buttonY = buttonY + self.lineHeight
		end
	end
	
	function m:release (x, y)
		local buttonY = self.menuY + self.lineHeight/2 + self.lineHeight*self:countLines()
		for _, b in pairs(self.buttons) do
			if b.pressed and b.func and y > buttonY and y < buttonY + FONT_SIZE then
				b:func()
			end
			buttonY = buttonY + self.lineHeight
		end
		
		if self.hotspot and self.hotspot.pressed then self.hotspot:release(x,y) end
		
		if self.fadeOnClick then
			self.fading = true
			if self.hotspot then self.hotspot.fading = true end
		end
	end
	
	function m:countLines()
		return 1+select(2, self.text:gsub('\n', '\n'))
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
		if soundOn then
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
			human.colony[stat] = newGeneStat
			human.colony:adjustGenes()
			if self.stat == 'spawn' then
				flags.increaseSpawn = true
			elseif self.stat == 'attack' then
				flags.increaseAttack = true
			elseif self.stat == 'travel' then
				flags.increaseTravel = true
			end
		end
		
		self.sliderWidth = human.colony[stat] * maxWidth
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
		if soundOn then
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
	