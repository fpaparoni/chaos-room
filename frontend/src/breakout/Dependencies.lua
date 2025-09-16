-- Class system and push library
Class = require 'lib/class'
push = require 'lib/push'

-- Core utilities
require 'src/core/StateMachine'
require 'src/core/Util'
require 'src/core/BaseState'

-- Game states
require 'src/breakout/states/StartState'
require 'src/breakout/states/PlayState'
require 'src/breakout/states/ServeState'
require 'src/breakout/states/GameOverState'
require 'src/core/WinState'

-- Game objects
require 'src/breakout/Ball'
require 'src/breakout/Brick'
require 'src/core/ChaosController'
require 'src/breakout/constants'
require 'src/breakout/LevelMaker'
require 'src/breakout/PowerUp'
require 'src/breakout/Paddle'

-- Fonts (shared)
gFonts = {
    ['small']  = love.graphics.newFont('assets/breakout/fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('assets/breakout/fonts/font.ttf', 16),
    ['large']  = love.graphics.newFont('assets/breakout/fonts/font.ttf', 32),
    ['huge']   = love.graphics.newFont('assets/breakout/fonts/font.ttf', 64)
}

-- Graphics (game-specific)
-- load up the graphics we'll be using throughout our states
gTextures = {
    ['background'] = love.graphics.newImage('assets/breakout/graphics/background.png'),
    ['main'] = love.graphics.newImage('assets/breakout/graphics/breakout.png'),
    ['arrows'] = love.graphics.newImage('assets/breakout/graphics/arrows.png'),
    ['hearts'] = love.graphics.newImage('assets/breakout/graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('assets/breakout/graphics/particle.png')
}

-- Frames (quads)
gFrames = {
    ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main']),
    ['big-balls'] = GenerateQuadsBigBalls(gTextures['main']),
    ['small-balls'] = GenerateQuadsSmallBalls(gTextures['main']),
    ['bricks'] = GenerateQuadsBricks(gTextures['main']),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
    ['powerups'] = GenerateQuadsPowerUps(gTextures['main'])
}

-- Sounds (game-specific)
gSounds = {
    ['paddle-hit'] = love.audio.newSource('assets/breakout/sounds/paddle_hit.wav', 'static'),
    ['score']      = love.audio.newSource('assets/breakout/sounds/score.wav', 'static'),
    ['wall-hit']   = love.audio.newSource('assets/breakout/sounds/wall_hit.wav', 'static'),
    ['confirm']    = love.audio.newSource('assets/breakout/sounds/confirm.wav', 'static'),
    ['select']     = love.audio.newSource('assets/breakout/sounds/select.wav', 'static'),
    ['no-select']  = love.audio.newSource('assets/breakout/sounds/no-select.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('assets/breakout/sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('assets/breakout/sounds/brick-hit-2.wav', 'static'),
    ['hurt']        = love.audio.newSource('assets/breakout/sounds/hurt.wav', 'static'),
    ['recover']     = love.audio.newSource('assets/breakout/sounds/recover.wav', 'static'),
    ['pause']       = love.audio.newSource('assets/breakout/sounds/pause.wav', 'static'),
    ['powerup']     = love.audio.newSource('assets/breakout/sounds/powerup.wav', 'static'),
    ['music']       = love.audio.newSource('assets/breakout/sounds/music.wav', 'stream')
}

chaos = ChaosController()

playState = PlayState()
playState:setChaosController(chaos)

-- the state machine we'll be using to transition between various states
-- in our game instead of clumping them together in our update and draw
-- methods
--
-- our current game state can be any of the following:
-- 1. 'start' (the beginning of the game, where we're told to press Enter)
-- 2. 'paddle-select' (where we get to choose the color of our paddle)
-- 3. 'serve' (waiting on a key press to serve the ball)
-- 4. 'play' (the ball is in play, bouncing between paddles)
-- 5. 'win' (game won)
-- 6. 'game-over' (the player has lost; display score and allow restart)
gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['play'] = function() return playState end,
    ['serve'] = function() return ServeState() end,
    ['game-over'] = function() return GameOverState() end,
    ['win'] = function() return WinState() end,
    ['paddle-select'] = function() return PaddleSelectState() end
}

BRICK_COUNT = 30

--[[
    Renders hearts based on how much health the player has. First renders
    full hearts, then empty hearts for however much health we're missing.
]]
function renderHealth(health)
    -- start of our health rendering
    local healthX = VIRTUAL_WIDTH - 100

    -- render health left
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

--[[
    Renders the current FPS.
    Renders the current FPS.draw
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end

function displayBallCount(ballCount)
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('Ball Count: ' .. tostring(ballCount), 5, 15)
end

function displayBrickCount(brickCount)
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('Brick Count: ' .. tostring(brickCount), 5, 25)
end

function displayRecoverPoints(recoverPoints)
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('Points to recover: ' .. tostring(recoverPoints), 5, 35)
end

function displayBallSpeeds(balls)
    for k, ball in pairs(balls) do
        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(0, 255, 0, 255)
        love.graphics.print(tostring(k) .. 'Ball Speed: ' .. tostring(ball.speed), 5, 35 + k*10)
    end
end

function debugMode(ballCount, brickCount, recoverPoints, balls)
    displayFPS()
    displayBallCount(ballCount)
    displayBrickCount(brickCount)
    displayRecoverPoints(recoverPoints)
    displayBallSpeeds(balls)
end

--[[
    Simply renders the player's score at the top right, with left-side padding
    for the score number.
]]
function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:apply('start')

    -- background should be drawn regardless of state, scaled to fit our
    -- virtual resolution
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'],
        -- draw at coordinates 0, 0
        0, 0,
        -- no rotation
        0,
        -- scale factors on X and Y axis so it fills the screen
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    -- use the state machine to defer rendering to the current state we're in
    gStateMachine:render()

    if love.keyboard.wasPressed('tab') then
        -- display FPS for debugging; simply comment out to remove
        displayFPS()
    end


    push:apply('end')
end