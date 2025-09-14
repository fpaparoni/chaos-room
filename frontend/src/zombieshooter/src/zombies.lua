require("src/zombieshooter/lib/table")

local utils = require("src/zombieshooter/lib/utils")
local collisions = require("src/zombieshooter/src/collisions")

local Zombie = require("src/zombieshooter/src/zombie")

local G = love.graphics

zombies = {
  spawnInterval = 2,
  spawnCountdown = spawnInterval
}

function zombies:update(dt)
  self:decreaseSpawnCountdown(dt)
  if self.spawnCountdown <= 0 then self:spawn() end

  for _i, zombie in ipairs(self) do
    zombie:move(dt)
    collisions:betweenZombieAndPlayer(zombie)
  end

  zombies:removeDead()
end

function zombies:draw()
  table.each(self, function(zombie) zombie:draw() end)
end

function zombies:new(x, y, speed)
  return Zombie(x, y, speed)
end

function zombies:spawn(speed)
  local spawnPositions = {
    {math.random(0, G.getWidth()), -30}, -- Top
    {math.random(0, G.getWidth()), G.getHeight() + 30}, -- Bottom
    {-30, math.random(0, G.getHeight())}, -- Left
    {G.getWidth() + 30, math.random(0, G.getHeight())} -- Right
  }

  local x, y = unpack(spawnPositions[math.random(1, #spawnPositions)])

  table.insert(self, self:new(x, y, speed))

  self:restartSpawnCountdown()
end

function zombies:removeDead()
  table.reverseEach(
    self,
    function(zombie, i)
      if not zombie.isAlive then table.remove(zombies, i) end
    end
  )
end

function zombies:resetSpawnCountdown()
  self.spawnInterval = 2
  self.spawnCountdown = self.spawnInterval
end

function zombies:restartSpawnCountdown()
  self.spawnInterval = self.spawnInterval * 0.95
  self.spawnCountdown = self.spawnInterval
end

function zombies:decreaseSpawnCountdown(dt)
  self.spawnCountdown = self.spawnCountdown - dt
end
