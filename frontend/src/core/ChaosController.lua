ChaosController = Class{}

local ChaosService = require("src.core.ChaosService")
local Session = require 'src.core.Session'

victims = nil
pollInterval = 2
channel_cmd = love.thread.getChannel("chaos_cmd")
channel_resp = love.thread.getChannel("chaos_resp")
channel_conf = love.thread.getChannel("chaos_conf")
thread = nil

function ChaosController:init()
    -- First sync call
    local chaos = ChaosService(Session.host,Session.port)
    victims = chaos:countPod()
    -- Start async thread
    self:startThread()
end

function ChaosController:startThread()
    print("[ChaosController] startThread")
    local code = [[
        local socket = require("socket")
        local ChaosService = require("src.core.ChaosService")
        
        local channel_cmd = love.thread.getChannel("chaos_cmd")
        local channel_resp = love.thread.getChannel("chaos_resp")
        local channel_conf = love.thread.getChannel("chaos_conf")

        local config = channel_conf:demand()  -- blocking
        local chaos = ChaosService(config.host, config.port)

        local pollInterval = 2
        local timer = 0
        local dt = 0.1

        while true do
            -- Gestione comandi
            local cmd = channel_cmd:pop()
            if cmd == "kill" then
                chaos:removePod()
            end

            -- Polling
            timer = timer + dt
            if timer >= pollInterval then
                timer = 0
                local count = chaos:countPod()
                if count then
                    channel_resp:push(count)
                end
            end

            socket.sleep(dt) 
        end
    ]]
    self.thread = love.thread.newThread(code)
    self.thread:start(self.pollInterval)

    channel_conf:push({
        host = Session.host,
        port = Session.port
    })
end

function ChaosController:update()
    local val = channel_resp:pop()
    if val then
        victims = val
    end
end

function ChaosController:countPod()
    local val = channel_resp:pop()
    while val do
        victims = val
        val = channel_resp:pop()
    end
    return victims
end

function ChaosController:removePod()
    Session.count=Session.count+1;
    channel_cmd:push("kill")
end
