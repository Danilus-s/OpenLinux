local c = require("component")
local term = require("term")
local tty = require("tty")
local text = require("text")
local sha = require("sha2")
local perm = require("perm")
local computer = require("computer")
local gpu = c.gpu

if os.getenv("USER") ~= nil then return end

local w,h = gpu.getViewport()
local rawpass
local txt = "Enter password:"
local txt2 = "Login"

local d = perm.getUser("user")

::retpass::
txt = "Enter password:"
gpu.setBackground(0x000000)
tty.clear()
gpu.setBackground(0x505050)
gpu.fill(w/2-15,h/2-5,30,3, " ")
gpu.set(w/2-#txt/2,h/2-4, txt)
gpu.set(w/2-#txt2/2,h/2-6, txt2)
term.setCursor(w/2-13,h/2-2)
gpu.setBackground(0x000000)
rawpass = perm.read()
local pass = sha.sha3_256(rawpass)
if pass ~= d[2] then goto retpass end

os.setenv("USER", d[1])
os.setenv("HOME", d[3])

gpu.setBackground(0x000000)
tty.clear()
if os.getenv("HOME") ~= d[3] then
  require("/lib/core/cursor.lua").ext()
end