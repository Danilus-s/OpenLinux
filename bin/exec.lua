local sh = require("sh")
local shell = require("shell")
local fs = require("filesystem")
local uni = require("unicode")

if not require("perm").getUsr("exec") then io.write("\27[31mPermission denied\27[m\n");return end

if ... == nil then print("Use `exec [filename]'");return end
if not fs.exists(shell.resolve(...)) then print("File not found");return end
if string.sub(shell.resolve(...), uni.wlen(shell.resolve(...))-2) ~= ".sh" then print("File not .sh");return end

for l in io.lines(shell.resolve(...)) do
    sh.execute(_ENV, l)
end