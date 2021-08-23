local c = require("component")
local sh = require("shell")
local cp = require("computer")
local nw = require("network")
local m = c.modem

local args, opt = sh.parse(...)

local adr
local up = os.time()

if opt.h or opt.help or #args < 1 then print("Usage: ping [IP]");return end
adr = args[1]

print("PING " .. args[1])
for i = 1, 5 do
    local tAdr = nw.getAdrFromIP(adr)
    if tAdr ~= nil then
        print("From " .. args[1] .. ": address=" .. tAdr .. " time=" .. os.time() - up .. " ms")
    else
        print("Timed out")
    end
end