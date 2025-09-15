--[[
    Helper functions.
]]

--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

--[[
    Utility function for slicing tables, a la Python.

    https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice
]]
function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

--[[
    This function is specifically made to piece out the bricks from the
    sprite sheet. Since the sprite sheet has non-uniform sprites within,
    we have to return a subset of GenerateQuads.
]]
function GenerateQuadsBricks(atlas)
    return table.slice(GenerateQuads(atlas, 32, 16), 1, 24)
end

--[[
    This function is specifically made to piece out the paddles from the
    sprite sheet. For this, we have to piece out the paddles a little more
    manually, since they are all different sizes.
]]
function GenerateQuadsPaddles(atlas)
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        -- smallest
        quads[counter] = love.graphics.newQuad(x, y, 32, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- medium
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- large
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- huge
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16,
            atlas:getDimensions())
        counter = counter + 1

        -- prepare X and Y for the next set of paddles
        --x = 0
        y = y + 32
    end

    return quads
end

--[[
    This function is specifically made to piece out the balls from the
    sprite sheet. For this, we have to piece out the balls a little more
    manually, since they are in an awkward part of the sheet and small.
]]
function GenerateQuadsBalls(atlas)
    local x = 96
    local y = 48

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    x = 96
    y = 56

    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    return quads
end

function GenerateQuadsSmallBalls(atlas)
    local x = 0
    local y = 224

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 5, 5, atlas:getDimensions())
        x = x + 5
        counter = counter + 1
    end

    x = 0
    y = 229

    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, 5, 5, atlas:getDimensions())
        x = x + 5
        counter = counter + 1
    end

    return quads
end

function GenerateQuadsBigBalls(atlas)
    local x = 0
    local y = 208

    local counter = 1
    local quads = {}

    for i = 0, 6 do
        quads[counter] = love.graphics.newQuad(x, y, 11, 11, atlas:getDimensions())
        x = x + 11
        counter = counter + 1
    end

    return quads
end

function GenerateQuadsPowerUps(atlas)
    local x = 0
    local y = 192

    local counter = 1
    local quads = {}

    for i = 0, 9 do
        quads[counter] = love.graphics.newQuad(x, y, 16, 16, atlas:getDimensions())
        x = x + 16
        counter = counter + 1
    end

    return quads
end

--[[
    Draw text with a glow effect
]]
function drawTextWithGlow(text, x, y)
    love.graphics.setColor(0, 1, 0, 0.1)
    for dx = -2, 2 do
        for dy = -2, 2 do
            love.graphics.print(text, x + dx, y + dy)
        end
    end
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print(text, x, y)
end


function drawTextWithGlowLimitWidth(text, y, limitWidth)
    love.graphics.setColor(0, 1, 0, 0.1)
    for dx = -2, 2 do
        for dy = -2, 2 do
            love.graphics.printf(text, dx, y + dy, limitWidth, "center")
        end
    end
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.printf(text, 0, y, limitWidth, "center")
    love.graphics.setColor(1,1,1)
end

--[[
    Draw text with a glow effect, position based on the text and VIRTUAL_WIDTH/VIRTUAL_HEIGHT
]]
function drawTextWithGlow(text)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local x = (VIRTUAL_WIDTH - textWidth) / 2
    local y = VIRTUAL_HEIGHT / 2 - 20
    love.graphics.setColor(0, 1, 0, 0.1)
    for dx = -2, 2 do
        for dy = -2, 2 do
            love.graphics.print(text, x + dx, y + dy)
        end
    end
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print(text, x, y)
end