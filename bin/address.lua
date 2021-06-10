if not require("perm").getUsr("address") then io.write("\27[31mPermission denied\27[m\n");return end
local computer = require("computer")
io.write(computer.address(),"\n")
