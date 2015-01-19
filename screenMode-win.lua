winMode = newScreenMode()

function winMode:load ()
	self.buttons = {
		newButton('main menu', 100, 500, function () switchToMode(startMode) end)
	}
	resetMusic()
	if soundOn then winMusic:play() end
end

function winMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('WIN', 100, 200)

	love.graphics.setColor(200, 200, 200)
	love.graphics.setFont(font)
	love.graphics.print('a tiny universe, conquered', 100, 250)
	
	self:drawButtons()
end