require("src/zombieshooter/lib/table")

local utils = require("src/zombieshooter/lib/utils")

local G = love.graphics
local K = love.keyboard
local M = love.mouse

player = {
  bullets = require("src/zombieshooter/src/bullets"),
  speed = 180,
  sprite = G.newImage("src/zombieshooter/assets/sprites/player.png"),
  x = G.getWidth() / 2,
  y = G.getHeight() / 2
}

function player:update(dt)
  self:move(dt)
end

function player:draw()
  G.draw(
    self.sprite, self.x, self.y, self:getDirection(), nil, nil,
    self.sprite:getWidth() / 2, self.sprite:getHeight() / 2
  )
end

function player:setX(x)
  self.x = x
end

function player:setY(y)
  self.y = y
end

function player:getPosition()
  return {x = self.x, y = self.y}
end

function player:resetPosition()
  self:setX(love.graphics.getWidth() / 2)
  self:setY(love.graphics.getHeight() / 2)
end

function player:getDirection()
  local joysticks = love.joystick.getJoysticks()
  local joystick = joysticks[1]

  if joystick then
    local lx = joystick:getAxis(3) -- right stick X
    local ly = joystick:getAxis(4) -- right stick Y
    if math.abs(lx) > 0.2 or math.abs(ly) > 0.2 then
      return math.atan2(ly, lx)
    end
  end

  -- fallback: mouse
  return math.atan2(self.y - love.mouse.getY(), self.x - love.mouse.getX()) + math.rad(180)
end

function player:move(dt)
  local isOnScreen = utils.isOnScreen
  local realSpeed = self.speed * dt

  local moveUp = function(dt) self:setY(self.y - realSpeed) end
  local moveDown = function(dt) self:setY(self.y + realSpeed) end
  local moveLeft = function(dt) self:setX(self.x - realSpeed) end
  local moveRight = function(dt) self:setX(self.x + realSpeed) end

  if K.isDown("w") and isOnScreen(self, "top") then moveUp() end
  if K.isDown("s") and isOnScreen(self, "bottom") then moveDown() end
  if K.isDown("a") and isOnScreen(self, "left") then moveLeft() end
  if K.isDown("d") and isOnScreen(self, "right") then moveRight() end
end

function player:shoot()
  bullets:spawn(nil, self)
end
