loseMode = newScreenMode()

function loseMode:load ()
	self.buttons = {
		newButton('main menu', 100, 500, function () switchToMode(startMode) end)
	}
	resetMusic()
	if soundOn then loseMusic:play() end
end

function loseMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('LOSE', 100, 200)

	love.graphics.setColor(200, 200, 200)
	love.graphics.setFont(font)
	love.graphics.print('you have been eradicated', 100, 250)
	
	self:drawButtons()
end