local shell = require("shell")
local perm = require("perm")
local term = require("term")
local sha = require("sha2")
local text = require("text")

local args,opts = shell.parse(...)
local needUsr
local needL

if os.getenv("USER") == "user" then
    needUsr = os.getenv("USER")
elseif os.getenv("USER") == "root" then
    if opts.u then
        needUsr = args[1]
    else
        needUsr = os.getenv("USER")
    end
end

local psw = {}
for l in io.lines("/etc/sys/passwd") do
    psw[#psw + 1] = l
    if perm.split(l, ":")[1] == needUsr then
        needL = #psw
    end
end
if needL == nil then
    print("User not found")
    return
end
local curData = perm.split(psw[needL], ":")

if os.getenv("USER") == "user" then
    io.write("Current password: ")
    term.setCursorBlink(false)
    local curPass = text.trim(term.read(nil,nil,nil," "))
    term.setCursorBlink(true)
    io.write("\n")

    if curData[2] ~= sha.sha3_256(curPass) then print("Current password mismatch");return end
end
io.write("New password: ")
term.setCursorBlink(false)
local newPass = text.trim(term.read(nil,nil,nil," "))
term.setCursorBlink(true)
io.write("\n")
io.write("Type again: ")
term.setCursorBlink(false)
local agaPass = text.trim(term.read(nil,nil,nil," "))
term.setCursorBlink(true)
io.write("\n")

if agaPass ~= newPass then
    print("Password mismatch")
    return
end
psw[needL] = curData[1] .. ":" .. sha.sha3_256(newPass)

local textToWrite = ""
for i = 1, #psw-1 do
    textToWrite = textToWrite .. psw[i] .. "\n"
end
textToWrite = textToWrite .. psw[#psw]

local file = io.open("/etc/sys/passwd", "w")
file:write(textToWrite)
file:close()