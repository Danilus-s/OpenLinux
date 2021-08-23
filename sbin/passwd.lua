local shell = require("shell")
local perm = require("perm")
local term = require("term")
local sha = require("sha2")
local text = require("text")
local adv = require("adv")

local args,opts = shell.parse(...)
local needUsr
local needL

if perm.getPerm(perm.getVar("user")) ~= 1 then
    needUsr = perm.getVar("user")
elseif perm.getPerm(perm.getVar("user")) == 1 then
    if opts.u then
        needUsr = args[1]
    else
        needUsr = perm.getVar("user")
    end
end

local psw = {}
for l in io.lines("/etc/sys/passwd") do
    psw[#psw + 1] = l
    if adv.split(l, ":")[1] == needUsr then
        needL = #psw
    end
end
if needL == nil then
    print("passwd: User not found.")
    return
end
local curData = adv.split(psw[needL], ":")

if perm.getPerm(perm.getVar("user")) ~= 1 then
    io.write("Current password: ")
    local curPass = perm.read()
    io.write("\n")
    if curData[3] ~= sha.sha3_256(curPass) then print("passwd: Current password mismatch.");return end
end
io.write("New password: ")
local newPass = perm.read()
io.write("\n")
io.write("Type again: ")
local agaPass = perm.read()
io.write("\n")

if agaPass ~= newPass then
    print("passwd: Password mismatch")
    return
end
psw[needL] = curData[1] .. ":" .. curData[2] .. ":" .. sha.sha3_256(newPass) .. ":" .. curData[4]


local file, re = io.open("/etc/sys/passwd", "w")
if not file then print("passwd: " .. re) return end
for i = 1, #psw-1 do
  file:write(psw[i] .. "\n")
end
file:write(psw[#psw])
file:close()