local http = require("lib.http")
local json = require("lib.json")
local Session = require 'src.core.Session'
ChaosController = Class{}

function ChaosController:init()
    self.timer = 0
    self.interval = 5         -- ogni 5 secondi
    self.pendingBricks = 0    -- quanti brick aggiungere
end

function ChaosController:saveInitialLayout(bricks)
    -- If already exists, don't overwrite
    if self.initialLayout and #self.initialLayout > 0 then
        return
    end

    self.initialLayout = {}

    for _, brick in ipairs(bricks) do
        table.insert(self.initialLayout, {
            col = brick.col,
            row = brick.row,
            x = brick.x,
            y = brick.y,
            color = brick.color,
            tier = brick.tier
        })
    end
end


function ChaosController:update(dt, bricks)
    
    self.timer = self.timer + dt
    
    if self.timer >= self.interval then
        self.timer = self.timer - self.interval

        local externalCount = self:queryExternalBrickCount(bricks)

        -- Conta quanti brick sono attualmente attivi
        local currentActive = 0
        for _, brick in ipairs(bricks) do
            if brick.inPlay then
                currentActive = currentActive + 1
            end
        end

        local delta = externalCount - currentActive
        if delta > 0 then
            self.pendingBricks = delta
            print("[CHAOS] External wants " .. externalCount .. " bricks. Adding " .. delta)
        elseif delta < 0 then
            print("[CHAOS] External wants " .. externalCount .. " bricks. Removing " .. math.abs(delta))
            self:removeBricks(math.abs(delta), bricks)
        end
    end

    -- Aggiunge i brick nei buchi disponibili
    if self.pendingBricks > 0 then
        self:addBricks(bricks)
    end
end

function ChaosController:queryExternalBrickCount(bricks)
    local response_body = {}
    local url = "http://".. Session.host .. ":" .. Session.port .. "/victims"
    local body, err = http.get(url)

    if not body then
        print("Errore HTTP:", err)
        return
    end

    local data = json.decode(body)
    if data and data.count then
        print("Numero di pod sul cluster:", data.count)
        return data.count
    else
        print("Errore JSON")
        return 1
    end
end


function ChaosController:addBricks(bricks)
    local added = 0

    -- Costruisci una mappa delle posizioni occupate attualmente
    local occupied = {}
    for _, brick in ipairs(bricks) do
        if brick.inPlay then
            occupied[brick.x] = occupied[brick.x] or {}
            occupied[brick.x][brick.y] = true
            print(string.format("[CHAOS] Brick inPlay at x=%d y=%d", brick.x, brick.y))
        else
            print(string.format("[CHAOS] Brick free at x=%d y=%d", brick.x, brick.y))
        end
    end

    -- Scorri la mappa iniziale e aggiungi mattoni nelle posizioni mancanti
    for _, pos in ipairs(self.initialLayout) do
        if not (occupied[pos.x] and occupied[pos.x][pos.y]) then
            local brick = Brick()
            brick.x = pos.x
            brick.y = pos.y
            brick.color = pos.color
            brick.tier = pos.tier
            brick.inPlay = true
            table.insert(bricks, brick)

            print(string.format("[CHAOS] Brick re-added at x=%d y=%d", pos.x, pos.y))
            added = added + 1

            if added == self.pendingBricks then
                self.pendingBricks = 0
                return
            end
        end
    end
end

function ChaosController:removeBrick()
    print("[CHAOS] Brick removed")
    Session.count=Session.count+1;
    local url = "http://"..Session.host .. ":" .. Session.port .. "/kill"
    local post_result, post_err = http.post(url)
    if post_result then
        print("Risposta POST:", post_result)
    else
        print("Errore POST:", post_err)
    end
end

function ChaosController:removeBricks(count, bricks)
    local removed = 0
    for _, brick in ipairs(bricks) do
        if brick.inPlay then
            brick.inPlay = false
            removed = removed + 1
            print("[CHAOS] Brick removed at x=" .. brick.x .. " y=" .. brick.y)
            local url = "http://"..Session.host .. ":" .. Session.port .. "/kill"
            local post_result, post_err = http.post(url)
            if post_result then
                print("Risposta POST:", post_result)
            else
                print("Errore POST:", post_err)
            end
            if removed == count then
                break
            end
        end
    end
end
