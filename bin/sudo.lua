local term = require("term")
local text = require("text")
local shell = require("shell")
local sh = require("shell")
local perm = require("perm")
local sha = require("sha2")
local adv = require("adv")

local args,opts = shell.parse(...)
local com = ""
local pass
local user = "root"
local try = 1

local stw = 1
if opts.p then 
  stw = stw + 1
end
if opts.u then
	stw = stw + 1
end
for i = stw, #args do
  com = com .. args[i] .. " "
end

if opts.h or opts.help then
  print("Usage: sudo [-p] [<password>] [-u] [<user>] <command>")
  return
end
if opts.u then
	if opts.p then user = args[2] else user = args[1] end
end
if opts.p then
  pass = args[1]
  goto skip
end

if perm.getVar("sudo") and user == "root" then
  if os.time() >= perm.getVar("sudot") then
    perm.setVar("sudo", false)
    perm.setVar("sudot", 0)
  else
    local env = perm.getVar("user")
    perm.setVar("user", "root")
    sh.execute(com)
    perm.setVar("user", env)
    return
  end
end
::ret::
io.write("[sudo] password for " .. user .. ": ")
pass = perm.read()
io.write("\n")
::skip::

local tmp = {}

tmp = perm.getUser(user)
if tmp[1] ~= user then
  print("sudo: User not found.")
  return
end

if tostring(tmp[3]) == sha.sha3_256(text.trim(pass)) then
  perm.setVar("sudo", true)
  perm.setVar("sudot", os.time()+6000)
  local env = perm.getVar("user")
  perm.setVar("user", user)
  sh.execute(com)
  perm.setVar("user", env)
else
  if try < 3 and not opts.p then 
    print("Password is wrong, please try again")
    try = try + 1
    goto ret
  else
    print("sudo: 3 incorrect password attempts")
  end
  local file = io.open("/var/sudo.log", "a")
  if ... ~= nil then file:write(os.date() .. " (" .. os.getenv("USER") .. ")> ".. ... .."\n") end
  file:close()
end