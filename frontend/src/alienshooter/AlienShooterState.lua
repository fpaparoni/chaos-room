-- AlienShooterState.lua
AlienShooterState = Class{__includes = BaseState}
require 'src/core/ChaosController'

gSounds = {
    ['music']       = love.audio.newSource('assets/alienshooter/sounds/main.mp3', 'stream'),
    ['fire']       = love.audio.newSource('assets/alienshooter/sounds/fire.wav', 'stream'),
}

chaos = ChaosController()

Session = require 'src.core.Session'
screenWidth = VIRTUAL_WIDTH
screenHeight = VIRTUAL_HEIGHT

-- Player settings
PLAYER_SCALAR = 0.8
player = {
    x = 50, 
    y = screenHeight / 2,
    speed = 230
}

-- Bullets settings
bullets = {}
bulletSpeed = 200 
bulletWidth = 4
bulletHeight = 2

-- Enemies settings
enemies = {}
enemySpeed = 150 
defaultSpanTimer = 1.0
spawnTimer = defaultSpanTimer

victimEndpointTimer = 0
victimEndpointInterval = 2
backendVictims = chaos:countPod()
Session.startTime=os.time()

-- Assets
playerImage = nil
enemyImage = nil
local ENEMY_SCALAR = 0.8


function AlienShooterState:enter()
    love.graphics.setDefaultFilter("nearest", "nearest")

    playerImage = love.graphics.newImage("assets/alienshooter/graphics/spaceship.png")
    player.width = playerImage:getWidth() * PLAYER_SCALAR
    player.height = playerImage:getHeight() * PLAYER_SCALAR


    enemyImage = love.graphics.newImage("assets/alienshooter/graphics/alienship.png")
    enemyBaseWidth = enemyImage:getWidth()
    enemyBaseHeight = enemyImage:getHeight()
end

function AlienShooterState:update(dt)
    victimEndpointTimer = victimEndpointTimer + dt
    if victimEndpointTimer >= victimEndpointInterval then
        local newVictimCount = chaos:countPod() or 0
        if newVictimCount > #enemies then
            local diff = newVictimCount - #enemies
            for i = 1, diff do
                table.insert(enemies, {
                    x = screenWidth + (enemyBaseWidth * ENEMY_SCALAR),
                    y = math.random(enemyBaseHeight * ENEMY_SCALAR, screenHeight - (enemyBaseHeight * ENEMY_SCALAR)),
                    width = enemyBaseWidth * ENEMY_SCALAR,
                    height = enemyBaseHeight * ENEMY_SCALAR
                })
            end
        end
        backendVictims = newVictimCount
        victimEndpointTimer = 0
    end

    -- keyboard management init
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    elseif love.keyboard.wasPressed('space') then
        gSounds['fire']:play()
        print("[AlienShooterState] Space pressed! Projectile generated.")
        table.insert(bullets, {
            x = player.x + player.width / 2,
            y = player.y,
            width = bulletWidth,
            height = bulletHeight
        })
    end
    -- keyboard management end

    -- player boundaries
    player.y = math.max(player.height / 2, math.min(screenHeight - player.height / 2, player.y))

    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.x = bullet.x + bulletSpeed * dt
        if bullet.x > screenWidth then
            table.remove(bullets, i)
        end
    end

    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.x = enemy.x - enemySpeed * dt
        if enemy.x < -(enemy.width) then -- Use enemy.width to check if enemy is out of the screen
            table.remove(enemies, i)
        end
    end

    spawnTimer = spawnTimer - dt
    if spawnTimer <= 0 and #enemies < backendVictims then
        table.insert(enemies, {
            x = screenWidth + (enemyBaseWidth * ENEMY_SCALAR),
            y = math.random(enemyBaseHeight * ENEMY_SCALAR, screenHeight - (enemyBaseHeight * ENEMY_SCALAR)),
            width = enemyBaseWidth * ENEMY_SCALAR,
            height = enemyBaseHeight * ENEMY_SCALAR
        })
        spawnTimer = defaultSpanTimer-- Reset spawn timer
    end

    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            -- Collision detection
            if bullet.x < enemy.x + enemy.width and
               bullet.x + bullet.width > enemy.x and
               bullet.y < enemy.y + enemy.height and
               bullet.y + bullet.height > enemy.y then
                table.remove(bullets, i)
                table.remove(enemies, j)
                chaos:removePod()
                goto next_bullet
            end
        end
        ::next_bullet::
    end
    -- Check enemies
    if backendVictims == 0 then
        Session.endTime=os.time()
        gSounds['music']:stop()
        gStateMachine:change('win')
    end
end

function AlienShooterState:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(playerImage,
                       player.x - player.width / 2,
                       player.y - player.height / 2,
                       0, -- Rotation
                       PLAYER_SCALAR, PLAYER_SCALAR
    )

    love.graphics.setColor(1, 1, 0)
    for _, bullet in ipairs(bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y - bullet.height / 2, bullet.width, bullet.height)
    end

    love.graphics.setColor(1, 1, 1)
    for _, enemy in ipairs(enemies) do
        -- Draw alien image
        love.graphics.draw(enemyImage,
                           enemy.x - enemy.width / 2,
                           enemy.y - enemy.height / 2,
                           0, -- Rotation
                           ENEMY_SCALAR, ENEMY_SCALAR
        )
    end

    love.graphics.setColor(1, 1, 1)
    drawTextWithGlowLimitWidth("ACTIVE ENEMIES: " .. #enemies .. " DESTROYED ENEMIES: " .. Session.count, 10, VIRTUAL_WIDTH)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function AlienShooterState:keypressed(key)
end
