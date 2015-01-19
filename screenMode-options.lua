optionsMode = newScreenMode()

function optionsMode:load ()
	self.buttons = {
		newSoundToggle(100, 200),
		newGameSizeToggle(100, 250),
		newButton('main menu', 100, 500, function () switchToMode(startMode) end)
	}
end

function optionsMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('OPTIONS', 100, 100)
	love.graphics.setFont(font)
	self:drawButtons()
end