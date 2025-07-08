-- AlienShooterState.lua
AlienShooterState = Class{__includes = BaseState}

local Game = require 'src.alienshooter.Game' 

function AlienShooterState:enter()
    Game.load()
end

function AlienShooterState:update(dt)
    Game.update(dt)

    -- Permette di tornare al menu premendo ESC
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    elseif love.keyboard.wasPressed('space') then
        Game.keypressed('space')
    end
end

function AlienShooterState:render()
    Game.draw()
end

function AlienShooterState:keypressed(key)
    Game.keypressed(key)
end
