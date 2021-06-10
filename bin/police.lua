local uni = require("unicode")
local tty = require ("tty")
local c = require("component")
local e = require("event")
local g = c.gpu
local st1, st2, sp = uni.char(9617)..uni.char(9617), uni.char(9619)..uni.char(9619), uni.char(9618)
local x,y = tty.getCursor()
local ex = true
local function ev(...)
    local arg = {...}
    e.ignore("interrupted", ev)
    ex = false
    return
end
e.listen("interrupted", ev)
while ex do
    for i = 1, 10 do
        tty.setCursor(x, y)
        io.write("\27[31m"..st1..st1..st1.."\27[m"..sp.."\27[34m"..st2..st2..st2.."\27[m")
        if ex == false then break end
        os.sleep(0.2)
        tty.setCursor(x, y)
        io.write("\27[31m"..st2..st2..st2.."\27[m"..sp.."\27[34m"..st1..st1..st1.."\27[m")
        if ex == false then break end
        os.sleep(0.2)
    end
    for i = 1, 10 do
        tty.setCursor(x, y)
        io.write("\27[31m"..st1..st2..st1.."\27[m"..sp.."\27[34m"..st2..st1..st2.."\27[m")
        if ex == false then break end
        os.sleep(0.2)
        tty.setCursor(x, y)
        io.write("\27[31m"..st2..st1..st2.."\27[m"..sp.."\27[34m"..st1..st2..st1.."\27[m")
        if ex == false then break end
        os.sleep(0.2)
    end
end
tty.setCursor(x, y)
io.write("meow ^^                       ")