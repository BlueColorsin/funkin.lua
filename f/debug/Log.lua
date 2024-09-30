---
--- @class flora.debug.Log
---
--- A class for logging to the console and debug menu.
---
local Log = Class:extend("Log", ...)

-- TODO: clean this shit up

---
--- Logs something to the console and debugger.
---
--- @param  output  any  What you want to log.
---
function Log:print(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    flora.native.setConsoleColors(flora.native.consoleColor.cyan)
    
    io.stdout:write("[  PRINT  | " .. curFile .. ":" .. curLine .. " ] ")
    io.stdout:flush()

    flora.native.setConsoleColors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as a warning.
---
--- @param  output  any  What you want to log.
---
function Log:warn(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    flora.native.setConsoleColors(flora.native.consoleColor.yellow)
    
    io.stdout:write("[ WARNING | " .. curFile .. ":" .. curLine .. " ] ")
    io.stdout:flush()

    flora.native.setConsoleColors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as an error.
---
--- @param  output  any  What you want to log.
---
function Log:error(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    flora.native.setConsoleColors(flora.native.consoleColor.dark_red)
    
    io.stdout:write("[  ERROR  | " .. curFile .. ":" .. curLine .. " ] ")
    io.stdout:flush()

    flora.native.setConsoleColors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as a success log.
---
--- @param  output  any  What you want to log.
---
function Log:success(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    flora.native.setConsoleColors(flora.native.consoleColor.green)
    
    io.stdout:write("[ SUCCESS | " .. curFile .. ":" .. curLine .. " ] ")
    io.stdout:flush()

    flora.native.setConsoleColors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as a verbose log.
---
--- @param  output  any  What you want to log.
---
function Log:verbose(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    flora.native.setConsoleColors(flora.native.consoleColor.magenta)
    
    io.stdout:write("[ VERBOSE | " .. curFile .. ":" .. curLine .. " ] ")
    io.stdout:flush()

    flora.native.setConsoleColors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Returns a string representation of this object.
---
function Log:__tostring()
    return "log"
end

return Log