--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row

LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]

function LevelMaker.createMap(level)
    local bricks = {}

    local brickWidth = 32
    local brickHeight = 16

    -- quanti mattoni per riga (senza superare la larghezza virtuale)
    local bricksPerRow = math.min(BRICK_COUNT, math.floor(VIRTUAL_WIDTH / brickWidth))
    local totalRows = math.ceil(BRICK_COUNT / bricksPerRow)

    local brickIndex = 0

    for row = 1, totalRows do
        -- numero effettivo di mattoni in questa riga (potrebbe essere incompleta)
        local bricksInThisRow = math.min(BRICK_COUNT - brickIndex, bricksPerRow)

        -- calcola xStart per centrare la riga
        local totalRowWidth = bricksInThisRow * brickWidth
        local xStart = (VIRTUAL_WIDTH - totalRowWidth) / 2

        for i = 1, bricksInThisRow do
            local x = xStart + (i - 1) * brickWidth
            local y = brickHeight * (row + 1)  -- +1 per partire dalla seconda riga

            table.insert(bricks, Brick(x, y))
            brickIndex = brickIndex + 1
        end
    end

    return bricks
end


