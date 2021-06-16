local network = require("network")
local perm = require("perm")
local c = require("component")
local m = c.modem

local info = {}

for i in io.lines("/etc/sys/network.cfg") do
    info[#info+1] = {}
    info[#info] = perm.split(i, ":")
end

local arg = {...}

if ... == nil then
    for i = 1, #info do
        local ik = c.getPrimary("modem").address
        if ik == info[i][2] then
            print(info[i][1] .. ":\tactive")
        else
            print(info[i][1] .. ":\tinactive")
        end
        print("\tinet " .. info [i][3])
        print("\taddress " .. info[i][2])
        print("\tpacket size " .. c.invoke(info[i][2], "maxPacketSize"))
        if c.invoke(info[i][2], "isWireless") then print("\tsignal strength " .. c.invoke(info[i][2], "getStrength")) end
        if i ~= #info then print("") end
    end
elseif #arg == 1 then
    for i = 1, #info do
        if info[i][1] == arg[1] then
            local ik = c.getPrimary("modem").address
            if ik == info[i][2] then
                print(info[i][1] .. ":\tactive")
            else
                print(info[i][1] .. ":\tinactive")
            end
            print("\tinet " .. info [i][3])
            print("\taddress " .. info[i][2])
            print("\tpacket size " .. c.invoke(info[i][2], "maxPacketSize"))
            if c.invoke(info[i][2], "isWireless") then print("\tsignal strength " .. c.invoke(info[i][2], "getStrength")) end
        end
    end
elseif #arg == 2 and arg[2] == "up" then
    local adr = network.getAdrFromName(arg[1])
    if adr ~= nil then c.setPrimary("modem", adr) else print("Interface `" .. arg[1] .."' not found") end
elseif #arg == 2 then
    if not network.getValidIP(arg[2]) then print("Invalid IP address") return end
    if not network.setAdr(arg[1], arg[2]) then print("Interface `" .. arg[1] .."' not found")return end
end

