require("maths")
require("vectors")

require("stars")
require("suns")
require("flyers")
require("memes")
require("planets")
require("players")

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
TURN_TIME = 30.0
ZOOM = 0.5
UNIT_RADIUS = 5
SEGMENTS = 30

UNIVERSE_SIZE = 10
WORLD_SIZE = {width = 0, height = 0}
OFFSET = {x = 0, y = 0}

human = newPlayer()

screenMode = startMode

soundOn = true

function love.load()
	
	math.randomseed( os.time() )
	
	-- Setup window
	love.window.setTitle("Prospora")
	love.window.setMode(600, 600, {fsaa=16})
	love.graphics.setBackgroundColor(51, 51, 51)
	love.graphics.setLineStyle('smooth')
	
	-- setup fonts
	font = love.graphics.newFont('assets/furore.otf', 20)
	fontLarge = love.graphics.newFont('assets/furore.otf', 40)
	love.graphics.setFont(font)
	
	-- setup audio
	gameMusic = love.audio.newSource('assets/alg0rh1tm-circuit.mp3', 'stream')
	gameMusic:setLooping(true)
	winMusic = love.audio.newSource('assets/alg0rh1tm-unit731.mp3', 'stream')
	winMusic:setLooping(true)
	loseMusic = love.audio.newSource('assets/alg0rh1tm-unit731.mp3', 'stream')
	loseMusic:setLooping(true)
	launchSound = love.audio.newSource('assets/fins-laser.wav', 'static')
	selectSound = love.audio.newSource('assets/nickgoa-plink.wav', 'static')
	selectSound:setVolume(0.5)
	buttonSound = love.audio.newSource('assets/junggle-btn402.mp3', 'static')
	buttonSound:setVolume(0.1)
	
	-- setup tutorial images
	tutorialImage1 = love.graphics.newImage('assets/tutorial-1.png')
	tutorialImage2 = love.graphics.newImage('assets/tutorial-2.png')
	tutorialImage3 = love.graphics.newImage('assets/tutorial-3.png')
	tutorialImage4 = love.graphics.newImage('assets/tutorial-4.png')
	tutorialImage5 = love.graphics.newImage('assets/tutorial-5.png')
	tutorialImage6 = love.graphics.newImage('assets/tutorial-6.png')
	tutorialImage7 = love.graphics.newImage('assets/tutorial-7.png')
	
	screenMode:load()
end

timeSinceLastUpdate = 0

function love.update(dt)
	timeSinceLastUpdate = timeSinceLastUpdate + dt
	if (timeSinceLastUpdate >= 1/FPS) then
		if screenMode.update then screenMode:update() end
		timeSinceLastUpdate = timeSinceLastUpdate - (1/FPS)
	end
end

function love.draw()
	if screenMode.draw then screenMode:draw() end
end

function love.mousepressed(x, y, button)
	if screenMode.mousepressed then screenMode:mousepressed(x, y) end
end

function love.mousereleased(x, y, button)
	if screenMode.mousereleased then screenMode:mousereleased(x, y) end
end

function checkForEndGame ()
	local noEnemyHomeworlds = true
	for _, planet in pairs(planets) do
		if planet.isHomeWorld and planet.homeWorldMeme ~= human.meme then
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
	loseMusic:rewind()
	loseMusic:stop()
end

--

function adjustMousePos (x, y)
	local v = newVector(x, y)
	v = vSub(v, OFFSET)
	v = vDiv(v, ZOOM)
	return v
end

function adjustOffset ()
	OFFSET.x = math.min(0, math.max(-WORLD_SIZE.width * ZOOM + love.graphics.getWidth(), OFFSET.x))
	OFFSET.y = math.min(0, math.max(-WORLD_SIZE.height * ZOOM + love.graphics.getHeight(), OFFSET.y))
end