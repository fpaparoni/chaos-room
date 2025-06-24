--[[
    GD50
    Breakout Remake

    -- ServeState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The state in which we are waiting to serve the ball; here, we are
    basically just moving the paddle left and right with the ball until we
    press Enter, though everything in the actual game now should render in
    preparation for the serve, including our current health and score, as
    well as the level we're on.
]]

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.recoverPoints = params.recoverPoints
    self.debugOn = params.debugOn
    -- init new ball (random color for fun)
    self.balls = {}
    table.insert(self.balls, params.ball)
    self.balls[1].skin = math.random(7)

    self.brickCount = 0
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            self.brickCount = self.brickCount + 1
        end
    end

    self.hasKey = params.hasKey
end

function ServeState:update(dt)
    -- have the ball track the player
    self.paddle:update(dt)
    self.balls[1].x = self.paddle.x + (self.paddle.width / 2) - 4
    self.balls[1].y = self.paddle.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            ball = self.balls[1],
            level = self.level,
            recoverPoints = self.recoverPoints,
            hasKey = self.hasKey,
            debugOn = self.debugOn
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    elseif love.keyboard.wasPressed('tab') then
        if self.debugOn then
            self.debugOn = false
        else
            self.debugOn = true
        end
    end
end

function ServeState:render()
    self.paddle:render()
    self.balls[1]:render()

    if self.hasKey then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][10],
        8, VIRTUAL_HEIGHT - 24)
    end

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)

    if self.debugOn then
        debugMode(self.ballCount, self.brickCount, self.recoverPoints, self.balls)
    end
end