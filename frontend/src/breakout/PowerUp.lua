--[[
    GD50
    Breakout Remake

    -- Power Up Class --

    Author: Ian Skelskey
    ianskelskey@gmail.com

    Represents power ups that drop from bricks randomly when they break. There will be two
    power ups in this game: a key that unlocks a locked block, and a ball multiplier.
]]

PowerUp = Class{}

--[[
    Power ups will initialize with their center in the same location as the center of the
    brick that they drop from.
]]
function PowerUp:init(brick)
    -- Borrow brick's location
    self.x = brick.x + 4
    self.y = brick.y + 2

    -- Power ups are always falling
    self.dy = POWERUP_SPEED

    -- starting dimensions
    self.width = 16
    self.height = 16
    -- Restricted to 6 & 7 (multiball & key) for submission
    self.type = math.random(1,7)
    self.graphicIndex = 0
    self.inPlay = false

    local allowedTypes = {3, 6}
    self.type = allowedTypes[math.random(1, #allowedTypes)]

    -- mappa tipo → grafica fissa
    local typeToGraphic = {
        [3] = 3,  -- Recover
        [6] = 9   -- Multi-ball
    }
    self.graphicIndex = typeToGraphic[self.type]
end
--[[
    Handles collision of powerup and other game elements
]]
function PowerUp:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end
--[[
    Power ups will fall straight down until they collide with the paddle or fall outside of
    the view frame.
]]
function PowerUp:update(dt)
    self.y = self.y + self.dy * dt
end

--[[
    Render the power ups by drawing the main texture, passing in the quad
    that corresponds to the proper skin and size.
]]
function PowerUp:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.graphicIndex],
        self.x, self.y)
end
