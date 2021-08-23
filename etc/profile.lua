local shell = require("shell")
local tty = require("tty")
local fs = require("filesystem")
local perm = require("perm")
local uni = require("unicode")

if tty.isAvailable() then
  if io.stdout.tty then
    io.write("\27[40m\27[37m")
    tty.clear()
  end
end



--os.setenv("USER", "root")

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
os.setenv("PS1", "\27[31m" .. uni.char(9484) .. uni.char(9472) .. uni.char(9472) .. "(\27[36;1m$USER\27[40m@$PCNAME\27[31m)" .. uni.char(9472) .. "[\27[35;1m$PWD\27[31m]\n".. uni.char(9492) .. uni.char(9472) .."\27[36;1m$ \27[37m\27[30m\27[m")
os.setenv("LS_COLORS", "di=0;36:fi=0:ln=0;33:*.lua=0;32")
--do not delete next line!
--trigger
os.setenv("PCNAME", "user")
local d = perm.getUser(perm.getVar("defuser"))
os.setenv("HOME", d[4] or "/")
--print(d[1], d[4])
--io.read()
perm.setVar("user", perm.getVar("defuser"))

shell.setWorkingDirectory(os.getenv("HOME"))
local home_shrc = shell.resolve(".shrc")
if fs.exists(home_shrc) then
  loadfile(shell.resolve("source", "lua"))(home_shrc)
end

if perm.getPerm(perm.getVar("user")) == 1 then os.setenv("PS1", "\27[31m" .. uni.char(9484) .. uni.char(9472) .. uni.char(9472) .. "(\27[36;1m$USER\27[40m@$PCNAME\27[31m)" .. uni.char(9472) .. "[\27[35;1m$PWD\27[31m]\n".. uni.char(9492) .. uni.char(9472) .."\27[36;1m# \27[37m\27[30m\27[m") end

dofile("/etc/motd")