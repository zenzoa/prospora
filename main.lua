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

require("game")
local shine = require("shine")

require("screenModes")
require("screenMode-game")
require("screenMode-win")
require("screenMode-lose")
require("screenMode-pause")
require("screenMode-start")
require("screenMode-options")
require("screenMode-tutorial")
require("screenMode-credits")

FPS = 60
UNIT_RADIUS = 5
SEGMENTS = 60
FONT_SIZE = 20
NEW_PLAYER = true
screenMode = startMode
soundOn = true
advancedControls = true --default to false

function love.load()
	
	math.randomseed( os.time() )
	
	-- setup window
	love.window.setTitle("Prospora")
	love.window.setMode(800, 600, {fullscreen=false, fullscreentype='desktop'})
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setLineStyle('smooth')
	love.graphics.setPointStyle('rough')
	
	-- setup fonts
	font = love.graphics.newFont('assets/furore.otf', FONT_SIZE)
	fontLarge = love.graphics.newFont('assets/furore.otf', FONT_SIZE*2)
	love.graphics.setFont(font)
	
	-- setup audio
	gameMusic = love.audio.newSource('assets/alg0rh1tm-circuit.mp3', 'stream')
	gameMusic:setLooping(true)
	winMusic = love.audio.newSource('assets/alg0rh1tm-unit731.mp3', 'stream')
	winMusic:setLooping(true)
	loseSound = love.audio.newSource('assets/ani-music-wicked-bass-drop.wav', 'static')
	launchSound = love.audio.newSource('assets/fins-laser.wav', 'static')
	selectSound = love.audio.newSource('assets/nickgoa-plink.wav', 'static')
	selectSound:setVolume(0.5)
	buttonSound = love.audio.newSource('assets/junggle-btn402.mp3', 'static')
	buttonSound:setVolume(0.1)
	hitPlanetSound = love.audio.newSource('assets/reitanna-drop-metal-thing.wav', 'static')
	hitPlanetSound:setVolume(0.5)
	attackedSound = love.audio.newSource('assets/daphne-in-wonderland-bass-metal-thud.wav', 'static')
	
	-- setup cool vignette effect
	local vignette = shine.vignette()
	vignette.parameters = {radius = 0.9, opacity = 0.1}
	post_effect = vignette
	
	-- setup new game
	game = newGame()
	game:load()
	
	--screenMode:load()
end

timeSinceLastUpdate = 0

function love.update(dt)
	timeSinceLastUpdate = timeSinceLastUpdate + dt
	if (timeSinceLastUpdate >= 1/FPS) then
		game:update()
		--if screenMode.update then screenMode:update() end
		timeSinceLastUpdate = timeSinceLastUpdate - (1/FPS)
	end
end

function love.draw()
	game:draw()
	--if screenMode.draw then screenMode:draw() end
end

function love.mousepressed(x, y, button)
	game:mousepressed(x, y)
	--if screenMode.mousepressed then screenMode:mousepressed(x, y) end
end

function love.mousereleased(x, y, button)
	game:mousereleased(x, y)
	--if screenMode.mousereleased then screenMode:mousereleased(x, y) end
end

function checkForEndGame ()
	local noEnemyHomeworlds = true
	for _, planet in pairs(planets) do
		if planet.isHomeWorld and planet.homeWorldMeme ~= human.colony then
			noEnemyHomeworlds = false
		end
	end
	if noEnemyHomeworlds then
		win()
	elseif not human.homeWorld.isHomeWorld then
		lose()
	end
end

function win ()
	switchToMode(winMode)
end

function lose ()
	switchToMode(loseMode)
end

function resetMusic ()
	gameMusic:rewind()
	gameMusic:stop()
	winMusic:rewind()
	winMusic:stop()
end

--

function adjustPos (x, y)
	local v = newVector(x, y)
	v = vSub(v, OFFSET)
	v = vDiv(v, ZOOM)
	return v
end

function adjustOffset ()
	OFFSET.x = math.min(0, math.max(-WORLD_SIZE.width * ZOOM + love.graphics.getWidth(), OFFSET.x))
	OFFSET.y = math.min(0, math.max(-WORLD_SIZE.height * ZOOM + love.graphics.getHeight(), OFFSET.y))
end

--

function drawFilledCircle(x, y, r)
	love.graphics.circle('fill', x*ZOOM, y*ZOOM, r*ZOOM-.5, SEGMENTS)
	love.graphics.setLineWidth(1)
	love.graphics.circle('line', x*ZOOM, y*ZOOM, r*ZOOM-.5, SEGMENTS)
end
