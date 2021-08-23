local network = require("network")
local adv = require("adv")
local c = require("component")
local m = c.modem

local info = {}

for i in io.lines("/etc/sys/network.cfg") do
  info[#info+1] = {}
  info[#info] = adv.split(i, ":")
end

local arg = {...}

if #arg == 0 then
  for i = 1, #info do
    local ik = c.getPrimary("modem").address
    if ik == info[i][2] then
      print(info[i][1] .. ":\tstatus=\tactive")
    else
      print(info[i][1] .. ":\tstatus=\tinactive")
    end
    print("\tinet=\t" .. info [i][3])
    print("\taddress=\t" .. info[i][2])
    if not c.invoke(info[i][2], "isWireless") then print("\tpacket size=\t" .. c.invoke(info[i][2], "maxPacketSize")) end
    if c.invoke(info[i][2], "isWireless") then print("\tsignal strength=\t" .. c.invoke(info[i][2], "getStrength")) end
    if i ~= #info then print("") end
  end
elseif #arg == 1 then
  for i = 1, #info do
    if info[i][1] == arg[1] then
      local ik = c.getPrimary("modem").address
      if ik == info[i][2] then
        print(info[i][1] .. ":\tstatus=\tactive")
      else
        print(info[i][1] .. ":\tstatus=\tinactive")
      end
      print("\tinet=\t" .. info [i][3])
      print("\taddress=\t" .. info[i][2])
      print("\tpacket size=\t" .. c.invoke(info[i][2], "maxPacketSize"))
      if c.invoke(info[i][2], "isWireless") then print("\tsignal strength=\t" .. c.invoke(info[i][2], "getStrength")) end
      return
    end
  end
  io.stderr:write("Interface `" .. arg[1] .."' not found.")
elseif #arg == 2 and arg[2] == "up" then
  local adr = network.getAdrFromName(arg[1])
  if adr ~= nil then c.setPrimary("modem", adr) else io.stderr:write("Interface `" .. arg[1] .."' not found.") end
elseif #arg == 2 then
  if not network.getValidIP(arg[2]) then io.stderr:write("Invalid IP address.") return end
  if not network.setIP(arg[1], arg[2], true) then io.stderr:write("Interface `" .. arg[1] .."' not found.")return end
end

