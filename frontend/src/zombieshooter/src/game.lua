-- General game logic and common stuff among all states.
local G = love.graphics

game = {
  background = G.newImage("src/zombieshooter/assets/sprites/bg.png"),
  current_state = "menu",
  font = G.newFont(20),
  score = 0
}

function game:load()
  self.current_state = "menu"
  self:resetScore()
  G.setFont(self.font)
end

function game:draw()
  drawGrassBackground() 
end

function drawGrassBackground()
  local w, h = love.graphics.getDimensions()
  local tileSize = 4  

  for x = 0, w, tileSize do
      for y = 0, h, tileSize do
          local r, g, b = 120, 180, 50

          if math.random() > 0.8 then
              g = g - math.random(20, 50)
          end

          love.graphics.setColor(r/255, g/255, b/255)
          love.graphics.rectangle("fill", x, y, tileSize, tileSize)
      end
  end

  love.graphics.setColor(1, 1, 1)
end


-- Game state
function game:goToMenu()
  self.current_state = "menu"
end

function game:startPlaying()
  self.current_state = "playing"
  self:resetScore()
end

function game:isMenu()
  return self.current_state == "menu"
end

function game:isPlaying()
  return self.current_state == "playing"
end

function game:isGameOver()
end

-- Score
function game:increaseScoreBy(n)
  self.score = self.score + n
end

function game:resetScore()
  self.score = 0
end
