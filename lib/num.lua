local gpu = require("component").gpu
local uni = require("unicode")--9617, 9618

local num1, num2 = uni.char(9617), uni.char(9619)
local sx, sy = gpu.getResolution()

local bg = gpu.setBackground
local fg = gpu.setForeground

local num = {}

--  =1=
--  2=3
--  =4=
--  5=6
--  =7=

num.numbers = {
--          1     2     3     4     5     6     7
  nul =   {num1, num1, num1, num1, num1, num1, num1},
  minus = {num1, num1, num1, num2, num1, num1, num1},
  n0 =    {num2, num2, num2, num1, num2, num2, num2},
  n1 =    {num1, num1, num2, num1, num1, num2, num1},
  n2 =    {num2, num1, num2, num2, num2, num1, num2},
  n3 =    {num2, num1, num2, num2, num1, num2, num2},
  n4 =    {num1, num2, num2, num2, num1, num2, num1},
  n5 =    {num2, num2, num1, num2, num1, num2, num2},
  n6 =    {num2, num2, num1, num2, num2, num2, num2},
  n7 =    {num2, num1, num2, num1, num1, num2, num1},
  n8 =    {num2, num2, num2, num2, num2, num2, num2},
  n9 =    {num2, num2, num2, num2, num1, num2, num2}
}

local function draw(mode, x, y, num)
  local toX,toY
  if mode == "v" then toX = 6; toY = 10 else toX = 20; toY = 3 end
  fg(0xFFFFFF)
  gpu.fill(x, y, toX, toY, num)
  bg(0x000000)
  if mode == "v" then 
	gpu.fill(x, y, 2, 1, " ")
	gpu.fill(x+4, y, 2, 1, " ")
	gpu.fill(x, y+toY-1, 2, 1, " ")
	gpu.fill(x+4, y+toY-1, 2, 1, " ")
  else
    gpu.fill(x, y, 2, 1, " ")
	gpu.fill(x+toX-2, y, 2, 1, " ")
	gpu.fill(x, y+toY-1, 2, 1, " ")
	gpu.fill(x+toX-2, y+toY-1, 2, 1, " ")
  end
end

local f = 1
local xx = sx - 4
function num.update(numbers)--table
	bg(0x000000)
	gpu.fill(1, 1, sx, sy, " ")
	draw("h", 9, 3,      numbers[1][1])--1
	draw("v", 3, 6,      numbers[1][2])--2
	draw("v", 29, 6,     numbers[1][3])--3
	draw("h", 9, 16,     numbers[1][4])--4
	draw("v", 3, 19,     numbers[1][5])--5
	draw("v", 29, 19,    numbers[1][6])--6
	draw("h", 9, 29,     numbers[1][7])--7

	draw("h", 45, 3,     numbers[2][1])
	draw("v", 39, 6,     numbers[2][2])
	draw("v", 65, 6,     numbers[2][3])
	draw("h", 45, 16,    numbers[2][4])
	draw("v", 39, 19,    numbers[2][5])
	draw("v", 65, 19,    numbers[2][6])
	draw("h", 45, 29,    numbers[2][7])

	draw("h", xx-59, 3,  numbers[3][1])
	draw("v", xx-39, 6,  numbers[3][3])
	draw("v", xx-65, 6,  numbers[3][2])
	draw("h", xx-59, 16, numbers[3][4])
	draw("v", xx-39, 19, numbers[3][6])
	draw("v", xx-65, 19, numbers[3][5])
	draw("h", xx-59, 29, numbers[3][7])

	draw("h", xx-23, 3,  numbers[4][1])
	draw("v", xx-3, 6,   numbers[4][3])
	draw("v", xx-29, 6,  numbers[4][2])
	draw("h", xx-23, 16, numbers[4][4])
	draw("v", xx-3, 19,  numbers[4][6])
	draw("v", xx-29, 19, numbers[4][5])
	draw("h", xx-23, 29, numbers[4][7])
	
	if f == 1 then 
		gpu.fill(sx/2-1, 10, 3, 2, num1)
		gpu.fill(sx/2-1, 23, 3, 2, num1)
	else
		gpu.fill(sx/2-1, 10, 3, 2, num2)
		gpu.fill(sx/2-1, 23, 3, 2, num2)
	end

	if f == 1 then f = 2 else f = 1 end
end

function num.clear()
  bg(0x000000)
  gpu.fill(1,1,sx,sy, " ")
end

return num