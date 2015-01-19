tutorialMode = newScreenMode()

function tutorialMode:load ()
	self.buttons = {
		newButton('main menu', 100, 500, function () switchToMode(startMode) end)
	}
end

function tutorialMode:draw ()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(fontLarge)
	love.graphics.print('HOW TO PLAY', 100, 100)
	love.graphics.setFont(font)
	
	self:drawButtons()
end

--[[
This is your homeworld.

These are your spores.

Click and drag the planet to launch a spore to another planet.

Spores can now attack and breed across the connection.

Click on other planets to select them.
Click and drag the screen to move around the universe.
Drag this bar to zoom in and out.
Drag this bar to speed up or slow down the game.

Adjust your spores' behavior by dragging the bars at the top.
Attack is how likely a spore is to attack an enemy meme.
Spawn is how likely a spore is to spawn into an empty space.
Travel is how likely a spore is to attack or spawn across a planetary connection.

Kill all enemy units to win.
But be careful - if all the units on your home planet are killed, you lose!
]]--