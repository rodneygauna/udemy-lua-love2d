PLAYER = WORLD:newRectangleCollider(360, 100, 40, 100, {
    collision_class = "PLAYER"
})
PLAYER:setFixedRotation(true)
PLAYER.speed = 240
PLAYER.animation = ANIMATIONS.idle
PLAYER.isMoving = false
PLAYER.direction = 1 -- 1 for right, -1 for left
PLAYER.grounded = true

function playerUpdate(dt)
    if PLAYER.body then
        local colliders = WORLD:queryRectangleArea(PLAYER:getX() - 20, PLAYER:getY() + 50, 40, 2, {"PLATFORM"})
        if #colliders > 0 then
            PLAYER.grounded = true
        else
            PLAYER.grounded = false
        end
        PLAYER.isMoving = false
        local px, py = PLAYER:getPosition()
        if love.keyboard.isDown("right") then
            PLAYER:setX(px + PLAYER.speed * dt)
            PLAYER.isMoving = true
            PLAYER.direction = 1
        end
        if love.keyboard.isDown("left") then
            PLAYER:setX(px - PLAYER.speed * dt)
            PLAYER.isMoving = true
            PLAYER.direction = -1
        end

        if PLAYER:enter("DANGER") then
            PLAYER:destory()
        end
    end

    if PLAYER.grounded then
        if PLAYER.isMoving then
            PLAYER.animation = ANIMATIONS.run
        else
            PLAYER.animation = ANIMATIONS.idle
        end
    else
        PLAYER.animation = ANIMATIONS.jump
    end
    PLAYER.animation:update(dt)
end

function playerDraw()
    local px, py = PLAYER:getPosition()
    PLAYER.animation:draw(SPRITES.playerSheet, px, py, nil, 0.25 * PLAYER.direction, 0.25, 130, 300)
end
