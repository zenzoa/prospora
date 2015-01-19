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
		b.text = 'sound: on'
	else
		b.text = 'sound: off'
	end
	
	function b:activate ()
		soundOn = not soundOn
		if soundOn then
			self.text = 'sound: on'
			love.audio.resume()
		else
			self.text = 'sound: off'
			love.audio.pause()
		end
	end
	
	return b
end

function newGameSizeToggle (x, y)
	b = newButton ('', x, y, nil)
	
	if UNIVERSE_SIZE == 20 then
		b.text = 'universe: large'
	elseif UNIVERSE_SIZE == 5 then
		b.text = 'universe: small'
	else
		b.text = 'universe: medium'
	end
	
	function b:activate ()
		if UNIVERSE_SIZE == 10 then
			UNIVERSE_SIZE = 20
			self.text = 'universe: large'
		elseif UNIVERSE_SIZE == 20 then
			UNIVERSE_SIZE = 5
			self.text = 'universe: small'
		else
			UNIVERSE_SIZE = 10
			self.text = 'universe: medium'
		end
	end
	
	return b
end
