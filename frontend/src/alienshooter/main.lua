-- main.lua
-- Uno shooter Love2D a scorrimento orizzontale con immagini PNG per Chaos Engineering

-- Dimensioni della finestra
local screenWidth = 900
local screenHeight = 600

-- Giocatore (navicella)
local player = {
    x = 100, -- Posizione fissa orizzontale (più a destra per mostrare bene la navicella)
    y = screenHeight / 2,
    speed = 200 -- Velocità di movimento verticale
}
local playerImage -- Variabile per l'immagine della navicella

-- Proiettili del giocatore
local bullets = {}
local bulletSpeed = 500
local bulletWidth = 12
local bulletHeight = 4

-- Nemici (le "vittime" del tuo sistema)
local enemies = {}
local enemySpeed = 100 -- Velocità con cui i nemici si muovono da destra a sinistra
-- enemySize verrà impostato dalle dimensioni dell'immagine dell'alieno
local enemyImage -- Variabile per l'immagine dell'alieno
local spawnTimer = 0.8 -- Quanto spesso appaiono nuovi nemici

-- Stato delle vittime dal backend (simulato per ora)
local backendVictims = 5 -- Numero iniziale di vittime dal tuo sistema
local victimEndpointTimer = 0 -- Timer per chiamare l'endpoint delle vittime
local victimEndpointInterval = 1 -- Ogni secondo chiamiamo l'endpoint (simulato)

-- Funzione per la chiamata agli endpoint (da implementare con LuaSocket o altro)
function callGetVictimsEndpoint()
    -- QUI DOVRESTI CHIAMARE IL TUO ENDPOINT REALE PER OTTENERE IL NUMERO DI VITTIME
    -- ESEMPIO SIMULATO:
    -- print("Chiamo l'endpoint 'getVictims'")
    -- In una vera implementazione, faresti una richiesta HTTP e aggiorneresti backendVictims
    -- Per ora, lo lasciamo invariato o lo manipoliamo per test
    return backendVictims
end

function callKillVictimEndpoint()
    -- QUI DOVRESTI CHIAMARE IL TUO ENDPOINT REALE PER UCCIDERE UNA VITTIMA
    -- ESEMPIO SIMULATO:
    -- print("Chiamo l'endpoint 'killVictim'")
    -- backendVictims = math.max(0, backendVictims - 1) -- Simula la diminuzione
end

-- Love2D: Inizializzazione del gioco
function love.load()
    love.window.setTitle("Chaos Horizontal Shooter")
    love.window.setMode(screenWidth, screenHeight)
    love.graphics.setDefaultFilter("nearest", "nearest") -- Per immagini pixel-art senza sfuocature
    math.randomseed(os.time()) -- Inizializza il generatore di numeri casuali

    -- CARICA L'IMMAGINE DELLA NAVICELLA
    playerImage = love.graphics.newImage("spaceship.png")
    -- Imposta la larghezza e altezza del giocatore basandoti sull'immagine
    player.width = playerImage:getWidth()
    player.height = playerImage:getHeight()

    -- CARICA L'IMMAGINE DELL'ALIENO
    enemyImage = love.graphics.newImage("alienship.png")
    -- Imposta la dimensione dei nemici basandoti sull'immagine (assumiamo un quadrato per semplicità)
    enemySize = enemyImage:getWidth() -- Oppure max(enemyImage:getWidth(), enemyImage:getHeight())
end

-- Love2D: Logica di aggiornamento del gioco
function love.update(dt)
    -- Aggiorna il timer per le chiamate agli endpoint
    victimEndpointTimer = victimEndpointTimer + dt
    if victimEndpointTimer >= victimEndpointInterval then
        local newVictimCount = callGetVictimsEndpoint()
        if newVictimCount > #enemies then
            -- Se le vittime dal backend sono aumentate, "resuscita" i nemici
            local diff = newVictimCount - #enemies
            for i = 1, diff do
                table.insert(enemies, {
                    x = screenWidth + enemySize, -- Appare da destra, fuori schermo
                    y = math.random(enemySize, screenHeight - enemySize),
                    width = enemyImage:getWidth(), -- Usa la larghezza dell'immagine alieno
                    height = enemyImage:getHeight() -- Usa l'altezza dell'immagine alieno
                })
            end
        end
        backendVictims = newVictimCount -- Aggiorna il conteggio interno
        victimEndpointTimer = 0
    end

    -- Movimento verticale del giocatore
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end
    -- Limita il giocatore entro i bordi verticali
    player.y = math.max(player.height / 2, math.min(screenHeight - player.height / 2, player.y))

    -- Aggiorna i proiettili
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.x = bullet.x + bulletSpeed * dt -- Si muovono verso destra
        if bullet.x > screenWidth then
            table.remove(bullets, i)
        end
    end

    -- Aggiorna i nemici (si muovono verso sinistra)
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.x = enemy.x - enemySpeed * dt
        if enemy.x < -enemy.width then -- Usa enemy.width per il controllo fuori schermo
            table.remove(enemies, i) -- Rimuovi nemici fuori schermo a sinistra
        end
    end

    -- Spawna nuovi nemici (se il numero è inferiore a backendVictims)
    spawnTimer = spawnTimer - dt
    if spawnTimer <= 0 and #enemies < backendVictims then
        table.insert(enemies, {
            x = screenWidth + enemySize, -- Appare da destra, fuori schermo
            y = math.random(enemySize, screenHeight - enemySize),
            width = enemyImage:getWidth(),
            height = enemyImage:getHeight()
        })
        spawnTimer = 0.8 -- Resetta il timer
    end

    -- Collisioni proiettili-nemici (AABB)
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            -- Rilevamento collisione AABB
            if bullet.x < enemy.x + enemy.width and       -- Il proiettile non è a destra dell'alieno
               bullet.x + bullet.width > enemy.x and       -- Il proiettile non è a sinistra dell'alieno
               bullet.y < enemy.y + enemy.height and       -- Il proiettile non è sotto l'alieno
               bullet.y + bullet.height > enemy.y then     -- Il proiettile non è sopra l'alieno
                table.remove(bullets, i) -- Rimuovi proiettile
                table.remove(enemies, j) -- Rimuovi nemico (vittima eliminata)
                callKillVictimEndpoint() -- Chiama l'endpoint per uccidere una vittima
                goto next_bullet -- Passa al prossimo proiettile (per evitare errori di indice dopo la rimozione)
            end
        end
        ::next_bullet:: -- Label per il goto
    end
end

-- Love2D: Gestione degli input (sparo)
function love.keypressed(key)
    if key == "space" then
        table.insert(bullets, {
            x = player.x + player.width / 2, -- Parte dal centro orizzontale della navicella
            y = player.y, -- Stessa altezza della navicella
            width = bulletWidth,
            height = bulletHeight
        })
    end
end

-- Love2D: Disegno degli elementi del gioco
function love.draw()
    -- Disegna il giocatore (navicella) usando l'immagine
    love.graphics.setColor(1, 1, 1) -- Colore bianco per disegnare l'immagine senza tinting
    love.graphics.draw(playerImage,
                       player.x - player.width / 2, -- Posizione X centrata
                       player.y - player.height / 2 -- Posizione Y centrata
    )

    -- Disegna i proiettili
    love.graphics.setColor(1, 1, 0) -- Giallo
    for _, bullet in ipairs(bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y - bullet.height / 2, bullet.width, bullet.height)
    end

    -- Disegna i nemici (immagini di alieni)
    love.graphics.setColor(1, 1, 1) -- Colore bianco per disegnare l'immagine senza tinting
    for _, enemy in ipairs(enemies) do
        love.graphics.draw(enemyImage,
                           enemy.x - enemy.width / 2, -- Posizione X centrata
                           enemy.y - enemy.height / 2 -- Posizione Y centrata
        )
    end

    -- Disegna il conteggio delle vittime (dal backend e attuali nel gioco)
    love.graphics.setColor(1, 1, 1) -- Bianco
    love.graphics.print("Vittime nel Backend (Simulate): " .. backendVictims, 10, 10)
    love.graphics.print("Vittime Attuali nel Gioco: " .. #enemies, 10, 30)
end
