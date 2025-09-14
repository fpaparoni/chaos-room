require("src/zombieshooter/lib/table")

local utils = require("src/zombieshooter/lib/utils")

local G = love.graphics

local Bullet = function(speed, player)
  local bullet = {
    direction = player:getDirection(),
    isAlive = true,
    speed = 500,
    sprite = G.newImage("src/zombieshooter/assets/sprites/bullet.png"),
    x = player.x,
    y = player.y
  }

  function bullet:update(dt)
    bullet:move(dt)
  end

  function bullet:draw()
    G.draw(
      self.sprite, self.x, self.y, nil, 0.5, 0.5,
      self.sprite:getWidth() / 2, self.sprite:getHeight() / 2
    )
  end

  function bullet:move(dt)
    self:setX(self.x + math.cos(self.direction) * self.speed * dt)
    self:setY(self.y + math.sin(self.direction) * self.speed * dt)

    if self:isOffScreen() then
      self.isAlive = false
    end
  end

  function bullet:setX(x)
    self.x = x
  end

  function bullet:setY(y)
    self.y = y
  end

  function bullet:getPosition()
    return {x = self.x, y = self.y}
  end

  function bullet:isOffScreen()
    return self.x < 0 or self.x > G.getWidth() or self.y < 0 or self.y > G.getHeight()
  end

  return bullet
end

return Bullet
