local term = require("term")
local text = require("text")
local shell = require("shell")
local sh = require("sh")
local perm = require("perm")
local sha = require("sha2")

local args,opts = shell.parse(...)
local arr = {...}
local cl = {}
local com = ""
local accUsr = "root"

if opts.h then
  print("Use: \n\t`sudo <command>'\n\t`sudo -u <userName> <command>'")
  return
end

if opts.u then
  accUsr = args[1]
  local d = #arr-1
  for i = 1, d do
    cl[i] = arr[i+2]
  end
else 
  accUsr = "root"
  cl = arr
end

for i = 1, #cl do
  com = com .." "..cl[i]
end

io.write("Enter password: ")
term.setCursorBlink(false)
local pass = term.read(nil,nil,nil," ")
term.setCursorBlink(true)
io.write("\n")
local file = io.open("/etc/sys/passwd")

local tmp = {}

local f
repeat
 f = file:read("*l")
 if f ~= nil then tmp = perm.split(f, ":") else break end
until tmp[1] == accUsr
file:close()
if tmp[1] ~= accUsr then
  print("User not found")
  return
end

if tostring(tmp[2]) == sha.sha3_256(text.trim(pass)) then
  local env = os.getenv("USER")
  os.setenv("USER", "root")
  sh.execute(_ENV, com)
  os.setenv("USER", "user")
else
  print("\nAccess denied")
  local file = io.open("/var/sudolog.log", "a")
  if ... ~= nil then file:write(os.date() .. " (" .. os.getenv("USER") .. ")> ".. ... .."\n") end
  file:close()
end