tutorialMode = newScreenMode()

function tutorialMode:load ()
	self.buttons = {}
	self.tutorialImage = tutorialImage1
end

function tutorialMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('HOW TO PLAY', 100, 100)
	love.graphics.setFont(font)
	
	love.graphics.draw(self.tutorialImage, 100, 150)
	
	self:drawButtons()
end

function tutorialMode:mousepressed(x, y)
	checkButtons(self.buttons, x, y)
	if self.tutorialImage == tutorialImage1 then
		self.tutorialImage = tutorialImage2
	elseif self.tutorialImage == tutorialImage2 then
		self.tutorialImage = tutorialImage3
	elseif self.tutorialImage == tutorialImage3 then
		self.tutorialImage = tutorialImage4
	elseif self.tutorialImage == tutorialImage4 then
		self.tutorialImage = tutorialImage5
	elseif self.tutorialImage == tutorialImage5 then
		self.tutorialImage = tutorialImage6
	elseif self.tutorialImage == tutorialImage6 then
		self.tutorialImage = tutorialImage7
	elseif self.tutorialImage == tutorialImage7 then
		switchToMode(startMode)
	end
end