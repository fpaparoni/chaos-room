local http = {}

function http.get(url)
    local cmd = 'curl -s "' .. url .. '"'
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    local success, msg, code = handle:close()

    if not success then
        return nil, "Errore eseguendo curl: " .. tostring(msg)
    end

    return result
end

-- POST request (without data)
function http.post(url)
    local cmd = 'curl -s -X POST "' .. url .. '"'
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    local success, msg, code = handle:close()

    if not success then
        return nil, "Errore POST: " .. tostring(msg)
    end

    return result
end

return http