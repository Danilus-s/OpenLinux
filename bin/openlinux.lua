local uni = require("unicode")
local term = require("term")
local e = require("event")
local cp = require("computer")

local c = uni.char(9619)..uni.char(9619)
local s = "  "
local text = {
    "",
    s..s..s..c..c..s..s..c..c..s..s..c..c..c..s..c..s..s..c,
    s..s..c..s..s..c..s..c..s..c..s..c..s..s..s..c..c..s..c,
    s..s..c..s..s..c..s..c..s..c..s..c..c..c..s..c..s..c..c,
    s..s..c..s..s..c..s..c..c..s..s..c..s..s..s..c..s..s..c,
    s..s..c..s..s..c..s..c..s..s..s..c..s..s..s..c..s..s..c,
    s..s..s..c..c..s..s..c..s..s..s..c..c..c..s..c..s..s..c,
    "",
    s..c..s..s..s..c..s..c..s..s..c..s..c..s..s..c..s..c..s..c,
    s..c..s..s..s..c..s..c..c..s..c..s..c..s..s..c..s..c..s..c,
    s..c..s..s..s..c..s..c..s..c..c..s..c..s..s..c..s..s..c..s,
    s..c..s..s..s..c..s..c..s..s..c..s..c..s..s..c..s..c..s..c,
    s..c..s..s..s..c..s..c..s..s..c..s..c..s..s..c..s..c..s..c,
    s..c..c..c..s..c..s..c..s..s..c..s..s..c..c..s..s..c..s..c,
    ""
}
term.clear()
for i = 1, #text do
    print(text[i])
end
if ... ~= "meow" then
    print(_ENV._OSVERSION)
    print(math.floor(cp.totalMemory() / 1024) .. "k RAM")
    print("PC name: " .. os.getenv("PCNAME"))
    local out = {0,0,0,0}
    if cp.uptime() > 86400 then 
        out[1] = math.floor(cp.uptime()/86400)
        out[2] = math.fmod(math.fmod(math.floor(cp.uptime()/3600), 3600), 24)
        out[3] = math.fmod(math.floor(cp.uptime()/60), 60)
        out[4] = math.floor(math.fmod(cp.uptime(), 60))
    elseif cp.uptime() > 3600 then 
        out[2] = math.floor(cp.uptime()/3600)
        out[3] = math.fmod(math.floor(cp.uptime()/60), 60)
        out[4] = math.floor(math.fmod(cp.uptime(), 60))
    elseif cp.uptime() > 60 then
        out[3] = math.floor(cp.uptime()/60)
        out[4] = math.fmod(math.floor(cp.uptime()/60), 60)
    else
        out[4] = math.floor(cp.uptime())
    end
    print("Uptime: " .. out[1] .. " d " .. out[2] .. " h " .. out[3] .. " min " .. out[4] .. " sec")
    print("\n\n\n\nDanilus is cutie")
elseif ... == "meow" then
    local text2 = {
        "",
        s..s..s..s..c..s..s..s..s..s..s..s..s..s..c..s,
        s..s..s..s..c..c..s..s..s..s..s..s..s..c..c..s,
        s..s..s..s..c..s..c..c..c..c..c..c..c..s..c..s,
        s..s..s..c..s..s..s..s..s..s..s..s..s..s..s..c,
        s..s..s..c..s..s..s..c..s..s..s..c..s..s..s..c,
        s..s..s..c..s..s..s..s..s..s..s..s..s..s..s..c,
        s..s..s..c..s..s..c..s..s..c..s..s..c..s..s..c,
        s..s..s..c..s..s..s..c..c..s..c..c..s..s..s..c,
        s..s..s..s..c..s..s..s..s..s..s..s..s..s..c..s,
        ""
    }
    for i = 1, #text2 do
        print(text2[i])
    end
end
e.pull("interrupted")