require 'src/core/Util'
local Session = require 'src.core.Session'

WinState = Class{__includes = BaseState}

function WinState:enter()
    WIN_VIRTUAL_WIDTH = 432*2
    WIN_VIRTUAL_HEIGHT = 243*2
    WINDOW_WIDTH = 1280
    WINDOW_HEIGHT = 720
    push:setupScreen(WIN_VIRTUAL_WIDTH, WIN_VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    self.image = love.graphics.newImage('assets/shared/graphics/victory.png')
    self.music = love.audio.newSource('assets/shared/sounds/victory.mp3', 'stream')
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

    local imgWidth = self.image:getWidth()
    local imgHeight = self.image:getHeight()
    local imgX = (WIN_VIRTUAL_WIDTH - imgWidth) / 2
    local imgY = (WIN_VIRTUAL_HEIGHT / 4 - imgHeight / 2)+30
    love.graphics.draw(self.image, imgX, imgY)

    love.graphics.printf('You won!\nChaos victims: ' .. Session.count .. '\nTime:'.. duration ..' seconds\n\nPress enter to exit', 0, (WIN_VIRTUAL_HEIGHT / 2)+40, WIN_VIRTUAL_WIDTH, 'center')
end
