local e = require("event")
local c = require("component")
local m = c.modem

local function ping(...)
    local arg = {...}
    if arg[6] == "ping" then m.send(arg[3], 1, os.getenv("PCNAME")) end
end


function start(msg)
    m.open(1)
    e.listen("modem_message", ping)
end

function stop(msg)
    e.ignore("modem_message", ping)
    m.close(1)
end