--[[
    GD50
    Breakout Remake

    -- GameOverState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The state in which we've lost all of our health and get our score displayed to us.
]]

GameOverState = Class{__includes = BaseState}

Session = require 'src.core.Session'

function GameOverState:enter(params)
    self.score = params.score
end

function GameOverState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function GameOverState:render()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Final Score: ' .. Session.count, 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter!', 0, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)
end