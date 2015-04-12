loseMode = newScreenMode(strings.loseHeader)

function loseMode:load ()
	self:resetObjects()
	self:addObject(newLabel(strings.loseMessage))
	self:addObject(newSpacer())
	self:addObject(newMenuReturn())
	
	resetMusic()
	if soundOn then loseSound:play() end
end