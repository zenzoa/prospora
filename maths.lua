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
	return table.getn(t)
end

function appendToTable(t1, t2)
	for _,v in pairs(t2) do
		table.insert(t1, v)
	end
	return t1
end