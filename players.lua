function newPlayer ()
	local p = {}
	
	p.colony = newColony()
	p.colony.color = { r=50, g=186, b=250 }
	p.selectedPlanet = nil
	p.homeWorld = nil
	p.homeUnderAttack = false
	
	return p
	
end