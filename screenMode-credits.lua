creditsMode = newScreenMode()

function creditsMode:load ()
	self.buttons = {
		newButton('main menu', 100, 500, function () switchToMode(startMode) end)
	}
end

function creditsMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('CREDITS', 100, 100)
	
	love.graphics.setColor(200, 200, 200)
	love.graphics.setFont(font)
	
	love.graphics.print('Sarah Gould', 100, 190)
	love.graphics.print('www.zenzoa.com', 100, 220)

	love.graphics.print('music from freemusicarchive.org:', 100, 270)
	love.graphics.print('circuit & unit731 by alg0rh1tm', 100, 300)
	
	love.graphics.print('sounds from freesound.org:', 100, 350)
	love.graphics.print('btn402 by junggle', 100, 380)
	love.graphics.print('(all others public domain)', 100, 410)
	
	self:drawButtons()
end