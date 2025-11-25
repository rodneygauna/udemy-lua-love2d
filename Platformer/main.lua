-- Platformer/main.lua
local love = require("love")
local wf = require("lib/windfield")
local anim8 = require("lib.anim8.anim8")

function love.load()
    WORLD = wf.newWorld(0, 800, false)
    WORLD:setQueryDebugDrawing(true)

    WORLD:addCollisionClass("PLATFORM")
    WORLD:addCollisionClass("PLAYER" --[[, { ignores = { "PLATFORM" } }]] )
    WORLD:addCollisionClass("DANGER")

    SPRITES = {}
    SPRITES.playerSheet = love.graphics.newImage("sprites/playerSheet.png")

    local grid = anim8.newGrid(614, 564, SPRITES.playerSheet:getWidth(), SPRITES.playerSheet:getHeight())

    ANIMATIONS = {}
    ANIMATIONS.idle = anim8.newAnimation(grid("1-15", 1), 0.05)
    ANIMATIONS.jump = anim8.newAnimation(grid("1-7", 2), 0.05)
    ANIMATIONS.run = anim8.newAnimation(grid("1-15", 3), 0.05)

    require("player")

    PLATFORM = WORLD:newRectangleCollider(250, 400, 300, 100, {
        collision_class = "PLATFORM"
    })
    PLATFORM:setType("static")

    DANGERZONE = WORLD:newRectangleCollider(0, 550, 800, 50, {
        collision_class = "DANGER"
    })
    DANGERZONE:setType("static")
end

function love.update(dt)
    WORLD:update(dt)
    playerUpdate(dt)
end

function love.draw()
    WORLD:draw()
    playerDraw()
end

function love.keypressed(key)
    if key == "up" then
        if PLAYER.grounded then
            PLAYER:applyLinearImpulse(0, -4000)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = WORLD:queryCircleArea(x, y, 200)
        for i, c in ipairs(colliders) do
            c:destory()
        end
    end
end
