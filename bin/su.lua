local shell = require("shell")
local sh = require("sh")
local perm = require("perm")

if not require("perm").getUsr("su") then io.write("\27[31mPermission denied\27[m\n");return end

--shell.setWorkingDirectory(d[4])
os.setenv("USER", "root")
os.setenv("SU", "true")
os.setenv("HOME", "/root")
sh.execute(_ENV, "/bin/sh.lua")
os.setenv("SU", "false")
--dofile("/etc/profile.lua")