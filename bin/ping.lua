local c = require("component")
local sh = require("shell")
local cp = require("computer")
local nw = require("network")
local m = c.modem

local args, opt = sh.parse(...)

local port = 7
local adr
local up = os.time()
local cl = m.isOpen(port)

if opt.h or opt.help or #args < 1 then print("Usage: ping [IP]");return end
adr = args[1]

print("PING " .. args[1])
m.open(port)
for i = 1, 5 do
    local tAdr = nw.getAdr(adr)
    if tAdr ~= nil then
        print("From " .. args[1] .. ": address=" .. tAdr .. " time=" .. os.time() - up .. " ms")
    else
        print("Timed out")
    end
end
if not cl then m.close(port) end