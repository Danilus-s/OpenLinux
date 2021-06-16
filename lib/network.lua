local cp = require("component")
local modem = cp.modem
local event = require("event")
local perm = require("perm")

if not require("component").isAvailable("modem") then return end

local network = {}

function network.readIP(adr)
    local info = {}
    for i in io.lines("/etc/sys/network.cfg") do
        info[#info+1] = {}
        info[#info] = perm.split(i, ":")
    end
    for i = 1, #info do
        if info[i][2] == adr then return  info[i][3] end
    end
    return
end

function network.readAdr(IP)
    local info = {}
    for i in io.lines("/etc/sys/network.cfg") do
        info[#info+1] = {}
        info[#info] = perm.split(i, ":")
    end
    for i = 1, #info do
        if info[i][3] == IP then return  info[i][2] end
    end
    return
end

function network.getAdrFromName(name)
    for i in io.lines("/etc/sys/network.cfg") do
        if perm.split(i, ":")[1] == name then return perm.split(i, ":")[2] end
    end
    return
end

function network.newIP()
    local t1 = perm.split(os.date(), " ")
    local raw = perm.concatTable(perm.split(t1[1], "/"),perm.split(t1[2], ":"))
    return raw[1]+raw[2] .. "." .. raw[3]+raw[4] .. "." .. raw[5]+raw[6] .. "." .. math.random(1,255)
end

modem.open(7)

function network.getAdr(IP)
    if type(IP) ~= "string" then return end 
    modem.broadcast(7, "ping", IP)
    os.sleep(0)
    modem.open(8)
    local resp = {event.pull(5, "modem_message")}
    modem.close(8)
    if resp[6] == "pong" then return resp[3] else return end
end

function network.getValidIP(IP)
    local raw = perm.split(IP, ".")
    if #raw == 4 then
        if tonumber(raw[1]) ~= nil and tonumber(raw[2]) ~= nil and tonumber(raw[3]) ~= nil and tonumber(raw[4]) ~= nil then
            return true
        end
    end
    return false
end

function network.setAdr(iface, IP)
    local info = {}
    local ok = false
    for i in io.lines("/etc/sys/network.cfg") do
        info[#info+1] = {}
        info[#info] = perm.split(i, ":")
    end
    local f = io.open("/etc/sys/network.cfg", "w")
    for i = 1, #info do
        if info[i][1] == iface then
            info[i][3] = IP
            ok = true
        end
        f:write(info[i][1] .. ":" .. info[i][2] .. ":" .. info[i][3] .. "\n")
    end
    f:close()
    return ok
end

return network