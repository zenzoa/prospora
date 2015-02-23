function newScreenMode ()
	mode = {}
	mode.buttons = {}
	
	function mode:load ()
		--
	end

	function mode:update ()
		--
	end

	function mode:draw ()
		self:drawButtons()
	end
	
	function mode:drawButtons ()
		for _, b in pairs(self.buttons) do
			b:draw()
		end
	end

	function mode:mousepressed(x, y)
		checkButtons(self.buttons, x, y)
	end
	
	return mode
	
end


function switchToMode(mode)
	screenMode = mode
	screenMode:load()
end


function newButton (text, x, y, action)
	b = {}
	b.text = text
	b.x = x
	b.y = y
	b.action = action
	b.load = true
	
	function b:draw ()
		local y = love.mouse.getY()
		if y >= self.y - 10 and y <= self.y + 35 then
			love.graphics.setColor(0, 170, 250, 150)
			love.graphics.rectangle('fill', 0, self.y-10, love.graphics.getWidth(), 45)
		end
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(self.text, self.x, self.y)
	end
	
	function b:activate ()
		self.action()
	end
	
	return b
end

function checkButtons (buttons, x, y)
	for _, b in pairs(buttons) do
		if y >= b.y - 10 and y <= b.y + 35 then
			buttonSound:rewind()
			if soundOn then buttonSound:play() end
			b:activate()
		end
	end
end

function newSoundToggle (x, y)
	b = newButton ('', x, y, nil)
	
	if soundOn then
		b.text = strings.soundsOn
	else
		b.text = strings.soundsOff
	end
	
	function b:activate ()
		soundOn = not soundOn
		if soundOn then
			self.text = strings.soundsOn
			love.audio.resume()
		else
			self.text = strings.soundsOff
			love.audio.pause()
		end
	end
	
	return b
end

function newGameSizeToggle (x, y)
	b = newButton ('', x, y, nil)
	
	if UNIVERSE_SIZE == 20 then
		b.text = strings.universeLarge
	elseif UNIVERSE_SIZE == 5 then
		b.text = strings.universeSmall
	else
		b.text = strings.universeMedium
	end
	
	function b:activate ()
		if UNIVERSE_SIZE == 10 then
			UNIVERSE_SIZE = 20
			self.text = strings.universeLarge
		elseif UNIVERSE_SIZE == 20 then
			UNIVERSE_SIZE = 5
			self.text = strings.universeSmall
		else
			UNIVERSE_SIZE = 10
			self.text = strings.universeMedium
		end
	end
	
	return b
end

function newFullscreenToggle (x, y)
	b = newButton ('', x, y, nil)
	
	if love.window.getFullscreen() then
		b.text = strings.fullscreenOn
	else
		b.text = strings.fullscreenOff
	end
	
	function b:activate ()
		local isFullscreen = not love.window.getFullscreen()
		love.window.setFullscreen(isFullscreen)
		if isFullscreen then
			self.text = strings.fullscreenOn
			love.window.setFullscreen(true)
		else
			self.text = strings.fullscreenOff
			love.window.setFullscreen(false)
		end
	end
	
	return b
end
