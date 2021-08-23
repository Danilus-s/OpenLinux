local cp = require("component")
local modem = cp.modem
local event = require("event")
local adv = require("adv")

if not require("component").isAvailable("modem") then return end

local network = {}

function network.readIPFromAdr(adr)
    local info = {}
    for i in io.lines("/etc/sys/network.cfg") do
        info[#info+1] = {}
        info[#info] = adv.split(i, ":")
    end
    for i = 1, #info do
        if info[i][2] == adr then return  info[i][3] end
    end
    return
end

function network.readAdrFromIP(IP)
    local info = {}
    for i in io.lines("/etc/sys/network.cfg") do
        info[#info+1] = {}
        info[#info] = adv.split(i, ":")
    end
    for i = 1, #info do
        if info[i][3] == IP then return  info[i][2] end
    end
    return
end

function network.getAdrFromName(name)
    for i in io.lines("/etc/sys/network.cfg") do
        if adv.split(i, ":")[1] == name then return adv.split(i, ":")[2] end
    end
    return
end

function network.newIP(mod)
  mod = mod or modem
  return string.format("%d.%d.%d", tonumber("0x"..require("computer").address():sub(1,2)), tonumber("0x"..mod.address:sub(1,2)), math.random(1,255))
end

function network.getAdrFromIP(IP)
  if type(IP) ~= "string" then return end 
  modem.broadcast(7, "ping", IP)
  local re = {event.pull(5, "modem")}
  if re ~= nil then return re[3] else return end
end

function network.getValidIP(IP)
    if IP:find("^%d%d?%d?%.%d%d?%d?%.%d%d?%d?$") then
      return true
    end
    return false
end

function network.setIP(iface, IP, save)
  local info = {}
  local ok = false
  for i in io.lines("/etc/sys/network.cfg") do
    info[#info+1] = {}
    info[#info] = adv.split(i, ":")
  end
  local f = io.open("/etc/sys/network.cfg", "w")
  for i = 1, #info do
    if info[i][1] == iface then
      info[i][3] = IP
      if save then
        local all = {}
        local needL = 0
        for j in io.lines("/etc/sys/saveip") do
          all[#all+1] = j
          if all[#all] == "" then all[#all] = nil end
          if adv.split(all[#all], ":")[1] == info[i][2] then needL = #all; all[#all] = info[i][2] .. ":" .. IP end
        end
        if needL == 0 then all[#all+1] = info[i][2] .. ":" .. IP end
        adv.writeAllLines("/etc/sys/saveip", all)
      end
      ok = true
    end
    f:write(info[i][1] .. ":" .. info[i][2] .. ":" .. info[i][3] .. "\n")
  end
  f:close()
  return ok
end

function network.getSavedIP(addr)
  if not require("filesystem").exists("/etc/sys/saveip") then adv.makeFile("/etc/sys/saveip") end
  for i in io.lines("/etc/sys/saveip") do
    local a = adv.split(i, ":")
    if a[1] == addr then return a[2] end
  end
  local new = network.newIP(cp.proxy(addr))
  local f = io.open("/etc/sys/saveip", "a")
  f:write(addr .. ":" .. new .. "\n")
  f:close()
  return new
end

return network