--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]
local Session = require 'src.core.Session'
PlayState = Class{__includes = BaseState}


function PlayState:setChaosController(chaos)
    self.chaos = chaos
end

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)

    --for video
    self.keyCount = 0
    self.multiCount = 0

    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score

    self.level = params.level

    self.recoverPoints = params.recoverPoints

    self.chaos:saveInitialLayout(self.bricks)

    Session.startTime=os.time()

    self.balls = {}
    self.ballCount = 1
    self.powerups = {}
    table.insert(self.balls, params.ball)

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    -- Pass it false from the exit function of the start state or paddle select (wherever recoverPoints is set)
    self.hasKey = params.hasKey
    self.brickCount = 0
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            self.brickCount = self.brickCount + 1
        end
    end

    self.debugOn = params.debugOn
end

function PlayState:update(dt)

    for k, powerup in pairs(self.powerups) do
        if powerup.inPlay then
            powerup:update(dt)
            --[[
                Power Up Definitions
            ]]
            if powerup:collides(self.paddle) then
                if powerup.type == 6 then
                    self.multiCount = self.multiCount + 1
                elseif powerup.type == 7 then
                    self.keyCount = self.keyCount + 1
                end
                self.score = self.score + 50
                -- Play sound
                gSounds['powerup']:stop()
                gSounds['powerup']:play()
                if powerup.type == 1 then
                    -- Slow ball
                    for k, ball in pairs(self.balls) do
                        ball.dx = ball.dx * .85
                        ball.dy = ball.dy * .85
                    end
                elseif powerup.type == 2 then
                    -- Speed ball
                    for k, ball in pairs(self.balls) do
                        ball.dx = ball.dx * 1.15
                        ball.dy = ball.dy * 1.15
                    end
                elseif powerup.type == 3 then
                    -- Recover health
                    if self.health < 3 then
                        self.health = self.health + 1
                    end
                elseif powerup.type == 4 then
                    --Small Ball
                    for k, ball in pairs(self.balls) do
                        if ball.size > 0 then
                            ball.size = ball.size - 1
                        end
                    end
                elseif powerup.type == 5 then
                    --Big Ball
                    for k, ball in pairs(self.balls) do
                        if ball.size < 2 then
                            ball.size = ball.size + 1
                        end
                    end
                elseif powerup.type == 6 then
                    -- Multi-ball
                    -- Create two new balls
                    b1 = Ball(self.balls[1].skin)
                    b2 = Ball(self.balls[1].skin)
                    -- Make sure that new balls match size of original
                    if self.balls[1].size == 2 then
                    -- Large
                        b1.size = 2
                        b2.size = 2
                    elseif self.balls[1].size == 0 then
                    -- Small
                        b1.size = 0
                        b2.size = 0
                    else
                    -- Medium (Default)
                        b1.size = 1
                        b2.size = 1
                    end
                    -- Initialize new ball positions to match original
				    b1.x = self.balls[1].x
				    b1.y = self.balls[1].y
                    b2.x = self.balls[1].x
				    b2.y = self.balls[1].y		
                    -- Assign random trajectory
				    b1.dx = math.random(-200, 200) 
				    b1.dy = math.random(-50, -60)
				    b2.dx = math.random(-200, 200) 
				    b2.dy = math.random(-50, -60)
				    -- Add new balls to table
				    table.insert(self.balls, b1)
				    table.insert(self.balls, b2)
                    -- Update ballCount variable
                    self.ballCount = self.ballCount + 2
                elseif powerup.type == 7 then
                    --Key powerup
                    self.hasKey = true
                end
                powerup.inPlay = false
                table.remove(self.powerups, k)
            end
        end
    end

    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        if ball.inPlay then
            ball:update(dt)
        end


        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - ball.width
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
        
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                
                if brick.isLocked then
                    if self.hasKey then
                        brick:unlock()
                        self.hasKey = false
                    else
                        if self.brickCount == 1 then
                            powerup = PowerUp(brick)
                            powerup.inPlay = true
                            table.insert(self.powerups,powerup)
                        end
                    end
                else
                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                end
                -- trigger the brick's hit function, which removes it from play
                brick:hit()
                print("[DEBUG] Brick hit at x=" .. brick.x .. " y=" .. brick.y)
                self.chaos:removeBrick()
                if not brick.inPlay then
                    self.brickCount = self.brickCount - 1
                    if brick.hasPowerUp then
                        powerup = PowerUp(brick)
                        powerup.inPlay = true
                        table.insert(self.powerups,powerup)
                    end
                end
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    --  increase paddle size
                    if self.paddle.size < 4 then
                        self.paddle.size = self.paddle.size + 1
                    end
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)
                    
                    if self.score < 100000 then
                        -- multiply recover points by 2
                        self.recoverPoints = math.min(100000, self.recoverPoints * 2)
                    else
                        self.recoverPoints = self.recoverPoints + 100000
                    end
                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    Session.endTime=os.time()
                    gSounds['music']:stop()
                    gStateMachine:change('win')
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - ball.width
            
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
            
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - ball.width
            
                -- bottom edge if no X collisions or top collision, last possibility
                else
                
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        -- if ball goes below bounds, revert to serve state and decrease health
        if ball.y >= VIRTUAL_HEIGHT then
        -- Remove ball from balls table and from play
        ball.inPlay = false
        table.remove(self.balls, k)
            self.ballCount = self.ballCount - 1
            if self.ballCount < 1 then
                for k, brick in pairs(self.bricks) do
                    if not brick.inPlay then
                        table.remove(self.bricks, k)
                    end
                end
                self.health = self.health - 1
                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score
                    })
                else

                    gStateMachine:change('serve', {
                        ball = Ball(),
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        level = self.level,
                        recoverPoints = self.recoverPoints,
                        hasKey = self.hasKey,
                        debugOn = self.debugOn
                    })
                end
            end
        end
    end
    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    self.chaos:update(dt, self.bricks)

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

function PlayState:render()
    if self.hasKey then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][10],
        8, VIRTUAL_HEIGHT - 24)
    end

    for k, powerup in pairs(self.powerups) do
        if powerup.inPlay then
            powerup:render()
        end
    end
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
	for k, ball in pairs(self.balls) do
        if ball.inPlay then
            ball:render()
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    if self.debugOn then
        debugMode(self.ballCount, self.brickCount, self.recoverPoints, self.balls)
    end

end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

function PlayState:getBallCount()
    if balls == nil then
        return 0
    else
        return #balls
    end
end