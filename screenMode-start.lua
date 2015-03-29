startMode = newScreenMode('Prospora')

function startMode:load ()
	self:resetObjects()
	self:addObject(newLink(strings.newGame, gameMode))
	self:addObject(newLink(strings.tutorialHeader, tutorialMode))
	self:addObject(newLink(strings.optionsHeader, optionsMode))
	self:addObject(newLink(strings.creditsHeader, creditsMode))
	self:addObject(newSpacer())
	self:addObject(newButton(strings.quit, love.event.quit))
	resetMusic()
end