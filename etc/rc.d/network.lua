local e = require("event")
local c = require("component")
local nw = require("network")
local m = c.modem

local function ping(...)
    local arg = {...}
    if arg[6] == "ping" then
        local adr = nw.readAdr(arg[7])
        if adr ~= nil then m.send(arg[3], 8, "pong", adr) end
    end
end


function start(msg)
    m.open(7)
    e.listen("modem_message", ping)
end

function stop(msg)
    e.ignore("modem_message", ping)
    m.close(7)
end