--[[

FIX:
- attack-abroad spore not showing up
- weird flickering when spawning locally

(all fade in and then fade out unless noted)

First open:
Welcome to Prospora
- skip tutorial

Later opens (start up previous game - could be tutorial! - if there is one, or new game if there isn't, paused)
or Paused:
Prospora
- return to game
- turn sound on/off
- about
(make sure these are separated from the main menu options to prevent easy exiting, maybe smaller along bottom of screen)
- new game
- new tutorial
- quit

Start tutorial:
This is your home planet. (point to home planet)
_Click to select it.
(make nil a possible planet selection, and make it the initial default)

First clicking of home planet:
These are spores in your colony. (point to spore)
Try launching one toward another planet to make a connection. (point to nearest empty planet)
_Click and drag away from the planet to launch a spore.

First time there is only one spore on a planet:
Increase your colony's spawn rate to generate more spores. (point to spawn bar)
_Drag the spawn bar to the right.

First time making a connection with an empty planet:
Increase your colony's travel rate to get spores to spawn and attack across a connection. (point to travel bar)
_Drag the travel bar to the right.

First time changing the bars after making a connection (?):
Now it's time to explore. (point to empty space)
_Click and drag empty space to move your viewpoint.

First time an enemy home planet comes into view:
You've discovered an enemy spore colony. (point to enemy home planet)
Destroy all enemy home planets to win the game.

First time making a connection with an enemy-inhabited planet:
Increase your colony's attack rate to defend and expand your territory. (point to attack bar)
_Drag the attack bar to the right.

Losing tutorial:
Alas, your colony was destroyed
- restart tutorial
- start full game
- quit

Winning tutorial:
Hurrah, your colony was triumphant
- restart tutorial
- start full game
- quit

Losing regular game:
You have been eradicated
- new game
- new tutorial
- quit

Winning regular game:
A tiny universe, conquered
- new game
- new tutorial
- quit

]]--

function newInterface ()
	local i = {}
	
	i.elements = {}
	table.insert(i.elements, newSlider('attack', 1))
	table.insert(i.elements, newSlider('spawn', 2))
	table.insert(i.elements, newSlider('travel', 3))
	
	i.flags = {} -- 0 = hasn't happened yet, 1 = show the thing!, 2 = it's happened, don't show again
	i.flags.firstClickHome = 0
	i.flags.firstOneSporeLeft = 0
	i.flags.firstConnection = 0
	i.flags.firstGeneChange = 0
	i.flags.firstEnemyHomeInView = 0 --todo
	i.flags.firstBattle = 0
	i.flags.startTutorial = 0 --todo
	i.flags.winTutorial = 0 --todo
	i.flags.loseTutorial = 0 --todo
	i.flags.win = 0 --todo
	i.flags.lose = 0 --todo
	
	function i:update ()
		for i, e in pairs(self.elements) do
			local kill = e:update()
			if kill then
				table.remove(self.elements, i)
			end
		end
		for flagKey, flagValue in pairs(self.flags) do
			if flagValue == 1 then
				table.insert(self.elements, 1, newMessage(flagKey))
			end
		end
	end
	
	function i:draw ()
		local currentPosition = 1
		for _, e in pairs(self.elements) do
			if e.type == 'message' then
				e:draw(currentPosition)
				currentPosition = currentPosition + 1
			else
				e:draw()
			end
		end
	end
	
	function i:mousepressed (x, y)
		local busy = false
		for _, e in pairs(self.elements) do
			if e.actArea and x >= e.actArea.x and x <= e.actArea.x+e.actArea.width and y >= e.actArea.y and y <= e.actArea.y+e.actArea.height then
				e:press(x, y)
				busy = true
			end
			if e.type == 'message' then
				e.fading = true
			end
		end
		return busy
	end
	
	function i:mousereleased (x, y)
		local busy = false
		for _, e in pairs(self.elements) do
			if e.pressed then
				e:release(x, y)
				busy = true
			end
		end
		return busy
	end
	
	return i
end

function newMessage (flagKey)
	local m = {}
	m.type = 'message'
	m.text = strings[flagKey]
	m.flag = flagKey
	game.interface.flags[flagKey] = 1.001
	--m.pressed = false
	m.fading = false
	
	function m:update ()
		if self.fading then
			game.interface.flags[self.flag] = game.interface.flags[self.flag] * 1.002
			if game.interface.flags[self.flag] >= 2 then
				return true
			end
		end
	end
	
	function m:draw (order)
		love.graphics.setFont(font)
		love.graphics.setColor(0,0,0,(2-game.interface.flags[self.flag])*64)
		love.graphics.rectangle('fill', 0, math.max(love.graphics.getHeight()*.05, 20)+order*120-10, love.graphics.getWidth(), 120)
		--love.graphics.printf(self.text, 101, (order+3)*math.max(love.graphics.getHeight()*.05, 20)+1, love.graphics.getWidth()-198, 'center')
		love.graphics.setColor(255,255,255,(2-game.interface.flags[self.flag])*255)
		love.graphics.printf(self.text, 100, math.max(love.graphics.getHeight()*.05, 20)+order*120, love.graphics.getWidth()-200, 'center')
	end
	
	--[[function m:press (x, y)
		self.pressed = true
	end
	
	function m:release (x, y)
		self.pressed = false
	end]]--
	
	return m
	
end

function newSlider (stat, order)
	local s = {}
	
	s.type = 'slider'
	s.order = order
	s.pos = {x=0, y=0}
	s.stat = stat
	s.actArea = {x=0, y=0, width=45, height=15}
	s.pressed = false
	s.sliderWidth = 0
	
	function s:update ()
		self.pos.y = self.order * math.max(love.graphics.getHeight()*.05, 20)
		local maxWidth = love.graphics.getWidth() - self.actArea.width*1.5
		
		if self.pressed then
			local adjTouchX = love.mouse.getX() - self.actArea.width/2
			local newX = math.max(math.min(adjTouchX, maxWidth), 0)
			local newGeneStat = newX/maxWidth
			human.colony[stat] = newGeneStat
			human.colony:adjustGenes()
			if game.interface.flags.firstGeneChange == 0 and game.interface.flags.firstConnection > 0 then
				game.interface.flags.firstGeneChange = 1
			end
		end
		
		self.sliderWidth = human.colony[stat] * maxWidth
		self.actArea.x = self.pos.x + self.sliderWidth
		self.actArea.y = self.pos.y - self.actArea.height/2
	end
	
	function s:draw ()
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 255, 255, 127)
		love.graphics.line(self.pos.x, self.pos.y, love.graphics.getWidth(), self.pos.y)

		love.graphics.setColor(0, 170, 250)
		love.graphics.setFont(font)
		love.graphics.print(strings[self.stat], 3, self.pos.y-18)
		
		if self.pressed then
			love.graphics.setLineWidth(3)
		else
			love.graphics.setLineWidth(2)
		end
		love.graphics.setColor(0, 0, 0, 50)
		love.graphics.line(self.pos.x, self.pos.y+2, self.pos.x + self.sliderWidth, self.pos.y)
		love.graphics.setColor(0, 170, 250)
		love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.sliderWidth, self.pos.y)
		
		if self.pressed then
			love.graphics.setColor(0, 0, 0, 50)
			love.graphics.rectangle('fill', self.actArea.x+2, self.actArea.y+2, self.actArea.width, self.actArea.height)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', self.actArea.x-1, self.actArea.y-1, self.actArea.width+2, self.actArea.height+2)
			love.graphics.setColor(0, 0, 0, 10)
			love.graphics.rectangle('fill', self.actArea.x+2, self.actArea.y+2, self.actArea.width-4, self.actArea.height-4)
		else
			love.graphics.setColor(0, 0, 0, 50)
			love.graphics.rectangle('fill', self.actArea.x+2, self.actArea.y+2, self.actArea.width, self.actArea.height)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', self.actArea.x, self.actArea.y, self.actArea.width, self.actArea.height)
		end
		
		love.graphics.setLineWidth(1)
		love.graphics.setColor(0, 170, 250)
		--drawTriangle(600, 400, 30, 'line')
	end
	
	function s:press (x, y)
		self.pressed = true
	end
	
	function s:release (x, y)
		self.pressed = false
	end
	
	return s
	
end

--[[
function drawTriangle (x, y, r, style)
	style = style or 'fill'
	
	local v = vMul(newVector(math.cos(PI/6), math.sin(PI/6)), r)
	local corner1 = newVector(x, y-r)
	local corner2 = newVector(x + v.x, y + v.y)
	local corner3 = newVector(x - v.x, y + v.y)
	
	love.graphics.polygon(style, corner1.x, corner1.y, corner2.x, corner2.y, corner3.x, corner3.y)
	
	local side1 = vAdd(corner1, corner2)
	local side2 = vAdd(corner2, corner3)
	local side3 = vAdd(corner3, corner1)
	
	local mX = love.mouse.getX()
	local mY = love.mouse.getY()
	local mR = math.sqrt(love.graphics.getWidth()^2 + love.graphics.getHeight()^2)
	local v1 = vMul(newVector(math.cos(PI/2), math.sin(PI/2)), mR)
	local v2 = vMul(newVector(math.cos(-PI/6), math.sin(-PI/6)), mR)
	local v3 = vMul(newVector(math.cos(-PI*(5/6)), math.sin(-PI*(5/6))), mR)
	
	love.graphics.line(mX, mY, mX+v1.x, mY+v1.y)
	love.graphics.line(mX, mY, mX+v2.x, mY+v2.y)
	love.graphics.line(mX, mY, mX+v3.x, mY+v3.y)
end
]]--
	