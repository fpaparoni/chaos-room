-- Game.lua (il tuo modulo per lo shooter)
-- Integra questo in un sistema che usa push per la risoluzione virtuale
require 'src/core/ChaosController'
require 'src/core/Util'

local Game = {}
local chaos = ChaosController()
local Session = require 'src.core.Session'
-- *******************************************************************
-- MODIFICHE QUI: Usa le variabili globali (o passale come parametri)
-- definite dal tuo sistema di menu principale che usa 'push'.
-- Assicurati che WINDOW_WIDTH, WINDOW_HEIGHT, VIRTUAL_WIDTH, VIRTUAL_HEIGHT
-- siano accessibili qui (solitamente sono globali nel main.lua principale
-- o passati come parte di un contesto di gioco).
-- Per questo esempio, assumiamo che siano globali.
-- *******************************************************************
Game.screenWidth = VIRTUAL_WIDTH*2 -- Ora usa la larghezza virtuale
Game.screenHeight = VIRTUAL_HEIGHT*2 -- Ora usa l'altezza virtuale

-- Giocatore
Game.player = {
    x = 50, -- Sposta la navicella più a sinistra nella vista virtuale
    y = Game.screenHeight / 2,
    speed = 200 -- Riduci la velocità, dato che lo schermo è più piccolo
}

Game.bullets = {}
Game.bulletSpeed = 300 -- Riduci la velocità dei proiettili
Game.bulletWidth = 7   -- Riduci la dimensione dei proiettili
Game.bulletHeight = 3

-- Nemici
Game.enemies = {}
Game.enemySpeed = 120 -- Riduci la velocità dei nemici
Game.spawnTimer = 1.5 -- Aumenta leggermente il timer di spawn per avere meno nemici inizialmente
                      -- dato lo spazio più piccolo

Game.victimEndpointTimer = 0
Game.victimEndpointInterval = 3
Game.backendVictims = chaos:queryExternalBrickCount()
Session.startTime=os.time()

-- Assets
Game.playerImage = nil
Game.enemyImage = nil
-- Game.enemySize verrà impostato in base all'immagine, ma potremmo scalarlo
local ENEMY_SCALAR = 0.8 -- Scala i nemici per farli sembrare più piccoli in questa risoluzione

function Game.load()
    push:setupScreen(VIRTUAL_WIDTH*2, VIRTUAL_HEIGHT*2, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    love.graphics.setDefaultFilter("nearest", "nearest")

    Game.playerImage = love.graphics.newImage("assets/alienshooter/graphics/spaceship.png")
    Game.player.width = Game.playerImage:getWidth()
    Game.player.height = Game.playerImage:getHeight()

    Game.enemyImage = love.graphics.newImage("assets/alienshooter/graphics/alienship.png")
    Game.enemyBaseWidth = Game.enemyImage:getWidth()
    Game.enemyBaseHeight = Game.enemyImage:getHeight()
end

function Game.callGetVictimsEndpoint()
    return chaos:queryExternalBrickCount()
end

function Game.callKillVictimEndpoint()
    chaos:removeBrick()
end

function Game.update(dt)
    Game.victimEndpointTimer = Game.victimEndpointTimer + dt
    if Game.victimEndpointTimer >= Game.victimEndpointInterval then
        local newVictimCount = Game.callGetVictimsEndpoint() or 0
        if newVictimCount > #Game.enemies then
            local diff = newVictimCount - #Game.enemies
            for i = 1, diff do
                table.insert(Game.enemies, {
                    -- Usiamo le dimensioni scalate per il posizionamento
                    x = Game.screenWidth + (Game.enemyBaseWidth * ENEMY_SCALAR),
                    y = math.random(Game.enemyBaseHeight * ENEMY_SCALAR, Game.screenHeight - (Game.enemyBaseHeight * ENEMY_SCALAR)),
                    width = Game.enemyBaseWidth * ENEMY_SCALAR,
                    height = Game.enemyBaseHeight * ENEMY_SCALAR
                })
            end
        end
        Game.backendVictims = newVictimCount
        Game.victimEndpointTimer = 0
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        Game.player.y = Game.player.y - Game.player.speed * dt
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        Game.player.y = Game.player.y + Game.player.speed * dt
    end
    -- Limiti basati sulla risoluzione virtuale e dimensioni reali scalate del player
    Game.player.y = math.max(Game.player.height / 2, math.min(Game.screenHeight - Game.player.height / 2, Game.player.y))

    for i = #Game.bullets, 1, -1 do
        local bullet = Game.bullets[i]
        bullet.x = bullet.x + Game.bulletSpeed * dt
        if bullet.x > Game.screenWidth then
            table.remove(Game.bullets, i)
        end
    end

    for i = #Game.enemies, 1, -1 do
        local enemy = Game.enemies[i]
        enemy.x = enemy.x - Game.enemySpeed * dt
        if enemy.x < -(enemy.width) then -- Usa enemy.width per il controllo fuori schermo
            table.remove(Game.enemies, i)
        end
    end

    Game.spawnTimer = Game.spawnTimer - dt
    if Game.spawnTimer <= 0 and #Game.enemies < Game.backendVictims then
        table.insert(Game.enemies, {
            x = Game.screenWidth + (Game.enemyBaseWidth * ENEMY_SCALAR),
            y = math.random(Game.enemyBaseHeight * ENEMY_SCALAR, Game.screenHeight - (Game.enemyBaseHeight * ENEMY_SCALAR)),
            width = Game.enemyBaseWidth * ENEMY_SCALAR,
            height = Game.enemyBaseHeight * ENEMY_SCALAR
        })
        Game.spawnTimer = 1.5 -- Resetta il timer di spawn
    end

    for i = #Game.bullets, 1, -1 do
        local bullet = Game.bullets[i]
        for j = #Game.enemies, 1, -1 do
            local enemy = Game.enemies[j]
            -- Collisione AABB
            if bullet.x < enemy.x + enemy.width and
               bullet.x + bullet.width > enemy.x and
               bullet.y < enemy.y + enemy.height and
               bullet.y + bullet.height > enemy.y then
                table.remove(Game.bullets, i)
                table.remove(Game.enemies, j)
                Game.callKillVictimEndpoint()
                goto next_bullet
            end
        end
        ::next_bullet::
    end
end

function Game.keypressed(key)
    if key == "space" then
        print("Spazio premuto! Proiettile generato.")
        table.insert(Game.bullets, {
            x = Game.player.x + Game.player.width / 2,
            y = Game.player.y,
            width = Game.bulletWidth,
            height = Game.bulletHeight
        })
    end
end

function Game.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Game.playerImage,
                       Game.player.x - Game.player.width / 2,
                       Game.player.y - Game.player.height / 2
    )

    love.graphics.setColor(1, 1, 0)
    for _, bullet in ipairs(Game.bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y - bullet.height / 2, bullet.width, bullet.height)
    end

    love.graphics.setColor(1, 1, 1)
    for _, enemy in ipairs(Game.enemies) do
        -- Disegna l'immagine dell'alieno scalata
        love.graphics.draw(Game.enemyImage,
                           enemy.x - enemy.width / 2,
                           enemy.y - enemy.height / 2,
                           0, -- Rotazione
                           ENEMY_SCALAR, ENEMY_SCALAR -- Scala X e Y
        )
    end

    love.graphics.setColor(1, 1, 1)
    drawTextWithGlowLimitWidth("ACTIVE ENEMIES: " .. #Game.enemies .. " DESTROYED ENEMIES: " .. Session.count, 10, VIRTUAL_WIDTH*2)
end

return Game