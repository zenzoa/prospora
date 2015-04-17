function newVector (x, y)
	return { x=x, y=y }
end

function vAdd (vectorA, vectorB)
	return { x = vectorA.x + vectorB.x, y = vectorA.y + vectorB.y }
end

function vSub (vectorA, vectorB)
	return { x = vectorA.x - vectorB.x, y = vectorA.y - vectorB.y }
end

function vMul (vector, scalar)
	return { x = vector.x * scalar, y = vector.y * scalar }
end

function vDiv (vector, scalar)
	return { x = vector.x / scalar, y = vector.y / scalar }
end

function vMag (vector)
	return math.sqrt(vector.x^2 + vector.y^2)
end

function vAng (vector)
	return math.atan2(vector.y, vector.x)
end

function vNormalize (vector)
	local mag = math.abs(vMag(vector))
	return { x = vector.x / mag, y = vector.y / mag }
end

function randomVector ()
	local angle = randomRealBetween(0, TAU)
	return newVector(math.cos(angle), math.sin(angle))
end

function crossProduct (vectorA, vectorB)
	
end

function dotProduct (vectorA, vectorB)
	return vectorA.x*vectorB.x + vectorA.y*vectorB.y
end