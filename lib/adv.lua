local text = require("text")

local adv = {}

function adv.writeAllText(path, text)
	local f = io.open(path, "w")
	f:write(tostring(text))
	f:close()
end

function adv.writeAllLines(path, lines)
	if not type(lines) == "table" then return end
	local f = io.open(path, "w")
	for i = 1, #lines do
		f:write(tostring(lines[i] .. "\n"))
	end
	f:close()
end

function adv.appendAllText(path, text)
	local f = io.open(path, "a")
	f:write(tostring(text))
	f:close()
end

function adv.appendAllLines(path, lines)
	if not type(lines) == "table" then return end
	local f = io.open(path, "a")
	for i = 1, #lines do
		f:write(tostring(lines[i] .. "\n"))
	end
	f:close()
end

function adv.concatTable(table1, table2)
  for i=1,#t2 do
    table1[#table1+1] = table2[i]
  end
  return table1
end

function adv.split (inputstr, sep)
  if inputstr == nil then return "" end
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function adv.readCfg(path)
	cfg = {}
	for i in io.lines(path) do
		local a = adv.split(i, "=")
		cfg[text.trim(a[1])]=text.trim(a[2])
	end
	return cfg
end

function adv.duplicate(tab)
  local sec = {}
  local i,v = next(tab, nil)
  while i do
	sec[i] = v
	i,v = next(tab, i)
  end
  return sec
end

function adv.makeFile(path)
  local f, re = io.open(path, "w")
  if not f then return nil, re end
  f:write("")
  f:close()
  return true
end

return adv