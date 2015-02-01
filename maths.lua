PI = math.pi
TAU = math.pi * 2

--

function collidePointCircle (vector, centerPoint, radius)
	local d = vMag({x = centerPoint.x - vector.x, y = centerPoint.y - vector.y})
	if d < radius then
		return true
	end
end

function collideCircles (centerA, radiusA, centerB, radiusB)
	return (centerB.x - centerA.x)^2 + (centerB.y - centerA.y)^2 < (radiusA + radiusB)^2
end

--

function randomRealBetween(lowerBound, upperBound)
	local n = math.random()
	local range = upperBound - lowerBound
	n = n * range
	n = n + lowerBound
	return n
end

function randomIntegerBetween(lowerBound, upperBound)
	return math.random(lowerBound, upperBound)
end

--

function randomElement(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
	 keys[i] = k
	 i = i + 1
	end
	local m = randomIntegerBetween(1, #keys)
	return t[ keys[m] ]
end

function tableSize(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

--

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