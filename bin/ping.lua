local c = require("component")
local sh = require("shell")
local cp = require("computer")
local e = require("event")
local m = c.modem

local args, opt = sh.parse(...)

local port = 1
local tm = 5
local adr
local up = cp.uptime()
local cl = m.isOpen(port)

if opt.h or opt.help then print("Use `ping <-b> [address] <-p> [port?] <-t> [timeout?]'");return end
if opt.p then if opt.b then port = tonumber(args[1]) else port = tonumber(args[2]) end end
if opt.t then if opt.b then tm = tonumber(args[2]) else tm = tonumber(args[3]) end end
if not opt.b then adr = args[1] end

local function rec(...)
    local arg = {...}
    
end
m.open(port)
if opt.b then m.broadcast(port, "ping") else m.send(adr, port, "ping") end
::ret::
local arg = {e.pull(tm, "modem_message")}
if arg[2] == arg[3] then goto ret end
print("From: " .. arg[3] .. " Name: " .. arg[6] .. " time: " .. cp.uptime() - up .. "sec")
if not cl then m.close(port) end