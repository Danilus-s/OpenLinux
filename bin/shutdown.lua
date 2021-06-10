local computer = require("computer")
local tty = require("tty")

if not require("perm").getUsr("shutdown") then io.write("\27[31mPermission denied\27[m\n");return end

tty.clear()
computer.shutdown()