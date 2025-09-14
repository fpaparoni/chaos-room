require("src/zombieshooter/lib/table")

local G = love.graphics

local utils = {}

function utils.distanceBetween(p1, p2)
  return math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
end

function utils.primaryFont(size)
  return G.newFont(MONOGRAM_FONT_FILE, size)
end

function utils.hex(hex, alpha)
  local convertHex = function(code) return math.floor((tonumber(code, 16) / 255) * 100) / 100 end

  hex = hex:gsub("#", "")
  local colorCodes = {hex:match('(..)(..)(..)')}
  local convertedColors = table.map(colorCodes, convertHex)
  table.insert(convertedColors, alpha or 1)

  return unpack(convertedColors)
end

function utils.rgb(r, g, b, alpha)
  local convertRgb = function(code) return math.floor((code/255) * 100) / 100 end

  local colorCodes = {r, g, b}
  convertedColors = table.map(colorCodes, convertRgb)
  table.insert(convertedColors, alpha or 1)

  return unpack(convertedColors)
end

function utils.isOnScreen(entity, side)
  if side == "top" then return entity.y > 0
  elseif side == "bottom" then return entity.y < G.getHeight()
  elseif side == "left" then return entity.x > 0
  elseif side == "right" then return entity.x < G.getWidth()
  end
end

return utils
