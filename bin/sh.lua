local shell = require("shell")
local tty = require("tty")
local text = require("text")
local sh = require("sh")
local perm = require("perm")
local fs = require("filesystem")

local args = shell.parse(...)

shell.prime()

function isBan(com)
  local b = perm.split(com, " ")
  local dirs = {}
  local f

  for i = 1, #b do
    if fs.exists(shell.resolve(b[i])) then
      dirs[#dirs + 1] = shell.resolve(b[i])
    end
  end

  for t in io.lines("/etc/banpath") do
    for n = 1, #dirs do
      if string.find(dirs[n], t) then
        return true
      end
    end
  end
  return false
end

function isBanW(com)
  local file = io.open("/etc/banword")
  local f
  while true do
    f = file:read("*l")
    if f ~= nil then 
      if string.find(com, f) ~= nil then return true end 
    else 
      break 
    end
  end
  file:close()
end

local logout = false

if #args == 0 then
  local has_profile
  local input_handler = {hint = sh.hintHandler}
  while true do
    if io.stdin.tty and io.stdout.tty then
      if not has_profile then -- first time run AND interactive
        has_profile = true
        if os.getenv("USER") == nil then       
          logout = true
          break
        end
        dofile("/etc/profile.lua")
      end
      if tty.getCursor() > 1 then
        io.write("\n")
      end
      io.write(sh.expand(os.getenv("PS1") or "$ "))
    end
    tty.window.cursor = input_handler
    local command = io.stdin:readLine(false)
    tty.window.cursor = nil
    if command then
      command = text.trim(command)
      if os.getenv("USER") ~= "root" and isBan(command) then 
        print("File or directory is blocked\nTry `sudo su'")
      elseif os.getenv("USER") ~= "root" and isBanW(command) then 
          print("Word is blocked\nTry `sudo su'")
      elseif command == "exit" then
        os.setenv("USER", "user")
        os.setenv("SU", "false")
        return
      elseif command == "logout" then
        logout = true
        os.setenv("USER", nil)
        os.setenv("SU", "false")
        break
      elseif command ~= "" then
        --luacheck: globals _ENV
        local result, reason = sh.execute(_ENV, command)
        if not result then
          io.stderr:write((reason and tostring(reason) or "unknown error") .. "\n")
        else
          local file = io.open("/var/syslog.log", "a")
          if os.getenv("USER") ~= nil then
            file:write(os.date() .. " (" .. os.getenv("USER") .. ")> ".. command .."\n")
          else
            file:write(os.date() .. " > ".. command .."\n")
          end
          file:close()
        end
      end
    elseif command == nil then -- false only means the input was interrupted
      return -- eof
    end
  end
else
  -- execute command.
  local result = table.pack(sh.execute(...))
  if not result[1] then
    error(result[2], 0)
  end
  return table.unpack(result, 2)
end
if logout then sh.execute(_ENV, "/sbin/login.lua") end