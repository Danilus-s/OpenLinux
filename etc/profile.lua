local shell = require("shell")
local tty = require("tty")
local fs = require("filesystem")
local perm = require("perm")

if tty.isAvailable() then
  if io.stdout.tty then
    io.write("\27[40m\27[37m")
    tty.clear()
  end
end



os.setenv("USER", "root")

shell.setAlias("dir", "ls")
shell.setAlias("move", "mv")
shell.setAlias("rename", "mv")
shell.setAlias("copy", "cp")
shell.setAlias("del", "rm")
shell.setAlias("md", "mkdir")
shell.setAlias("cls", "clear")
shell.setAlias("rs", "redstone")
shell.setAlias("view", "edit -r")
shell.setAlias("help", "man")
shell.setAlias("cp", "cp -i")
shell.setAlias("l", "ls -lhp")
shell.setAlias("..", "cd ..")
shell.setAlias("df", "df -h")
shell.setAlias("grep", "grep --color")
shell.setAlias("more", "less --noback")
shell.setAlias("reset", "resolution `cat /dev/components/by-type/gpu/0/maxResolution`")

os.setenv("EDITOR", "/bin/edit")
os.setenv("HISTSIZE", "10")
os.setenv("IFS", " ")
os.setenv("MANPATH", "/usr/man:.")
os.setenv("PAGER", "less")
os.setenv("PS1", "\27[40m\27[31m$USER@$PCNAME\27[37m:\27[34m$PWD\27[37m$ \27[37m")
os.setenv("LS_COLORS", "di=0;36:fi=0:ln=0;33:*.lua=0;32")
--do not delete next line!
--trigger
os.setenv("PCNAME", "Danilus")
os.setenv("HOME", "/home")

if os.getenv("SU") == "true" then os.setenv("USER", "root") else os.setenv("USER", "user") end

::usr::
if os.getenv("USER") ~= nil then
  local d = perm.getUser(os.getenv("USER"))
  os.setenv("HOME", d[3])
else
  os.setenv("USER", "user")
  goto usr
end

local v = os.getenv("USER")
os.setenv("USER", "root")

shell.setWorkingDirectory(os.getenv("HOME"))
local home_shrc = shell.resolve(".shrc")
if fs.exists(home_shrc) then
  loadfile(shell.resolve("source", "lua"))(home_shrc)
end

os.setenv("USER", v)
if os.getenv("USER") == "root" then os.setenv("PS1", "\27[42m\27[31m$USER\27[40m@$PCNAME\27[37m:\27[34m$PWD\27[37m$ \27[37m") end

dofile("/etc/motd")