-- Platformer/main.lua

local love = require("love")
local wf = require("lib/windfield")

function love.load()
	WORLD = wf.newWorld(0, 800, false)

	WORLD:addCollisionClass("PLATFORM")
	WORLD:addCollisionClass("PLAYER"--[[, { ignores = { "PLATFORM" } }]])
	WORLD:addCollisionClass("DANGER")

	PLAYER = WORLD:newRectangleCollider(360, 100, 80, 80, { collision_class = "PLAYER" })
	PLAYER:setFixedRotation(true)
	PLAYER.speed = 240

	PLATFORM = WORLD:newRectangleCollider(250, 400, 300, 100, { collision_class = "PLATFORM" })
	PLATFORM:setType("static")

	DANGERZONE = WORLD:newRectangleCollider(0, 550, 800, 50, { collision_class = "DANGER" })
	DANGERZONE:setType("static")
end

function love.update(dt)
	WORLD:update(dt)

	if PLAYER.body then
		local px, py = PLAYER:getPosition()
		if love.keyboard.isDown("right") then
			PLAYER:setX(px + PLAYER.speed * dt)
		end
		if love.keyboard.isDown("left") then
			PLAYER:setX(px - PLAYER.speed * dt)
		end

		if PLAYER:enter("DANGER") then
			PLAYER:destory()
		end
	end
end

function love.draw()
	WORLD:draw()
end

function love.keypressed(key)
	if key == "up" then
		PLAYER:applyLinearImpulse(0, -1000)
	end
end
