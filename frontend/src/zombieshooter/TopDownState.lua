TopDownState = Class{__includes = BaseState}

require("src/zombieshooter/lib/table")
require("src/zombieshooter/src/game")
require("src/zombieshooter/src/player")
require("src/zombieshooter/src/zombies")

local G = love.graphics
local collisions = require("src/zombieshooter/src/collisions")

function TopDownState:enter()
    WIN_VIRTUAL_WIDTH = 800
    WIN_VIRTUAL_HEIGHT = 600
    WINDOW_WIDTH = 800
    WINDOW_HEIGHT = 600
    push:setupScreen(WIN_VIRTUAL_WIDTH, WIN_VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    game:load()
end

function TopDownState:update(dt)
    if game:isMenu() then
    elseif game:isPlaying() then
      player:update(dt)
      player.bullets:update(dt)
      zombies:update(dt)
  
      collisions:betweenZombiesAndBullets()
    end
end

function TopDownState:render()
    local w, h = love.graphics.getDimensions()
    game.width = w
    game.height = h

    -- resettare posizione iniziale player
    player.x = w / 2
    player.y = h / 2

    game:draw()

    if game:isMenu() then
      G.printf("Click anywhere to begin", 0, 50, G.getWidth(), "center")
    end
  
    G.printf("Score: " .. game.score, 0, G.getHeight() - 100, G.getWidth(), "center")
  
    player:draw()
    player.bullets:draw()
    zombies:draw()
end

function TopDownState:keypressed(key, scancode, isrepeat)
    print("keypressed")
end

function TopDownState:mousepressed(x, y, button, istouch, presses)
    print("mousepressed")
    if game:isMenu() then
        if not btnCode == 2 then return end
    
        game:startPlaying()
        zombies:resetSpawnCountdown()
    
      elseif game:isPlaying() then
        if not btnCode == 1 then return end
    
        player.bullets:spawn()
      end
end
