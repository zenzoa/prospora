optionsMode = newScreenMode()

function optionsMode:load ()
	self.buttons = {
		newSoundToggle(100, 200),
		newGameSizeToggle(100, 250),
		newFullscreenToggle(100, 300),
		newButton(strings.mainMenu, 100, 500, function () switchToMode(startMode) end)
	}
end

function optionsMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print(strings.optionsHeader, 100, 100)
	love.graphics.setFont(font)
	self:drawButtons()
end