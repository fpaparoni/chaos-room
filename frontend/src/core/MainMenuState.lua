MainMenuState = Class{__includes = BaseState}

function MainMenuState:init()
    self.options = {'Breakout', 'Temp1 (disabled)', 'Temp2 (disabled)'}
    self.currentSelection = 1
end

function MainMenuState:update(dt)
    if love.keyboard.wasPressed('up') then
        self.currentSelection = self.currentSelection == 1 and #self.options or self.currentSelection - 1
    elseif love.keyboard.wasPressed('down') then
        self.currentSelection = self.currentSelection == #self.options and 1 or self.currentSelection + 1
    elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        if self.currentSelection == 1 then
            -- Carica dinamicamente le dipendenze di Breakout
            require 'src/breakout/Dependencies'
            local ball = Ball()
            ball.skin = 1       -- assegna un tipo di palla (ci sono sprite diversi)
            ball:reset()  
        
            local paddle = Paddle()
            paddle.skin = 1
        
            gStateMachine:change('play', {
                paddle = paddle,
                bricks = LevelMaker.createMap(1),
                health = 3,
                score = 0,
                highScores = {},
                ball = ball,
                level = 1,
                recoverPoints = 5000
            })
        
            -- play our music outside of all states and set it to looping
            gSounds['music']:play()
            gSounds['music']:setLooping(true)
            gSounds['music']:setVolume(0.15)
        
            -- a table we'll use to keep track of which keys have been pressed this
            -- frame, to get around the fact that LÖVE's default callback won't let us
            -- test for input from within other functions
            love.keyboard.keysPressed = {}
        end
    end
end

function MainMenuState:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Mini Arcade', 0, 40, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])

    for i, option in ipairs(self.options) do
        local y = 100 + i * 20
        if i == self.currentSelection then
            love.graphics.setColor(0.2, 0.8, 0.2, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.printf(option, 0, y, VIRTUAL_WIDTH, 'center')
    end
end
