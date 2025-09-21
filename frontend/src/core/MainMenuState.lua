require 'src/core/WinState'
local Session = require 'src.core.Session'
MainMenuState = Class{__includes = BaseState}
textColor = {0, 1, 0} 
logoImage = love.graphics.newImage("assets/logo.png")

function MainMenuState:init()
    self.options = {'Breakout', 'Alien shooter', 'Zombie shooter'}
    self.currentSelection = 1

    self.phase = 'splash'      -- 'splash', 'input', 'menu'
    self.timer = 0

    self.inputBuffer = { host = '', port = '' }
    self.currentField = 'host'
end

function MainMenuState:update(dt)
    if self.phase == 'splash' then
        self.timer = self.timer + dt
        if self.timer >= 3 then
            self.phase = 'input'
        end

    elseif self.phase == 'input' then
        -- Scrittura input host/port
        if love.keyboard.wasPressed('backspace') then
            local field = self.inputBuffer[self.currentField]
            self.inputBuffer[self.currentField] = field:sub(1, -2)
        end

        for i = 32, 126 do
            if love.keyboard.wasPressed(string.char(i)) then
                self.inputBuffer[self.currentField] = self.inputBuffer[self.currentField] .. string.char(i)
            end
        end

        if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
            if self.currentField == 'host' then
                self.currentField = 'port'
            else
                -- Salva nella Sessione e passa al menu
                Session.host = self.inputBuffer.host
                Session.port = self.inputBuffer.port
                self.phase = 'menu'
            end
        end

    elseif self.phase == 'menu' then
        if love.keyboard.wasPressed('up') then
            self.currentSelection = self.currentSelection == 1 and #self.options or self.currentSelection - 1
        elseif love.keyboard.wasPressed('down') then
            self.currentSelection = self.currentSelection == #self.options and 1 or self.currentSelection + 1
        elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
            if self.currentSelection == 1 then
                require 'src.breakout.Dependencies'

                local ball = Ball()
                ball.skin = 1
                ball:reset()

                local paddle = Paddle()
                paddle.skin = 1

                gStateMachine:change('play', {
                    paddle = paddle,
                    bricks = LevelMaker.createMap(1,chaos:countPod()),
                    health = 3,
                    score = 0,
                    ball = ball,
                    level = 1,
                    recoverPoints = 5000
                })

                gSounds['music']:play()
                gSounds['music']:setLooping(true)
                gSounds['music']:setVolume(0.15)

                love.keyboard.keysPressed = {}
            elseif self.currentSelection == 2 then
                require 'src.alienshooter.AlienShooterState'
                gStateMachine = StateMachine {
                    ['win'] = function() return WinState() end,
                    ['alienshooter'] = function() return AlienShooterState() end
                }
                gStateMachine:change('alienshooter')
                gSounds['music']:play()
                gSounds['music']:setLooping(true)
                gSounds['music']:setVolume(0.4)
            elseif self.currentSelection == 3 then
                require 'src.zombieshooter.TopDownState'
                gStateMachine = StateMachine {
                    ['win'] = function() return WinState() end,
                    ['zombieshooter'] = function() return TopDownState() end
                }
                gStateMachine:change('zombieshooter')
                gSounds['music']:play()
                gSounds['music']:setLooping(true)
                gSounds['music']:setVolume(0.4)
            end
        end
    end
end

function MainMenuState:render()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(textColor)
    if self.phase == 'splash' then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            logoImage,
            (VIRTUAL_WIDTH - logoImage:getWidth()) / 2,
            (VIRTUAL_HEIGHT - logoImage:getHeight()) / 2
        )

    elseif self.phase == 'input' then
        love.graphics.setColor(textColor)
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('ENTER ' .. self.currentField .. ':', 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(0.6, 1, 0.6, 1)
        love.graphics.printf(self.inputBuffer[self.currentField], 0, 130, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)

    elseif self.phase == 'menu' then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('SHALL WE PLAY A GAME?', 0, 40, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(gFonts['large'])

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
end
