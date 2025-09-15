local utils = require("src/zombieshooter/lib/utils")

local collisions = {}

function collisions:betweenZombieAndPlayer(zombie)
  local zombieGetsPlayer =
    utils.distanceBetween(player:getPosition(), zombie:getPosition()) < 30

  if zombieGetsPlayer then
    table.each(zombies, function(zombie) zombie.isAlive = false end)
    player:resetPosition()
    game:resetScore()
    game:goToMenu()
  end
end

function collisions:betweenZombiesAndBullets()
  local bulletHitsZombie = function(bullet, zombie)
    return utils.distanceBetween(zombie:getPosition(), bullet:getPosition()) <= 20
  end

  for _i, zombie in ipairs(zombies) do
    for _j, bullet in ipairs(player.bullets) do
      if bulletHitsZombie(bullet, zombie) then
        zombie.isAlive = false
        bullet.isAlive = false
        game:increaseScoreBy(1)
        ChaosController:removeBrick()
      end
    end
  end
end

return collisions
