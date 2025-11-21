-- TopDownShooter/main.lua
function love.load()
    -- Load assets, initialize game state, etc.
    sprites = {}
    sprites.background = love.graphics.newImage("sprites/background.png")
    sprites.player = love.graphics.newImage("sprites/player.png")
    sprites.zombie = love.graphics.newImage("sprites/zombie.png")
    sprites.bullet = love.graphics.newImage("sprites/bullet.png")

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 160

    zombies = {}
    bullets = {}
end

function love.update(dt)
    -- Update game state, handle input, etc.
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end

    for i, zombie in ipairs(zombies) do
        zombie.x = zombie.x + math.cos(zombiePlayerAngle(zombie)) * zombie.speed * dt
        zombie.y = zombie.y + math.sin(zombiePlayerAngle(zombie)) * zombie.speed * dt

        if distanceBetween(zombie.x, zombie.y, player.x, player.y) < 30 then
            for i, zombie in ipairs(zombies) do
                zombies[i] = nil
            end
        end
    end
end

function love.draw()
    -- Render game objects, UI, etc.
    love.graphics.draw(sprites.background, 0, 0)
    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth() / 2,
        sprites.player:getHeight() / 2)
    for i, zombie in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, zombie.x, zombie.y, zombiePlayerAngle(zombie), nil, nil,
            sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function playerMouseAngle()
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
    return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
    local zombie = {}
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = math.random(0, love.graphics.getHeight())
    zombie.speed = 100
    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
