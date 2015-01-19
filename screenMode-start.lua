startMode = newScreenMode()

function startMode:load ()
	self.buttons = {
		newButton('new game', 100, 200, function () switchToMode(gameMode) end),
		newButton('how to play', 100, 300, function () switchToMode(tutorialMode) end),
		newButton('options', 100, 350, function () switchToMode(optionsMode) end),
		newButton('credits', 100, 400, function () switchToMode(creditsMode) end),
		newButton('quit', 100, 500, love.event.quit)
	}
	resetMusic()
end

function startMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('PROSPORA', 100, 100)
	love.graphics.setFont(font)
	self:drawButtons()
end