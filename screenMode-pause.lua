pauseMode = newScreenMode(strings.pauseHeader)

function pauseMode:load ()
	self:resetObjects()
	self:addObject(newButton(strings.resume, function () screenMode = gameMode end))
	self:addObject(newSpacer())
	self:addObject(newSoundToggle())
	self:addObject(newFullscreenToggle())
	self:addObject(newAdvancedControlsToggle())
	self:addObject(newSpacer())
	self:addObject(newMenuReturn())
end