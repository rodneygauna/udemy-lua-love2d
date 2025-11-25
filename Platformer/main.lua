-- Platformer/main.lua
local love = require("love")
local wf = require("lib/windfield")
local anim8 = require("lib.anim8.anim8")
local sti = require("lib/Simple-Tiled-Implementation/sti")
local cameraFile = require("lib/hump/camera")

function love.load()
    love.window.setMode(1024, 768)

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

    --[[
		DANGERZONE = WORLD:newRectangleCollider(0, 550, 800, 50, {
        collision_class = "DANGER"
    })
    DANGERZONE:setType("static")
		-- ]]

    PLATFORMS = {}

    CAM = cameraFile()

    loadMap()
end

function love.update(dt)
    WORLD:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    local px, py = PLAYER:getPosition()
    CAM:lookAt(px, love.graphics.getHeight() / 2)
end

function love.draw()
    CAM:attach()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    WORLD:draw()
    playerDraw()
    CAM:detach()
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

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = WORLD:newRectangleCollider(x, y, width, height, {
            collision_class = "PLATFORM"
        })
        platform:setType("static")
        table.insert(PLATFORMS, platform)
    end
end

function loadMap()
    gameMap = sti("maps/level1.lua")
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end
