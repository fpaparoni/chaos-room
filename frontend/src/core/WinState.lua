require 'src/core/Util'

local Session = require 'src.core.Session'

WinState = Class{__includes = BaseState}

function WinState:enter()
    self.image = love.graphics.newImage('assets/breakout/graphics/victory.png')
    self.music = love.audio.newSource('assets/breakout/sounds/victory.mp3', 'stream')
    self.music:setLooping(true)
    self.music:play()
end

function WinState:update(dt)
    if love.keyboard.wasPressed('return') then
        love.event.quit()  -- chiude il gioco
    end
end

function WinState:render()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setFont(gFonts['large'])
    duration = Session.endTime - Session.startTime
    love.graphics.printf('You won!\nChaos victims: ' .. Session.count .. '\nTime:'.. duration ..' seconds', 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
end
