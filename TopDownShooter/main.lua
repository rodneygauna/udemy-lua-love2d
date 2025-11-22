-- TopDownShooter/main.lua
function love.load()
    -- Load assets, initialize game state, etc.
    -- Set random seed
    math.randomseed(os.time())

    -- Load sprites
    sprites = {}
    sprites.background = love.graphics.newImage("sprites/background.png")
    sprites.player = love.graphics.newImage("sprites/player.png")
    sprites.zombie = love.graphics.newImage("sprites/zombie.png")
    sprites.bullet = love.graphics.newImage("sprites/bullet.png")

    -- Initialize player
    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 160

    -- Font
    myFont = love.graphics.newFont(30)

    -- Initialize game objects
    zombies = {}
    bullets = {}

    -- Game state
    gameState = 1 -- 1: Game Over/Menu, 2: Playing
    score = 0
    maxTime = 2
    timer = maxTime
end

function love.update(dt)
    -- Update game state, handle input, etc.
    -- Player movement
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
            player.x = player.x + player.speed * dt
        end
        if love.keyboard.isDown("a") and player.x > 0 then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("w") and player.y > 0 then
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
            player.y = player.y + player.speed * dt
        end
    end

    -- Update zombies
    for i, zombie in ipairs(zombies) do
        zombie.x = zombie.x + math.cos(zombiePlayerAngle(zombie)) * zombie.speed * dt
        zombie.y = zombie.y + math.sin(zombiePlayerAngle(zombie)) * zombie.speed * dt

        if distanceBetween(zombie.x, zombie.y, player.x, player.y) < 30 then
            for i, zombie in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1 -- Game Over
                player.x = love.graphics.getWidth() / 2 -- Reset player position
                player.y = love.graphics.getHeight() / 2 -- Reset player position
            end
        end
    end

    -- Update bullets
    for i, b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction) * b.speed * dt)
    end

    -- Remove bullets that are off-screen
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.x > love.graphics.getWidth() or b.y < 0 or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

    -- Check for collisions between bullets and zombies
    for i, zombie in ipairs(zombies) do
        for j, bullet in ipairs(bullets) do
            if distanceBetween(zombie.x, zombie.y, bullet.x, bullet.y) < 20 then
                zombie.dead = true
                bullet.dead = true
                score = score + 1
            end
        end
    end

    -- Remove dead zombies
    for i = #zombies, 1, -1 do
        if zombies[i].dead then
            table.remove(zombies, i)
        end
    end

    -- Remove dead bullets
    for i = #bullets, 1, -1 do
        if bullets[i].dead then
            table.remove(bullets, i)
        end
    end

    -- Spawn zombies over time
    if gameState == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end
end

function love.draw()
    -- Render game objects, UI, etc.
    -- Draw background
    love.graphics.draw(sprites.background, 0, 0)

    -- Draw start screen message
    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end

    -- Draw score
    love.graphics.setFont(myFont)
    love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

    -- Draw player
    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth() / 2,
        sprites.player:getHeight() / 2)

    -- Draw zombies
    for i, zombie in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, zombie.x, zombie.y, zombiePlayerAngle(zombie), nil, nil,
            sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end

    -- Draw bullets
    for i, b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, nil, sprites.bullet:getWidth() / 2,
            sprites.bullet:getHeight() / 2)
    end
end

function love.keypressed(key)
    -- Spawn a zombie when spacebar is pressed
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button)
    -- Spawn a bullet when left mouse button is pressed
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
    end
end

function playerMouseAngle()
    -- Calculate angle between player and mouse cursor
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
    -- Calculate angle between zombie and player
    return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
    -- Create a new zombie at a random position
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 100
    zombie.dead = false

    -- Spawn zombie at random edge of the screen
    local side = math.random(1, 4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function spawnBullet()
    -- Create a new bullet at the player's position
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

function distanceBetween(x1, y1, x2, y2)
    -- Calculate distance between two points
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
