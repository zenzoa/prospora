pauseMode = newScreenMode()

function pauseMode:load ()
	self.buttons = {
		newButton('resume', 100, 200, function () screenMode = gameMode end),
		newSoundToggle(100, 250),
		newButton('quit to menu', 100, 500, function () switchToMode(startMode) end)
	}
end

function pauseMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('PAUSED', 100, 100)
	love.graphics.setFont(font)
	self:drawButtons()
end