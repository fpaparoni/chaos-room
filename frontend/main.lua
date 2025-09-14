Class = require 'lib/class'
push = require 'lib/push'

require 'src/core/StateMachine'
require 'src/core/BaseState'
require 'src/core/Util'
require 'src/core/MainMenuState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432*2
VIRTUAL_HEIGHT = 243*2

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Chaos Room")

    math.randomseed(os.time())

    gFonts = {
        ['small']  = love.graphics.newFont('assets/shared/fonts/VT323-Regular.ttf', 8),
        ['medium'] = love.graphics.newFont('assets/shared/fonts/VT323-Regular.ttf', 16),
        ['large']  = love.graphics.newFont('assets/shared/fonts/VT323-Regular.ttf', 32),
        ['verylarge']  = love.graphics.newFont('assets/shared/fonts/VT323-Regular.ttf', 64)
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    gStateMachine = StateMachine {
        ['main-menu'] = function() return MainMenuState() end,
        -- gli altri stati vengono registrati al volo dopo la scelta
    }

    gStateMachine:change('main-menu')

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.mousepressed(x, y, btnCode, isTouch)
    gStateMachine:mousepressed(x, y, btnCode, isTouch)
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end
