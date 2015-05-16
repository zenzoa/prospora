require("maths")
require("vectors")
require("strings")

require("stars")
require("suns")
require("colonies")
require("spores")
require("connections")
require("planets")
require("players")
require("deathRipples")

require("game")
require("interface")
require("tutorial")
local shine = require("shine")
require("dumper/dumper")

FANCY_GRAPHICS = true
FPS = 60
UNIT_RADIUS = 5
SEGMENTS = 60
FONT_SIZE = 20
TITLE_OPACITY = .8
LAUNCH_ANGLE = TAU*.75

function love.load()
	
	math.randomseed( os.time() )
	love.filesystem.setIdentity('prospora')
	love.keyboard.setKeyRepeat(true)
	
	-- setup window
	love.window.setTitle("Prospora")
	love.window.setMode(800, 600, {fullscreen=false, fullscreentype='desktop'})
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setLineStyle('smooth')
	love.graphics.setPointStyle('rough')
	
	-- setup fonts
	fontMessageSmallest = love.graphics.newFont('assets/furore.otf', FONT_SIZE*.6)
	fontMessageSmall = love.graphics.newFont('assets/furore.otf', FONT_SIZE*.8)
	fontMessage = love.graphics.newFont('assets/bender.otf', FONT_SIZE)
	font = love.graphics.newFont('assets/furore.otf', FONT_SIZE)
	fontLarge = love.graphics.newFont('assets/furore.otf', FONT_SIZE*2)
	fontTitle = love.graphics.newFont('assets/furore.otf', FONT_SIZE*5)
	love.graphics.setFont(font)
	
	-- setup audio
	gameMusic = love.audio.newSource('assets/alg0rh1tm-circuit.mp3', 'stream')
	gameMusic:setLooping(true)
	winMusic = love.audio.newSource('assets/broke_for_free-covered_in_oil.mp3', 'stream')
	winMusic:setLooping(true)
	loseSound = love.audio.newSource('assets/generdyn-brams01.wav', 'static')
	launchSound = love.audio.newSource('assets/fins-laser.wav', 'static')
	selectSound = love.audio.newSource('assets/nickgoa-plink.wav', 'static')
	selectSound:setVolume(0.5)
	buttonSound = love.audio.newSource('assets/junggle-btn402.mp3', 'static')
	buttonSound:setVolume(0.1)
	hitPlanetSound = love.audio.newSource('assets/reitanna-drop-metal-thing.wav', 'static')
	hitPlanetSound:setVolume(0.5)
	attackedSound = love.audio.newSource('assets/reitanna-defeated-sigh.wav', 'static')
	spawnSound = love.audio.newSource('assets/fins-creature.wav', 'static')
	homeWorldLossSound = love.audio.newSource('assets/generdyn-hits10.wav', 'static')
	
	-- setup cool vignette effect
	post_effect = setupFancyGraphics()
	
	-- load previous game or setup new game
	if not pcall(loadGame) then	
		game = newGame(true)
		game:load()
	end
end

timeSinceLastUpdate = 0

function love.update(dt)
	timeSinceLastUpdate = timeSinceLastUpdate + dt
	if (timeSinceLastUpdate >= 1/FPS) then
		game:update()
		
		if TITLE_OPACITY > 0 then
			TITLE_OPACITY = TITLE_OPACITY - 0.003
		end
		
		timeSinceLastUpdate = timeSinceLastUpdate - (1/FPS)
	end
end

function love.draw()
	game:draw()
	if TITLE_OPACITY > 0 then
		love.graphics.setColor(0,0,0, 255*TITLE_OPACITY)
		love.graphics.rectangle('fill', 0,0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255, 255*TITLE_OPACITY)
		love.graphics.setFont(fontTitle)
		love.graphics.printf(strings.prospora, 0, love.graphics.getHeight()/2-FONT_SIZE*4, love.graphics.getWidth(), 'center')
	end
end

function love.mousepressed(x, y, button)
	game:mousepressed(x, y)
end

function love.mousereleased(x, y, button)
	game:mousereleased(x, y)
end

function love.keyreleased(k)
	if (k == ' ' or k == 'return') then
		if not game.paused and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
			local d = unitVectorFromAngle(LAUNCH_ANGLE)
			d = vMul(d, game.human.selectedPlanet.radius)
			d = vAdd(d, game.human.selectedPlanet.location)
			game:launchHumanSpore(d)
		elseif game.interface.messages[1] and not game.interface.messages[1]:activateSelectedButton() and not game.paused then
			centerOnSelection()
		end
		
	elseif k == 'escape' then
		game:togglePause()
	end
end

function love.keypressed(k, isRepeat)
	if k == 'left' then
		if not game.paused and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
			if isRepeat then
				LAUNCH_ANGLE = LAUNCH_ANGLE - TAU/33
			else
				LAUNCH_ANGLE = LAUNCH_ANGLE - TAU/100
			end
		elseif game.interface.messages[1] and game.interface.messages[1]:selectPrevButton() then
			--
		elseif not game.paused then
			game.offset.x = game.offset.x + 20
			adjustOffset()
			game.flags.shiftView = true
		end
		
	elseif k == 'right' then
		if not game.paused and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
			if isRepeat then
				LAUNCH_ANGLE = LAUNCH_ANGLE + TAU/33
			else
				LAUNCH_ANGLE = LAUNCH_ANGLE + TAU/100
			end
		elseif game.interface.messages[1] and game.interface.messages[1]:selectNextButton() then
			--
		elseif not game.paused then
			game.offset.x = game.offset.x - 20
			adjustOffset()
			game.flags.shiftView = true
		end
		
	elseif k == 'up' then
		if not game.paused and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
			if isRepeat then
				LAUNCH_ANGLE = LAUNCH_ANGLE - TAU/33
			else
				LAUNCH_ANGLE = LAUNCH_ANGLE - TAU/100
			end
		elseif game.interface.messages[1] and game.interface.messages[1]:selectPrevButton() then
			--
		elseif not game.paused then
			game.offset.y = game.offset.y + 20
			adjustOffset()
			game.flags.shiftView = true
		end
		
	elseif k == 'down' then
		if not game.paused and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
			if isRepeat then
				LAUNCH_ANGLE = LAUNCH_ANGLE + TAU/33
			else
				LAUNCH_ANGLE = LAUNCH_ANGLE + TAU/100
			end
		elseif game.interface.messages[1] and game.interface.messages[1]:selectNextButton() then
			--
		elseif not game.paused then
			game.offset.y = game.offset.y - 20
			adjustOffset()
			game.flags.shiftView = true
		end
		
	elseif k == 'q' then
		game.human.colony.attack = game.human.colony.attack * 0.8
		game.human.colony:adjustGenes()
		
	elseif k == 'w' then
		game.human.colony.attack = game.human.colony.attack * 1.25
		game.human.colony:adjustGenes()
		game.flags.increaseAttack = true
		
	elseif k == 'a' then
		game.human.colony.spawn = game.human.colony.spawn * 0.8
		game.human.colony:adjustGenes()
		
	elseif k == 's' then
		game.human.colony.spawn = game.human.colony.spawn * 1.25
		game.human.colony:adjustGenes()
		game.flags.increaseSpawn = true
		
	elseif k == 'z' then
		game.human.colony.travel = game.human.colony.travel * 0.8
		game.human.colony:adjustGenes()
		
	elseif k == 'x' then
		game.human.colony.travel = game.human.colony.travel * 1.25
		game.human.colony:adjustGenes()
		game.flags.increaseTravel = true
		
	elseif k == 'tab' and not game.paused then
		local firstPlanet = nil
		local chooseNextPlanet = false
		local chosenPlanet = nil
		for i, planet in pairs(planets) do
			local friends = planet:countFriends(game.human.colony)
			if friends > 0 then
				if not firstPlanet then firstPlanet = planet end
				if planet == game.human.selectedPlanet then
					chooseNextPlanet = true
				elseif chooseNextPlanet then
					chosenPlanet = planet
					chooseNextPlanet = false
				end
			end
		end
		if not chosenPlanet and firstPlanet then
			chosenPlanet = firstPlanet
		end
		if chosenPlanet == game.human.homeWorld then
			game.flags.selectHomeWorld = true
		end
		game.human.selectedPlanet = chosenPlanet
		centerOnSelection()
	end
	
	
	-- if paused, arrows select prev/next button
		-- also if paused, ENTER or SPACE activate selected button
	
	-- to launch from keyboard: shift to show target circle,
	-- arrows while holding shift to aim,
	-- ENTER or SPACE to launch
	
end

function love.quit ()
	if game.tutorial or game.flags.win or game.flags.lose then
		love.filesystem.remove('savegame')
	else
		saveGame()
	end
end

function saveGame ()
	game.stars = stars
	game.suns = suns
	game.planets = planets
	game.planetConnections = planetConnections
	love.filesystem.write('savegame', DataDumper(game))
end

function loadGame ()
	local f = love.filesystem.read('savegame')
	local fun = loadstring(f)
	game = fun()
	stars = game.stars
	suns = game.suns
	planets = game.planets
	planetConnections = game.planetConnections
	toggleFullscreen(true)
	if game.soundOn then
		if game.paused then
			gameMusic:setVolume(0.5)
		else
			gameMusic:setVolume(1)
		end
		gameMusic:play()
	end
end

function toggleFullscreen (doNotToggle)
	if not doNotToggle then game.isFullscreen = not game.isFullscreen end
	love.window.setFullscreen(game.isFullscreen)
	if FANCY_GRAPHICS then post_effect = setupFancyGraphics() end
end

function setupFancyGraphics ()
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.setColor(255,255,255)
	local vignette = shine.vignette()
	vignette.parameters = {radius = .95, opacity = 0.2}
	local separate_chroma = shine.separate_chroma()
	separate_chroma.parameters = {radius = 0.5}
	local filmgrain = shine.filmgrain()
	filmgrain.parameters = {opacity = 0.05}
	return separate_chroma:chain(vignette:chain(filmgrain))
end

function adjustPos (x, y)
	local v = newVector(x, y)
	v = vSub(v, game.offset)
	v = vDiv(v, game.zoom)
	return v
end

function unAdjustPos (x, y)
	local v = newVector(x, y)
	v = vMul(v, game.zoom)
	v = vAdd(v, game.offset)
	return v
end

function adjustOffset ()
	game.offset.x = math.min(0, math.max(-game.world_size.width * game.zoom + love.graphics.getWidth(), game.offset.x))
	game.offset.y = math.min(0, math.max(-game.world_size.height * game.zoom + love.graphics.getHeight(), game.offset.y))
end

function drawFilledCircle(x, y, r)
	love.graphics.circle('fill', x*game.zoom, y*game.zoom, r*game.zoom-.5, SEGMENTS)
	love.graphics.setLineWidth(1)
	love.graphics.circle('line', x*game.zoom, y*game.zoom, r*game.zoom-.5, SEGMENTS)
end