local fs = require("filesystem")
local c = require("component")
local term = require("term")
local tty = require("tty")
local perm = require("perm")
local sha = require("sha2")
local text = require("text")
local gpu = c.gpu

if fs.exists("/etc/sys/passwd") then return end

local w,h = gpu.getViewport()
local txt = "Enter PC name:"
local txt2 = "Initial setup"
local data = ""
local rawpass

tty.clear()
gpu.setBackground(0x000000)
tty.clear()
gpu.setBackground(0x505050)
gpu.fill(w/2-15,h/2-5,30,3, " ")
gpu.set(w/2-#txt/2,h/2-4, txt)
gpu.set(w/2-#txt2/2,h/2-6, txt2)
term.setCursor(w/2-13,h/2-2)
gpu.setBackground(0x000000)
local pcname = text.trim(term.read())
if pcname == "" then pcname = "User-PC" end

::retrootpass::
tty.clear()
txt = "Enter root password:"
gpu.setBackground(0x000000)
tty.clear()
gpu.setBackground(0x505050)
gpu.fill(w/2-15,h/2-5,30,3, " ")
gpu.set(w/2-#txt/2,h/2-4, txt)
gpu.set(w/2-#txt2/2,h/2-6, txt2)
term.setCursor(w/2-13,h/2-2)
gpu.setBackground(0x000000)
rawpass = text.trim(term.read(nil,nil,nil, " "))
if rawpass == "" then goto retrootpass end
local rootpass = sha.sha3_256(rawpass)

txt = "Enter user password:"
gpu.setBackground(0x000000)
tty.clear()
gpu.setBackground(0x505050)
gpu.fill(w/2-15,h/2-5,30,3, " ")
gpu.set(w/2-#txt/2,h/2-4, txt)
gpu.set(w/2-#txt2/2,h/2-6, txt2)
term.setCursor(w/2-13,h/2-2)
gpu.setBackground(0x000000)
rawpass = text.trim(term.read(nil,nil,nil, " "))
local pass = sha.sha3_256(rawpass)

gpu.setBackground(0x000000)
tty.clear()

data = "root:" .. rootpass .. "\nuser:" .. pass
fs.makeDirectory("/root")
fs.makeDirectory("/var")
fs.makeDirectory("/home")
fs.makeDirectory("/etc/sys")
local file = io.open("/etc/sys/passwd", "w")
file:write(data)
file:close()

local needL

local prof = {}
for l in io.lines("/etc/profile.lua") do
    prof[#prof + 1] = l
    if string.find(l, "--trigger") ~= nil then
        needL = #prof+1
    end
end
prof[needL] = 'os.setenv("PCNAME", "' .. pcname .. '")'

local textToWrite = ""
for i = 1, #prof-1 do
    textToWrite = textToWrite .. prof[i] .. "\n"
end
textToWrite = textToWrite .. prof[#prof]

local file = io.open("/etc/profile.lua", "w")
file:write(textToWrite)
file:close()