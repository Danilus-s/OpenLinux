if not require("perm").getUsr("clear") then io.write("\27[31mPermission denied\27[m\n");return end

local tty = require("tty")
tty.clear()