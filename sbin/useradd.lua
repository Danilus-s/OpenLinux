local sha = require("sha2")
local shell = require("shell")
local perm = require("perm")
local fs = require("filesystem")

local args, opts = shell.parse(...)
if #args ~= 2 and not opts.p then
  io.write("Usage: useradd <name> <password> [-p]\n")
  io.write("  -p: not use password\n")
  return 1
end

local users = {}

local name = args[1]
local passwd
if opts.p then passwd = sha.sha3_256("") else passwd = sha.sha3_256(string.gsub(args[2], ":", "")) end

for i in io.lines("/etc/sys/passwd") do
  users[#users+1] = i
  if i == name then print("useradd: User `" .. name .. "' already exists.") return end
end

local newline = name .. ":2:" .. passwd .. ":/home/" .. name

local f, re = io.open("/etc/sys/passwd", "a")
if not f then print("useradd: "..re) return end
f:write("\n"..newline)
f:close()
fs.makeDirectory("/home/" .. name)