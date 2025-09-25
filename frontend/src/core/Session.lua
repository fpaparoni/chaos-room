-- Session module shared among different states

local Session = {
    host = '',
    port = '',
    count = 0,
    startTime = 0,
    endTime=0
}

function Session:reset()
    self.host = ''
    self.port = ''
    self.count = 0
    self.startTime = 0
    self.endTime=0
end

-- debug utility
function Session:debug()
    print('--- Session State ---')
    for k, v in pairs(self) do
        if type(v) ~= "function" then
            print(k .. ': ' .. tostring(v))
        end
    end
end

return Session