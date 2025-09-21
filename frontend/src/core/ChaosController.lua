local http = require("lib.http")
local json = require("lib.json")
local Session = require 'src.core.Session'
ChaosController = Class{}

function ChaosController:init()
end

function ChaosController:countPod()
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

function ChaosController:removePod()
    print("[CHAOS] Pod removed")
    Session.count=Session.count+1;
    local url = "http://"..Session.host .. ":" .. Session.port .. "/kill"
    local post_result, post_err = http.post(url)
    if post_result then
        print("Response POST:", post_result)
    else
        print("Error POST:", post_err)
    end
end
