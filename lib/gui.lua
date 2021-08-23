local gpu = require("component").gpu
local th = require("thread")
local event = require("event")
local tty = require("tty")
local uni = require("unicode")
local kb = require("keyboard")
local sh = require("sh")

local bg = gpu.setBackground
local fg = gpu.setForeground

local fullX, fullY = gpu.getResolution()

local curApp = nil
local apps = {}
local trays = {}
local workX, workY, workW, workH = 1,2,fullX,fullY-4

local gui = {}

local metatable = {
  __index = gui
}

local function clear()
	bg(0x000000)
	gpu.fill(1,1,workW,workH+1, " ")
end

function gui.getWorkArea()
	return workX, workY, workW, workH
end

function gui.update()
	clear()
	if curApp ~= nil then
		bg(0x505050)
		gpu.fill(workX,workY,workW,workH, " ")
		bg(0x707070)
		gpu.fill(1,1,workW,1, " ")
		bg(0xFF0000)
		gpu.fill(workW-1,1,2,1, " ")
		bg(0x707070)
		fg(0x000000)
		local gX = fullX/2-#curApp.name/2
		gpu.set(gX,1,sh.expand(curApp.name))
		bg(0x505050)
		
		bg(0xE0E0E0)
		local counter = 0
		for i = 1, #apps do
			if apps[i].tray then 
				gpu.fill(workW+counter+#trays*10,workY+2,10,3, " ")
				gpu.set(workW+counter+#trays*10,workY+3,string.sub(apps[i].name,1,10))
				counter = counter + 1
				trays[#trays+1] = apps[i]
			end
		end
		
		for i = 1, #curApp.items do
			if curApp.items[i].type == "label" then
				fg(curApp.items[i].color or 0x000000)
				gpu.set(curApp.items[i].x, curApp.items[i].y, sh.expand(curApp.items[i].text))
			elseif curApp.items[i].type == "checkBox" then
				fg(curApp.items[i].color or 0x000000)
				local state = uni.char(9744)
				if curApp.items[i].checked then state = uni.char(9745) end
				gpu.set(curApp.items[i].x, curApp.items[i].y, state .. " " .. sh.expand(curApp.items[i].text))
			end
		end
	end
end

function gui.newApp()
	app = {name = "newApp", border = true, backColor = 0xe0e0e0, tray = true, items = {}}
	apps[#apps+1] = app
	if curApp == nil then curApp = app end
	return setmetatable(app, metatable)
end

function gui.kill(app)
	if curApp == app then curApp = nil end
	for i = 1, #apps do
		if apps[i] == app then apps[i] = nil return true end
	end
	return false
end

function gui:newLabel(x,y,text)
	self.items[#self.items+1] = {type = "label", x = x,y = y,color = nil, text = text}
end
function gui:newCheckBox(x,y,text,func)
	self.items[#self.items+1] = {type = "checkBox", x = x,y = y,color = nil, text = text, checked = false, func = (func or nil)}
end

function gui.read(x,y,maxX,arg)
  --[[
  pwdchar:char
  maxlen:num
  numonly:bool
  passwd:bool
  ]]
  local ch = "┃"--uni.char(9614)
  x = x or 1
  y = y or 1
  maxX = maxX or 25
  arg = arg or {}
  local useChar = false
  if arg.pwdchar then useChar = true arg.pwdchar = string.sub(arg.pwdchar,1,1) end
  local input = ""
  local curX = uni.len(input)
  gpu.set(x,y,ch .. string.rep(" ",maxX-1))
  local startX, endX = 1,1
  while true do
    r = {event.pull()}
	if r[1] == "key_down" then
      -- Return
      if r[3] == 13 then
	    if useChar then
	  	  if uni.len(input) > maxX then gpu.set(x,y,string.sub(string.rep(arg.pwdchar,#input) .. " ", uni.len(input)+1-maxX)) else gpu.set(x,y,string.rep(arg.pwdchar,#input) .. " ") end
	    else
		  if uni.len(input) > maxX then gpu.set(x,y,string.sub(input .. " ", uni.len(input)+1-maxX)) else gpu.set(x,y,input .. " ") end
	    end
	    return input
      -- Backspace
	  elseif r[4] == 14 then
	    if curX > 0 then
	      if curX ~= uni.len(input) then
	        input = uni.sub(input, 1, curX-1) .. uni.sub(input, curX+1)
	      else
	        input = uni.sub(input, 1, -2)
	      end
	      curX = curX - 1
		  endX = uni.len(input)
		  --if uni.len(input) <= maxX then endX = endX - 1 end
	      if startX > 1 then startX = startX - 1;endX = uni.len(input) + 1 end
	    end
	  -- Delete
	  elseif r[4] == 211 then
	    if curX < uni.len(input) then
	      if curX ~= 0 then
	        input = uni.sub(input, 1, curX) .. uni.sub(input, curX+2)
	      else
	        input = uni.sub(input, 2)
	      end
		  if uni.len(input) < maxX then endX = endX - 1 end
	    end
	  -- Home
	  elseif r[4] == 199 then
	    curX = 0
	    startX = 1
	    if endX > maxX then endX = maxX end
	  -- End
	  elseif r[4] == 207 then
	    curX = uni.len(input)
	    endX = uni.len(input)
	    if uni.len(input) > maxX then startX = endX - maxX + 1 end
	    if startX > 1 then endX = uni.len(input) + 1 end
	  -- Arows
	  elseif r[4] == 203 then
	    if curX > 0 then
	      curX = curX - 1
		  if curX < startX-1 then startX = startX - 1; endX = endX - 1 end
	    end
	  elseif r[4] == 205 then
	    if curX < uni.len(input) then curX = curX + 1 end 
	    if curX > endX then if uni.len(input) > maxX then startX = startX + 1 end endX = endX + 1 end
	  elseif r[3] == 0 then
	  elseif not kb.isControlDown() then
	    if uni.len(input) >= (arg.maxlen or 32) and arg.maxlen ~= nil then goto skip end
		local char = uni.char(r[3])
		if r[4] == 15 then char = "  " end
		input = uni.sub(input,1,curX) .. char .. uni.sub(input,curX+1)--gui.read(1,1,8)
		curX = curX + 1
		if r[4] == 15 then curX = curX + 1 end
		endX = uni.len(input)
		if uni.len(input) >= maxX then startX = --[[curX - maxX+2]] startX + 1 end
		if startX > 1 then endX = uni.len(input) + 1 end
		::skip::
	  end
    elseif r[1] == "clipboard" then
	  local text = r[3]
	  if arg.maxlen then text = text:sub(1,arg.maxlen - uni.len(input)) end
	  input = uni.sub(input,1,curX) .. text .. uni.sub(input,curX+1)--gui.read(1,1,8)
	  curX = curX + uni.len(text)
	  endX = uni.len(input)
	  if uni.len(input) >= maxX then startX = --[[curX - maxX+2]] startX + uni.len(text) end
	  if startX > 1 then endX = uni.len(input) + 1 end
	elseif r[1] == "touch" then
	  if x+startX-3+r[3] <= endX-startX+x and r[4] == y then curX = x+startX-3+r[3] end
	end
	gpu.fill(x,y,maxX,1," ")
    if useChar then
      if uni.len(input)+1 > maxX then gpu.set(x,y,string.sub(string.rep(arg.pwdchar,#input), --[[uni.len(input)+1-maxX+1]] startX, endX-1)) else gpu.set(x,y,string.rep(arg.pwdchar,#input)) end
    else
	  if uni.len(input)+1 > maxX then gpu.set(x,y,string.sub(input, --[[uni.len(input)+1-maxX+1]] startX, endX-1)) else gpu.set(x,y,input) end
    end
    --f curX >= endX - startX+1 then gpu.set(curX-startX+2,y, ch) else gpu.set(curX+1,y, ch) end
    gpu.set(x-1+curX-startX+2,y, ch)
    --gpu.set(x,y+1, "curX=" .. curX .. ", len="..uni.len(input)..", start="..startX..", end="..endX.."       ")
  end
end

local function even (...)
	local e = {...}
	local x,y = e[3],e[4]
	
	if x >= 147 and  x <= workW and y >= 1 and y <= 3 then 
		if curApp ~= nil then gui.kill(curApp) end
		gui.update()
	end
	for _,v in pairs(curApp.items) do
		if v.type == "checkBox" then 
			if x >= v.x and x <= 2+uni.len(v.text) and y >= v.y and y <= v.y then
				v.checked = not v.checked
				if v.func then v.func() end
			end
		end
	end
	gui.update()
end
function gui.init()
	event.listen("touch", even)
end

function gui.stop()
	event.ignore("touch", even)
end

return gui