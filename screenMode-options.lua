optionsMode = newScreenMode(strings.optionsHeader)

function optionsMode:load ()
	self:resetObjects()
	self:addObject(newSoundToggle())
	self:addObject(newFullscreenToggle())
	self:addObject(newAdvancedControlsToggle())
	--self:addObject(newGameSizeToggle())
	self:addObject(newSpacer())
	self:addObject(newMenuReturn())
end