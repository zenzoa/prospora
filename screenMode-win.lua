winMode = newScreenMode(strings.winHeader)
	
function winMode:load ()
	self:resetObjects()
	self:addObject(newLabel(strings.winMessage))
	self:addObject(newSpacer())
	self:addObject(newMenuReturn())
	
	resetMusic()
	winMusic:rewind()
	if soundOn then winMusic:play() end
end