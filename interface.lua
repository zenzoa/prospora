--[[

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
	
	function i:update ()
		for _, e in pairs(self.elements) do
			e:update()
		end
	end
	
	function i:draw ()
		for _, e in pairs(self.elements) do
			e:draw()
		end
	end
	
	function i:mousepressed (x, y)
		local busy = false
		for _, e in pairs(self.elements) do
			if x >= e.actArea.x and x <= e.actArea.x+e.actArea.width and y >= e.actArea.y and y <= e.actArea.y+e.actArea.height then
				e:press(x, y)
				busy = true
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

function newSlider (stat, order)
	local s = {}
	
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
	end
	
	function s:press (x, y)
		self.pressed = true
	end
	
	function s:release (x, y)
		self.pressed = false
	end
	
	return s
	
end
	