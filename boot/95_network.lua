local event = require("event")
local adv = require("adv")
local com = require("component")
local network = require("network")

local f = io.open("/etc/sys/network.cfg", "w")
f:write("")
f:close()
local wlanC = 0
local ethC = 0

com.modem.open(8)

local f = io.open("/etc/sys/network.cfg", "a")
for i in pairs(com.list("modem")) do
  local ip = network.getSavedIP(i)
  if com.invoke(i, "isWireless") then
      f:write("wlan" .. wlanC .. ":" .. i .. ":" .. ip .."\n")
      wethC = wethC + 1
    else
      f:write("eth" .. ethC .. ":" .. i .. ":" .. ip .."\n")
      ethC = ethC + 1
    end
end
f:close()

local function onComponentAdded(addr, comType)
  if comType == "modem" then
    for i in io.lines("/etc/sys/network.cfg") do
      local seg = adv.split(i, ":")
      if seg[2] == addr then goto skip end
    end
    local ip = network.getSavedIP(i)
    if com.invoke(addr, "isWireless") then
      local f = io.open("/etc/sys/network.cfg", "a")
      f:write("wlan" .. wlanC .. ":" .. addr .. ":" .. ip .."\n")
      wlanC = wlanC + 1
      f:close()
    else
      local f = io.open("/etc/sys/network.cfg", "a")
      f:write("eth" .. ethC .. ":" .. addr .. ":" .. ip .."\n")
      ethC = ethC + 1
      f:close()
    end
  end
  ::skip::
end

local function onComponentRemoved(addr, comType)
  if comType == "modem" then
    local all = {}
    local needL = 0
    for i in io.lines("/etc/sys/network.cfg") do
      all[#all+1] = i
      local seg = adv.split(i, ":")
      if seg[2] == addr then needL = #all end
    end
    if needL == 0 then goto skip end
    local f = io.open("/etc/sys/network.cfg", "w")
    for i = 1, #all do
      if i == needL then goto no end
      f:write(all[i])
      ::no::
    end
  end
  ::skip::
end

event.listen("component_added", onComponentAdded)
event.listen("component_removed", onComponentRemoved)