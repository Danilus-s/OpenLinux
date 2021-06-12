local term = require("term")
local text = require("text")
local shell = require("shell")
local sh = require("sh")
local perm = require("perm")
local sha = require("sha2")

local args,opts = shell.parse(...)
local com = ""
local pass
local try = 1

local stw = 1
if opts.p then 
  stw = 2
end
for i = stw, #args do
  com = com .. args[i] .. " "
end

if opts.h or opts.help then
  print("Usage:`sudo [-p] [<password>] <command>")
  return
end
if opts.p then
  pass = args[1]
  goto skip
end

if os.getenv("SUDO") == "true" then
  if os.time() >= tonumber(os.getenv("SUDOT")) then
    os.setenv("SUDO", nil)
    os.setenv("SUDOT", nil)
  else
    local env = os.getenv("USER")
    os.setenv("USER", "root")
    sh.execute(_ENV, com)
    os.setenv("USER", env)
    return
  end
end
::ret::
io.write("[sudo] password for root: ")
pass = perm.read()
io.write("\n")
::skip::
local file = io.open("/etc/sys/passwd")

local tmp = {}

local f
repeat
 f = file:read("*l")
 if f ~= nil then tmp = perm.split(f, ":") else break end
until tmp[1] == "root"
file:close()
if tmp[1] ~= "root" then
  print("User not found")
  return
end

if tostring(tmp[2]) == sha.sha3_256(text.trim(pass)) then
  os.setenv("SUDO", "true")
  os.setenv("SUDOT", os.time()+60)
  local env = os.getenv("USER")
  os.setenv("USER", "root")
  sh.execute(_ENV, com)
  os.setenv("USER", env)
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