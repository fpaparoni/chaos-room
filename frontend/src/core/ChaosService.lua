local http = require("lib.http")
local json = require("lib.json")
local Class = require("lib.class")


ChaosService = Class{}

function ChaosService:init(host, port)
    self.host = host
    self.port = port
end

function ChaosService:countPod()
    local response_body = {}

    local url = "http://".. self.host .. ":" .. self.port .. "/victims"
    local body, err = http.get(url)

    if not body then
        print("[ChaosService] HTTP error:", err.." "..url)
        return
    end

    local data = json.decode(body)
    if data and data.count then
        print("[ChaosService] Pod count:", data.count)
        return data.count
    else
        print("[ChaosService] JSON error:",body)
        return 1
    end
end

function ChaosService:removePod()
    print("[ChaosService] Pod removed")
    local url = "http://"..self.host .. ":" .. self.port .. "/kill"
    local post_result, post_err = http.post(url)
    if post_result then
        print("[ChaosService] POST response:", post_result)
    else
        print("[ChaosService] POST error:", post_err)
    end
end

return ChaosService