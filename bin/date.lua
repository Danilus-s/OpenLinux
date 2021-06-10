if not require("perm").getUsr("date") then io.write("\27[31mPermission denied\27[m\n");return end

io.write(os.date("%F %T").."\n")
