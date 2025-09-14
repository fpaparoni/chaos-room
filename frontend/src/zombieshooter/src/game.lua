-- General game logic and common stuff among all states.
local G = love.graphics

game = {
  background = G.newImage("src/zombieshooter/assets/sprites/bg.png"),
  current_state = "menu",
  font = G.newFont(40),
  score = 0
}

function game:load()
  self.current_state = "menu"
  self:resetScore()
end

function game:draw()
  G.draw(self.background, 0, 0)
  G.setFont(self.font)
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
