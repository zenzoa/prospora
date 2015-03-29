creditsMode = newScreenMode(strings.creditsHeader)

function creditsMode:load ()
	self:resetObjects()
	self:addObject(newLabel('Sarah Gould'))
	self:addObject(newLabel('zenzoa.com'))
	self:addObject(newSpacer())
	self:addObject(newLabel(strings.music))
	self:addObject(newLabel('circuit & unit731 / alg0rh1tm'))
	self:addObject(newLabel('freemusicarchive.org'))
	self:addObject(newSpacer())
	self:addObject(newMenuReturn())
end