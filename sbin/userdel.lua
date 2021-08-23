local shell = require("shell")
local fs = require("filesystem")
local adv = require("adv")

local args = shell.parse(...)
if #args ~= 1 then
  io.write("Usage: userdel <name>\n")
  return 1
end

local name = args[1]

if name == "root" then print("userdel: root user cannot be deleted.") return end

local users = {}
local ok = false

for i in io.lines("/etc/sys/passwd") do
	if adv.split(i, ":")[1] == name then ok = true goto skip end
	users[#users+1] = i
	::skip::
end
if not ok then print("userdel: User `" .. name .. "' not found.") return end
local f,re = io.open("/etc/sys/passwd", "w")
if not f then print("userdel: " .. re) return end
for i = 1, #users-1 do
  f:write(users[i] .. "\n")
end
f:write(users[#users])
f:close()
fs.remove("/home/" .. name)