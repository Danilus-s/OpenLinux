local sha = require ("sha2")
local gpu = require("component").gpu
local term = require("term")
local adv = require("adv")
local p = require("process")

local perm = {}
local system = {}
system.logged = false
system.defuser = ""
system.user = ""
system.home = ""
system.sudo = false
system.sudot = 0

local sys = {
  "init",
  "sudo",
  "su",
  "sh",
  "/bin/sh.lua",
  "/etc/profile.lua",
  "login",
  "logout",
  "passwd",
  "/sbin/passwd.lua"
}

function perm.getNeedPerm(comName)
  local file = io.open("/etc/perm")
  local f
  local tmp = {}
  repeat
   f = file:read("*l")
   if f ~= nil then tmp = adv.split(f, ":") else break end
  until tostring(tmp[1]) == comName
  file:close()
  if f == nil then tmp[2] = 10 end
  local ret = false
  
  local nv = perm.getPerm(perm.getVar("user"))
  if nv <= tonumber(tmp[2]) then ret = true end
  if not ret then perm.error(comName) end
end

function perm.read()
  local x,y = term.getCursor()
  local x1,y1 = gpu.getResolution()
  local c = gpu.getForeground()
  gpu.setForeground(0x000000)
  gpu.fill(x,y,x1-x,1, " ")
  local d = require("text").trim(term.read(nil,nil,nil," "))
  gpu.setForeground(c)
  return d
end

function perm.error(...)
  local arg = {...}
  local str = ""
  for i = 1, #arg do
    str = str .. arg[i] .. ": "
  end
  print("\27[31m" .. str .. "Permission denied.\27[m")
  os.exit()
end

function perm.getPerm(user)
  local file = io.open("/etc/sys/passwd")
  local f
  local tmp = {}
  repeat
    f = file:read("*l")
    if f ~= nil then tmp = adv.split(f, ":") else break end
  until tostring(tmp[1]) == user
  file:close()
  if f == nil then return 10 end
  
  return tonumber(tmp[2])
end

function perm.getUser(user)
  local f = ""
  local data = {}
  local file = io.open("/etc/sys/passwd")
  repeat
      f = file:read("*l")
      if f ~= nil then data = adv.split(f, ":") else break end
  until data[1] == user
  file:close()
  if f ~= nil then return data else return nil end
end

function perm.save(path)
  local f
  local file = io.open("/etc/checkfile")
  repeat
      f = file:read("*l")
      if f == nil then break end
  until f == path
  file:close()
  if f ~= nil then return true else return false end
end

function perm.check()
  local b = false
  for c in io.lines("/etc/checkfile") do
    local txt = ""
    if not require("filesystem").exists(c) then print("File `" .. c .. "' not found!"); b = true; require("computer").beep(700, 0.3); goto skip end
    for t in io.lines(c) do
      txt = txt .. t .. "\n"
    end

    local needL

    local prof = {}
    for l in io.lines("/etc/sys/sums") do
        prof[#prof + 1] = l
        if string.find(l, c) ~= nil then
            needL = #prof
        end
    end
    local sum = adv.split(prof[needL], ":")[2]
    if sum ~= sha.md5(txt) then
      print("File `" .. c .. "' modified!")
      require("computer").beep(700, 0.3)
      b = true
    end
    ::skip::
  end
  if b then
    io.write("\nEnd")
    io.read()
  end
end

function perm.isBan(path)
  if perm.getPerm(perm.getVar("user")) == 1 then return false end
  for i = 1, #sys do
    if p.info().command == sys[i] then return false end
	end
  for t in io.lines("/etc/banpath") do
    if string.find(path, t) then
      return true
    end
  end
  return false
end

function perm.isUsrDir(path)
  if perm.getPerm(perm.getVar("user")) == 1 then return true end
  if perm.getPerm(perm.getVar("user")) ~= 1 then
    for i = 1, #sys do
      if p.info().command == sys[i] then return true end
	  end
    local d = {}
    d = perm.getUser(perm.getVar("user"))
    path = require("shell").resolve(path)
    for i in io.lines("/etc/sys/passwd") do
      local sp = adv.split(i, ":")
      if sp[1] ~= d[1] and string.find(path, sp[4]) then return false end
    end
  end
  return true
end

function perm.setVar(varname, value)
  if _G.runlevel ~= "S" then
	  for i = 1, #sys do
      if p.info().command == sys[i] then goto ok end
	  end
	  perm.error(p.info().command,"set var")
  end
  ::ok::
  if system[varname] ~= nil then system[varname] = value if varname == "user" then os.setenv("USER", value) elseif varname == "home" then os.setenv("HOME", value) end end
end
function perm.getVar(varname)
	if system[varname] ~= nil then return system[varname] end
end

function perm.isSys(prog)
	for i = 1, #sys do
	  if prog == sys[i] then return true end
	end
	return false
end

return perm