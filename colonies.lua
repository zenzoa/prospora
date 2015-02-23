function newColony ()
	local c = {}
	
	c.attack = randomRealBetween(0,1)
	c.spawn = randomRealBetween(0,1)
	c.travel = randomRealBetween(0,1)
	
	c.color = randomColor()
	
	function c:adjustGenes ()
		local t = self.attack + self.spawn + self.travel
		self.attack = self.attack / t
		self.spawn = self.spawn / t
		self.travel = self.travel / t
	end
	
	c:adjustGenes()
	
	function c:setToMyColor (alpha)
		alpha = alpha or 255
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, alpha)
	end
	
	return c
end

function randomColor ()
	local hue = randomRealBetween(0,240)
	if hue>180 then hue=hue+120 end
	hue = hue*255/360
	local sat = randomRealBetween(100,255)
	local lit = randomRealBetween(100,200)
	
	local color = {}
	color.r, color.g, color.b = HSL(hue, sat, lit)
	return color
end

function HSL(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end
		return (r+m)*255, (g+m)*255, (b+m)*255, a
end