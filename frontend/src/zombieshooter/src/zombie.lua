require("src/zombieshooter/lib/table")

local G = love.graphics

local Zombie = function(x, y, speed)
  local zombie = {
    isAlive = true,
    speed = speed or 100,
    sprite = G.newImage("src/zombieshooter/assets/sprites/zombie.png"),
    x = x or 0,
    y = y or 0
  }

  function zombie:draw()
    G.draw(
      self.sprite, self.x, self.y, self:getDirection(), nil, nil,
      self.sprite:getWidth() / 2, self.sprite:getHeight() / 2
    )
  end

  function zombie:move(dt)
    self.x = self.x + math.cos(self:getDirection()) * self.speed * dt
    self.y = self.y + math.sin(self:getDirection()) * self.speed * dt
  end

  function zombie:getDirection()
    return math.atan2(self.y - player.y, self.x - player.x) + math.rad(180)
  end

  function zombie:getPosition()
    return {x = self.x, y = self.y}
  end

  function zombie:hasGotPlayer()
    return distanceBetween(player:getPosition(), self:getPosition()) < 30
  end

  return zombie
end

return Zombie
