TopDownState = Class{__includes = BaseState}

require("src/zombieshooter/lib/table")
require("src/zombieshooter/src/game")
require("src/zombieshooter/src/player")
require("src/zombieshooter/src/zombies")
require("src/core/ChaosController")
gSounds = {
    ['music']       = love.audio.newSource('assets/zombieshooter/sounds/main.mp3', 'stream'),
    ['fire']       = love.audio.newSource('assets/zombieshooter/sounds/fire.mp3', 'stream'),
}

local G = love.graphics
local collisions = require("src/zombieshooter/src/collisions")

local Session = require 'src.core.Session'
chaos = ChaosController()

local activeEnemy=-1
local podUpdateTimer = 0
local podUpdateInterval = 1

function TopDownState:enter()
    WIN_VIRTUAL_WIDTH = G.getWidth()
    WIN_VIRTUAL_HEIGHT = G.getHeight()
    WINDOW_WIDTH = G.getWidth()
    WINDOW_HEIGHT = G.getHeight()
    push:setupScreen(WIN_VIRTUAL_WIDTH, WIN_VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    game:load()
    Session.startTime = os.time()
end

function TopDownState:update(dt)
    if game:isMenu() then
    elseif game:isPlaying() then
      podUpdateTimer = podUpdateTimer + dt
      if podUpdateTimer >= podUpdateInterval then
          activeEnemy = chaos:countPod() or 0
          podUpdateTimer = 0
      end

      player:update(dt)
      player.bullets:update(dt)
      zombies:update(activeEnemy,dt)
  
      collisions:betweenZombiesAndBullets()
    end
    if love.keyboard.wasPressed('escape') then
      love.event.quit()
    end
end

function TopDownState:render()
    local w, h = love.graphics.getDimensions()
    game.width = w
    game.height = h

    player.x = w / 2
    player.y = h / 2

    game:draw()

    if game:isMenu() then
      drawTextWithGlowLimitWidth("Click anywhere to begin",40,G.getWidth())
    end
    
    drawTextWithGlowLimitWidth("ACTIVE ENEMIES: " .. activeEnemy .. " DESTROYED ENEMIES: " .. Session.count, 10, G.getWidth())

        -- Check enemies
    if activeEnemy == 0 then
      love.graphics.setCanvas() 
      Session.endTime=os.time()
      gSounds['music']:stop()
      gStateMachine:change('win')
    end

    player:draw()
    player.bullets:draw()
    zombies:draw()
end

function TopDownState:keypressed(key, scancode, isrepeat)
end

function TopDownState:mousepressed(x, y, button, istouch, presses)
    if game:isMenu() then
        if not btnCode == 2 then return end
    
        game:startPlaying()
        zombies:resetSpawnCountdown()
    
      elseif game:isPlaying() then
        if not btnCode == 1 then return end
    
        player.bullets:spawn()
      end
end
