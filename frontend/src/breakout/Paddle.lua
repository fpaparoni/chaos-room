--[[
    GD50
    Breakout Remake

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move left and right. Used in the main
    program to deflect the ball toward the bricks; if the ball passes
    the paddle, the player loses one heart. The Paddle can have a skin,
    which the player gets to choose upon starting the game.
]]

Paddle = Class{}

--[[
    Our Paddle will initialize at the same spot every time, in the middle
    of the world horizontally, toward the bottom.
]]
function Paddle:init(skin)
    -- x is placed in the middle
    self.x = VIRTUAL_WIDTH / 2 - 32

    -- y is placed a little above the bottom edge of the screen
    self.y = VIRTUAL_HEIGHT - 32

    -- start us off with no velocity
    self.dx = 0

    -- starting dimensions
    self.width = 64
    self.height = 16

    -- the skin only has the effect of changing our color, used to offset us
    -- into the gPaddleSkins table later
    self.skin = skin

    -- the variant is which of the four paddle sizes we currently are; 2
    -- is the starting size, as the smallest is too tough to start with
    self.size = 2
end

function Paddle:update(dt)
    -- size update
    if self.size == 1 then
        self.width = 32
    elseif self.size == 2 then
        self.width = 64
    elseif self.size == 3 then
        self.width = 96
    elseif self.size == 4 then
        self.width = 128
    end

    -- keyboard
    local moveLeft = love.keyboard.isDown('left')
    local moveRight = love.keyboard.isDown('right')

    -- joystick (if any available)
    local joysticks = love.joystick.getJoysticks()
    local joystick = joysticks[1] 

    if joystick and joystick:isGamepad() then
        -- analogic
        local axis = joystick:getGamepadAxis("leftx")
        if axis < -0.2 then
            moveLeft = true
        elseif axis > 0.2 then
            moveRight = true
        end

        -- D-Pad
        if joystick:isGamepadDown("dpleft") then
            moveLeft = true
        end
        if joystick:isGamepadDown("dpright") then
            moveRight = true
        end
    end

    -- logic
    if moveLeft then
        self.dx = -PADDLE_SPEED
    elseif moveRight then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    -- screen boundaries
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end


--[[
    Render the paddle by drawing the main texture, passing in the quad
    that corresponds to the proper skin and size.
]]
function Paddle:render()
    love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)],
        self.x, self.y)
end