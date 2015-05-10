function initTutorialWorld ()
	local enemy1 = newColony()
	enemy1.attack = 3
	enemy1.spawn = 1
	enemy1.travel = 1
	enemy1:adjustGenes()
	
	local enemy2 = newColony()
	enemy2.attack = 1
	enemy2.spawn = 3
	enemy2.travel = 1
	enemy2:adjustGenes()
	
	local enemy3 = newColony()
	enemy3.attack = 1
	enemy3.spawn = 1
	enemy3.travel = 3
	enemy3:adjustGenes()
	
	--
	
	local maxOrbit = 50*7
	local centerOfTheUniverse = newVector(game.world_size.width/2, game.world_size.height/2)
	local r = math.min(game.world_size.width, game.world_size.height)/3
	local v = vMul(newVector(math.cos(PI/6), math.sin(PI/6)), r)
	local location1 = newVector(centerOfTheUniverse.x, centerOfTheUniverse.y-r)
	local location2 = newVector(centerOfTheUniverse.x + v.x, centerOfTheUniverse.y + v.y)
	local location3 = newVector(centerOfTheUniverse.x - v.x, centerOfTheUniverse.y + v.y)
	
	local sun0 = newSun(centerOfTheUniverse, math.random(20, 50))
	local sun1 = newSun(location1, math.random(20, 50))
	local sun2 = newSun(location2, math.random(20, 50))
	local sun3 = newSun(location3, math.random(20, 50))
	
	suns = {sun0, sun1, sun2, sun3}
	
	--
	
	local createHomeWorld = function (sun, colony)
		local planet = newPlanet(sun)
		planet.isHomeWorld = true
		planet.startingColony = colony
		planet.maxSpores = 6
		return planet
	end
	
	planets = {}
	planetConnections = {}
	
	local humanHomeWorld = createHomeWorld(sun0, game.human.colony)
	humanHomeWorld.orbitVelocity = PI/100
	game.human.homeWorld = humanHomeWorld
	game.human.selectedPlanet = humanHomeWorld
	table.insert(planets, humanHomeWorld)
	
	local p1 = newPlanet(sun0)
	p1.maxSpores = 12
	p1.orbitVelocity = PI/50
	table.insert(planets, p1)
	local p2 = newPlanet(sun0)
	p2.maxSpores = 10
	p2.orbitVelocity = PI/60
	table.insert(planets, p2)
	
	table.insert(planets, createHomeWorld(sun1, enemy1))
	table.insert(planets, newPlanet(sun1))
	
	table.insert(planets, createHomeWorld(sun2, enemy2))
	table.insert(planets, newPlanet(sun2))
	
	table.insert(planets, createHomeWorld(sun3, enemy3))
	table.insert(planets, newPlanet(sun3))
	
	for _, planet in pairs(planets) do
		planet:initSpores()
	end
	
end

function createTutorialMessages()
	local m = game.interface:createMessages()
	
	--
	
	m.selectHomeWorld = newMessage('selectHomeWorld', strings.thisIsHome)
	m.selectHomeWorld:addButton(strings.clickToSelect)
	local skipTutorialButton = function (self)
			game.tutorial = false
			game:load()
		end
	m.selectHomeWorld:addButton('> ' .. strings.skipTutorial, skipTutorialButton)
	local homePosFunc = function()
			return unAdjustPos(game.human.homeWorld.location.x, game.human.homeWorld.location.y), game.human.homeWorld.radius*2.5
		end
	m.selectHomeWorld.hotspot = newHotSpot(homePosFunc)
	
	--
	
	m.makeConnection = newMessage('makeConnection', strings.theseAreSpores)
	m.makeConnection:addButton(strings.launchSpore)
	local sporePosFunc = function()
			local spore = game.human.homeWorld.spores[1]
			local sporePos = game.human.homeWorld:getSporeLocation(spore)
			return unAdjustPos(sporePos.x, sporePos.y), UNIT_RADIUS*3
		end
	m.makeConnection.hotspot = newHotSpot(sporePosFunc)
	
	--
	
	m.increaseSpawn = newMessage('increaseSpawn', strings.needMoreSpores)
	m.increaseSpawn:addButton(strings.increaseSpawn)
	local spawnBarFunc = function() return game.interface.spawnSlider:getCenter() end
	m.increaseSpawn.hotspot = newHotSpot(spawnBarFunc)
	
	--
	
	m.increaseTravel = newMessage('increaseTravel', strings.acrossConnections)
	m.increaseTravel:addButton(strings.increaseTravel)
	local travelBarFunc = function() return game.interface.travelSlider:getCenter() end
	m.increaseTravel.hotspot = newHotSpot(travelBarFunc)
	
	--
	
	m.increaseAttack = newMessage('increaseAttack', strings.underAttack)
	m.increaseAttack:addButton(strings.increaseAttack)
	local attackBarFunc = function() return game.interface.attackSlider:getCenter() end
	m.increaseAttack.hotspot = newHotSpot(attackBarFunc)
	
	--
	
	m.shiftView = newMessage('shiftView', strings.timeToExplore)
	m.shiftView:addButton(strings.dragToMove)
	
	--
	
	m.enemyHomeInView = newMessage('enemyHomeInView', strings.discoveredEnemyHome)
	m.enemyHomeInView:addButton(strings.destroyEnemies)
	m.enemyHomeInView.fadeOnClick = true
	
	--
	
	m.pause = newMessage('pause', strings.timeToPause)
	m.pause:addButton(strings.howToPause)
	
	--
	
	return m
end