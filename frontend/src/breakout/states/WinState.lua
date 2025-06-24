WinState = Class{__includes = BaseState}

function WinState:enter()
    self.image = love.graphics.newImage('assets/breakout/graphics/victory.png')
    self.music = love.audio.newSource('assets/breakout/sounds/victory.mp3', 'stream')
    self.music:setLooping(true)
    self.music:play()
end

function WinState:update(dt)
    if love.keyboard.wasPressed('return') then
        love.event.quit()  -- chiude il gioco
    end
end

function WinState:render()
    -- calcola i fattori di scala in base alla risoluzione virtuale
    local scaleX = VIRTUAL_WIDTH / self.image:getWidth()
    local scaleY = VIRTUAL_HEIGHT / self.image:getHeight()
    
    -- usa il min per mantenere le proporzioni (letterbox effect)
    local scale = math.min(scaleX, scaleY)

    -- calcola offset per centrare l'immagine
    local offsetX = (VIRTUAL_WIDTH - self.image:getWidth() * scale) / 2
    local offsetY = (VIRTUAL_HEIGHT - self.image:getHeight() * scale) / 2

    -- disegna l'immagine scalata e centrata
    love.graphics.draw(self.image, offsetX, offsetY, 0, scale, scale)
end
