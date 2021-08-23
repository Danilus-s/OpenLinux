local it = require("internet")
local sh = require("shell")
local fs = require("filesystem")
local term = require("term")
local adv = require("adv")

if not fs.exists("/etc/apt") and not fs.isDirectory("/etc/apt") then fs.makeDirectory("/etc/apt") end

local args, opt = sh.parse(...)
if #args < 1 then
    print("Usage: apt [OPERATION]")
    print("  list:            List of all packages")
    print("  update:          Downloads up-to-date information about available software packages")
    print("  search <pkg>:    Search for available packages whose names contain the text `pkg'")
    print("  install <pkg>:   Installs the package named `pkg'")
    print("  upgrade [<pkg>]: Upgrade the package named `pkg' or all packages")
    print("  remove <pkg>:    Uninstall the software package named `pkg'")
    return
end
local function install(fi, gt, y)
    for i = 1, #fi do
        local data = adv.split(fi[i], ":")
        data[2] = require("text").trim(data[2])
        data[3] = require("text").trim(data[3])
        local url = "https://raw.githubusercontent.com/" .. data[3]
        if y == false then
            if data[1] == "dep" and fs.exists(data[2]) then
                goto skip
            end
            if data[1] == "file" and fs.exists(data[2]) then
                goto skip
            end
        end
        
        local f, reason = io.open(data[2], "w")
        if not f then
            print("Failed opening file for writing: " .. reason)
            return
        end
        io.write("Get data from: " .. url .. "... ")
        os.sleep(0)
        local result, response = pcall(it.request, url)
        if result then
            for chunk in response do
                f:write(chunk)
            end
            f:close()
            io.write("File `" .. data[2] .."' installed\n")
        else
            io.write("File `" .. data[2] .."' not installed\n")
            f:close()
            fs.remove(data[2])
        end
        ::skip::
    end
    if fs.exists("/etc/apt/installed") and not fs.isDirectory("/etc/apt/installed") then
        local inst = {}
        local f = io.open("/etc/apt/installed")
        while true do
            local t = f:read()
            if t ~= nil then
                inst[#inst + 1] = t
                if adv.split(t, ":")[1] == gt[1] then goto skip; break end
            else
                break
            end
        end
        f:close()
    end
    local f = io.open("/etc/apt/installed", "a")
    f:write(gt[1] .. ":" .. gt[2] .. "\n")
    f:close()
    ::skip::
end

if args[1] == "update" then
    local url = "https://raw.githubusercontent.com/Danilus-s/OC-APT/master/APTlist"
    local f, reason = io.open("/etc/apt/sources.list", "w")
    if not f then
        io.stderr:write("Failed opening file for writing: " .. reason)
        return
    end
    io.write("Get information from: " .. url .. "\n")
    os.sleep(0)
    local result, response = pcall(it.request, url)
    if result then
        for chunk in response do
            f:write(chunk)
        end
        f:close()
        io.write("Package list has been successfully updated\n")
    else
        io.write("Package list update error\n")
        f:close()
    end
elseif args[1] == "list" then
    for l in io.lines("/etc/apt/sources.list") do
        print(adv.split(l, ":")[1])
    end
elseif args[1] == "search" and args[2] ~= nil then
    for l in io.lines("/etc/apt/sources.list") do
        if string.find(string.lower(adv.split(l, ":")[1]), string.lower(args[2])) then
            print(adv.split(l, ":")[1])
        end
    end
elseif args[1] == "install" and args[2] ~= nil then
    local get
    for l in io.lines("/etc/apt/sources.list") do
        if string.lower(adv.split(l, ":")[1]) == string.lower(args[2]) then
            get = adv.split(l, ":")
            break
        end
    end
    if get == nil then print("Package `" .. args[2] .. "' not found");return end
    local url = "https://raw.githubusercontent.com/" .. get[2]
    local files = {}
    io.write("Get information from: " .. url .. "\n")
    os.sleep(0)
    local result, response = pcall(it.request, url)
    if result then
        for chunk in response do
            files = perm.split(chunk, "\n")
        end
    end
    install(files, get, false)
elseif args[1] == "upgrade" then
    if #args == 2 then
        local get
        for l in io.lines("/etc/apt/installed") do
            if string.lower(adv.split(l, ":")[1]) == string.lower(args[2]) then
                get = adv.split(l, ":")
                break
            end
        end
        if get == nil then print("Package `" .. args[2] .. "' not found");return end
        local url = "https://raw.githubusercontent.com/" .. get[2]
        local files = {}
        io.write("Get information from: " .. url .. "\n")
        os.sleep(0)
        local result, response = pcall(it.request, url)
        if result then
            for chunk in response do
                files = adv.split(chunk, "\n")
            end
        end
        install(files, get, true)
    elseif #args == 1 then
        local get
        for l in io.lines("/etc/apt/installed") do
            get = adv.split(l, ":")
            local url = "https://raw.githubusercontent.com/" .. get[2]
            local files = {}
            io.write("Get information from: " .. url .. "\n")
            os.sleep(0)
            local result, response = pcall(it.request, url)
            if result then
                for chunk in response do
                    files = adv.split(chunk, "\n")
                end
            end
            install(files, get, true)
        end
    end
elseif args[1] == "remove" and args[2] ~= nil then
    local get
    for l in io.lines("/etc/apt/installed") do
        if string.lower(adv.split(l, ":")[1]) == string.lower(args[2]) then
            get = adv.split(l, ":")
            break
        end
    end
    if get == nil then print("Package `" .. args[2] .. "' not found");return end
    local url = "https://raw.githubusercontent.com/" .. get[2]
    local files = {}
    io.write("Get information from: " .. url .. "\n")
    os.sleep(0)
    local result, response = pcall(it.request, url)
    if result then
        for chunk in response do
            files = adv.split(chunk, "\n")
        end
    end
    for i = 1, #files do
        if fs.exists(adv.split(files[i], ":")[3]) and not fs.isDirectory(perm.split(files[i], ":")[3]) and perm.split(files[i], ":")[1] == "file" then
            fs.remove(adv.split(files[i], ":")[3])
            print(adv.split(files[i], ":")[3])
        end
    end
    local inst = {}
    local f = io.open("/etc/apt/installed")
    while true do
        local t = f:read()
        if t ~= nil then
            if string.lower(perm.split(t, ":")[1]) == string.lower(args[2]) then goto skip end
            inst[#inst + 1] = t
            ::skip::
        else
            break
        end
    end
    f:close()
    f = io.open("/etc/apt/installed", "w")
    for i = 1, #inst do
        f:write(inst[i])
    end
    f:close()
end