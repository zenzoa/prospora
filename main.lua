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
require("interface")
local shine = require("shine")

FANCY_GRAPHICS = true
FPS = 60
UNIT_RADIUS = 5
SEGMENTS = 60
FONT_SIZE = 20
NEW_PLAYER = true
soundOn = true

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
	post_effect_on = setupFancyGraphics()
	post_effect_off = function(f) f() end
	post_effect = post_effect_on
	
	-- setup new game
	game = newGame()
	game:load()
end

timeSinceLastUpdate = 0

function love.update(dt)
	timeSinceLastUpdate = timeSinceLastUpdate + dt
	if (timeSinceLastUpdate >= 1/FPS) then
		game:update()
		timeSinceLastUpdate = timeSinceLastUpdate - (1/FPS)
	end
end

function love.draw()
	game:draw()
end

function love.mousepressed(x, y, button)
	game:mousepressed(x, y)
end

function love.mousereleased(x, y, button)
	game:mousereleased(x, y)
end

function love.keypressed(k)
	if k == 'escape' then
		game:togglePause()
	end
	
	if k == 'q' then
		FANCY_GRAPHICS = not FANCY_GRAPHICS
		if FANCY_GRAPHICS then
			post_effect = post_effect_on
		else
			post_effect = post_effect_off
		end
	end
	
	if k == 'f' then
		local isFullscreen = not love.window.getFullscreen()
		love.window.setFullscreen(isFullscreen)
		post_effect_on = setupFancyGraphics()
		if FANCY_GRAPHICS then post_effect = post_effect_on end
	end
	
	if k == ' ' then
		centerOnSelection()
	end
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

function setupFancyGraphics()
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
	v = vSub(v, OFFSET)
	v = vDiv(v, ZOOM)
	return v
end

function adjustOffset ()
	OFFSET.x = math.min(0, math.max(-WORLD_SIZE.width * ZOOM + love.graphics.getWidth(), OFFSET.x))
	OFFSET.y = math.min(0, math.max(-WORLD_SIZE.height * ZOOM + love.graphics.getHeight(), OFFSET.y))
end

function drawFilledCircle(x, y, r)
	love.graphics.circle('fill', x*ZOOM, y*ZOOM, r*ZOOM-.5, SEGMENTS)
	love.graphics.setLineWidth(1)
	love.graphics.circle('line', x*ZOOM, y*ZOOM, r*ZOOM-.5, SEGMENTS)
end
