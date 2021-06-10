local args = {...}

if not require("perm").getUsr("unset") then io.write("\27[31mPermission denied\27[m\n");return end

if #args < 1 then
  io.write("Usage: unset <varname>[ <varname2> [...]]\n")
else
  for _, k in ipairs(args) do
    os.setenv(k, nil)
  end
end
