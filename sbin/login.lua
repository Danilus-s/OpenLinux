local c = require("component")
local term = require("term")
local tty = require("tty")
local text = require("text")
local sha = require("sha2")
local perm = require("perm")
local computer = require("computer")
local gui = require("gui")
local gpu = c.gpu

if perm.getVar("logged") == true then return end

local w,h = gpu.getViewport()
local rawpass
local txt = ""
local txt2 = "Login"

local d = perm.getUser("user")

local cfg = require("adv").readCfg("/etc/system.cfg")
if cfg.passwd ~= "true" and cfg.defuser ~= "-" then
	perm.setVar("defuser", cfg.defuser)
	perm.setVar("logged", true)
	return
end

local function draw()
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  tty.clear()
  gpu.setForeground(0x101010)
  gpu.setBackground(0xe0e0e0)
  gpu.fill(w/2-15,h/2-5,30,5, " ")
  gpu.set(w/2-13,h/2-3, txt)
  gpu.set(w/2-#txt2/2,h/2-5, txt2)
  gpu.setBackground(0x303030)
  gpu.fill(w/2-13,h/2-2,26,1," ")
  gpu.setForeground(0xF0F0F0)
end

::retuser::
txt = "Enter username:"
draw()
local usrname = gui.read(w/2-13,h/2-2,26,{maxlen = 32})
d = perm.getUser(usrname)
if not d then goto retuser end

::retpass::
txt = "Enter password:"
draw()
rawpass = gui.read(w/2-13,h/2-2,26,{pwdchar = "*", maxlen = 32})
local pass = sha.sha3_256(rawpass)
if pass ~= d[3] then goto retpass end

perm.setVar("defuser", d[1])
perm.setVar("logged", true)

gpu.setBackground(0x000000)
tty.clear()