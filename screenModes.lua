LINEHEIGHT = 50

function newScreenMode (title)
	mode = {}
	mode.screenObjects = {}
	mode.title = title
	mode.mouseHeldFor = nil
	
	function mode:load ()
		--
	end

	function mode:update ()
		--
	end
	
	function mode:resetObjects ()
		self.screenObjects = {}
	end
	
	function mode:addObject (o)
		table.insert(self.screenObjects, o)
	end

	function mode:draw ()
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(fontLarge)
		love.graphics.printf(self.title, 0, LINEHEIGHT*2, love.window.getWidth(), 'center')
		
		local y = LINEHEIGHT*4
		love.graphics.setFont(font)
		for _, o in pairs(self.screenObjects) do
			o:draw(y, self.mouseHeldFor==o)
			y = y + LINEHEIGHT
		end
	end
	
	function mode:mousepressed(x, y)
		local lineClicked = y/LINEHEIGHT + 4
		local ypos = LINEHEIGHT*4
		for i, b in pairs(self.screenObjects) do
			if b.type == 'button' and y > ypos-10 and y < ypos+LINEHEIGHT-10 then
				self.mouseHeldFor = b
				if soundOn then buttonSound:play() end
			end
			ypos = ypos + LINEHEIGHT
		end
	end

	function mode:mousereleased(x, y)
		local lineClicked = y/LINEHEIGHT + 4
		local ypos = LINEHEIGHT*4
		for i, b in pairs(self.screenObjects) do
			if self.mouseHeldFor == b and y > ypos-10 and y < ypos+LINEHEIGHT-10 then
				b:activate()
			end
			ypos = ypos + LINEHEIGHT
		end
		self.mouseHeldFor = nil
	end
	
	return mode
	
end

function switchToMode(mode)
	screenMode = mode
	screenMode:load()
end

function newLabel (text)
	l = {}
	l.text = text
	l.type = 'label'
	
	function l:draw (y)
		love.graphics.setColor(200, 200, 200)
		love.graphics.printf(self.text, 0, y, love.window.getWidth(), 'center')
	end
	
	return l
end

function newButton (text, action)
	b = {}
	b.text = text
	b.action = action
	b.type = 'button'
	
	function b:draw (y, mouseHeld)
		if mouseHeld and love.mouse.getY() > y-10 and love.mouse.getY() < y+LINEHEIGHT-10 then
			y = y + 2
			love.graphics.setColor(0, 170, 250)
		else
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.printf(self.text, 0, y, love.window.getWidth(), 'center')
	end
	
	function b:activate ()
		self:action()
	end
	
	return b
end

function newSpacer ()
	s = {}
	s.type = 'spacer'
	
	function s:draw (y)
		--
	end
	
	return s
end

---

function newLink (linkText, mode)
	return newButton (linkText, function () switchToMode(mode) end)
end

function newMenuReturn ()
	return newLink (strings.mainMenu, startMode)
end

function newSoundToggle ()
	local toggleText = function ()
		if soundOn then
			return strings.soundsOn
		else
			return strings.soundsOff
		end
	end
	
	local action = function(self)
		soundOn = not soundOn
		if soundOn then
			love.audio.resume()
		else
			love.audio.pause()
		end
		self.text = toggleText()
	end
	
	return newButton (toggleText(), action)
end

function newGameSizeToggle ()
	local toggleText = function ()
		if UNIVERSE_SIZE == 20 then
			return strings.universeLarge
		elseif UNIVERSE_SIZE == 5 then
			return strings.universeSmall
		else
			return strings.universeMedium
		end
	end
	
	local action = function(self)
		if UNIVERSE_SIZE == 10 then
			UNIVERSE_SIZE = 20
		elseif UNIVERSE_SIZE == 20 then
			UNIVERSE_SIZE = 5
		else
			UNIVERSE_SIZE = 10
		end
		self.text = toggleText()
	end
	
	return newButton (toggleText(), action)
end

function newFullscreenToggle ()
	local toggleText = function ()
		if love.window.getFullscreen() then
			return strings.fullscreenOn
		else
			return strings.fullscreenOff
		end
	end
	
	local action = function(self)
		local isFullscreen = not love.window.getFullscreen()
		love.window.setFullscreen(isFullscreen)
		self.text = toggleText()
	end
	
	return newButton (toggleText(), action)
end

function newAdvancedControlsToggle ()
	local toggleText = function ()
		if advancedControls then
			return strings.advancedControlsOn
		else
			return strings.advancedControlsOff
		end
	end
	
	local action = function(self)
		advancedControls = not advancedControls
		self.text = toggleText()
	end
	
	return newButton (toggleText(), action)
end