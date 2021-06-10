local c = require("component")
local e = require("event")
local cm = require("computer")
local perm = require("perm")
local sha = require("sha2")
local sh = require("sh")
local modem = c.modem
local m = c.modem

local connected = false
local conAdr = ""
local data = {}

local function con(...)
    local arg = {...}
    if connected == false then
        if type(arg[6]) == "table" then data = arg[6] end
        if data[1] == "connect" then
            local d = perm.getUser(data[2])
            local pass = sha.sha3_256(data[3])
            if pass == d[2] then
                cm.beep(1200, 0.5)
                connected = true
                conAdr = arg[3]
                modem.send(conAdr, 22, true, os.getenv("PCNAME"))
            end
        end
    else
        if conAdr == arg[3] then
            if arg[6] == "stop" then 
                connected = false
                conAdr = ""
                data = {}
            else
                local def = os.getenv("USER")
                os.setenv("USER", data[2])
                local result, reason = sh.execute(_ENV, arg[6])
                os.setenv("USER", def)
                modem.send(conAdr, 22, result)
            end
        else
            modem.send(arg[3], 22, false)
        end
    end
end

function start(msg)
    m.open(22)
    e.listen("modem_message", con)
end



function stop(msg)
    e.ignore("modem_message", con)
    m.close(22)
    connected = false
    conAdr = ""
    data = {}
end