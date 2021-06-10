local computer = require("computer")

if not require("perm").getUsr("reboot") then io.write("\27[31mPermission denied\27[m\n");return end

io.write("Rebooting...")
computer.shutdown(true)