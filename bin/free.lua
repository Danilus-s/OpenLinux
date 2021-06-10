local computer = require("computer")
local total = computer.totalMemory()

if not require("perm").getUsr("free") then io.write("\27[31mPermission denied\27[m\n");return end

local max = 0
for _=1,40 do
  max = math.max(max, computer.freeMemory())
  os.sleep(0) -- invokes gc
end
io.write(string.format("Total%12d\nUsed%13d\nFree%13d\n", total, total - max, max))
