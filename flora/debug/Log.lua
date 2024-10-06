---
--- @class flora.debug.Log
---
--- A class for logging to the console and debug menu.
---
local Log = Class:extend("Log", ...)

---
--- Logs something to the console and debugger.
---
--- @param  output  any  What you want to log.
---
function Log:print(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    self:customizedPrint(output, " PRINT ", nil, Flora.native.consoleColor.CYAN, curFile, curLine)
end

---
--- Logs something to the console and debugger, as a warning.
---
--- @param  output  any  What you want to log.
---
function Log:warn(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    self:customizedPrint(output, "WARNING", nil, Flora.native.consoleColor.YELLOW, curFile, curLine)
end

---
--- Logs something to the console and debugger, as an error.
---
--- @param  output  any  What you want to log.
---
function Log:error(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    self:customizedPrint(output, " ERROR ", nil, Flora.native.consoleColor.RED, curFile, curLine)
end

---
--- Logs something to the console and debugger, as a success log.
---
--- @param  output  any  What you want to log.
---
function Log:success(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    self:customizedPrint(output, "SUCCESS", nil, Flora.native.consoleColor.GREEN, curFile, curLine)
end

---
--- Logs something to the console and debugger, as a verbose log.
---
--- @param  output  any  What you want to log.
---
function Log:verbose(output, curFile, curLine)
    curFile = curFile and curFile or debug.getinfo(2, "S").source:sub(2)
    curLine = curLine and curLine or debug.getinfo(2, "l").currentline
    self:customizedPrint(output, "VERBOSE", nil, Flora.native.consoleColor.MAGENTA, curFile, curLine)
end

---
--- Logs something to the console and debugger.
---
--- @param  output        any      What you want to log.
--- @param  logType       string   The log type printed to the console. (e.x. `"ERROR"`, `"WARNING"`, etc)
--- @param  outputColor?  integer  The color of the log printed to the console.
--- @param  logTypeColor  integer  The color of the log type printed to the console.
---
function Log:customizedPrint(output, logType, outputColor, logTypeColor, curFile, curLine)
    ---
    --- @type string
    ---
    curFile = curFile or debug.getinfo(2, "S").source:sub(2)
    local srcFolder = Flora.config.sourceFolder .. "/"
    if curFile:startsWith(srcFolder) then
        curFile = curFile:sub(#srcFolder + 1)
    end
    curLine = curLine or debug.getinfo(2, "l").currentline
    
    -- output time to console
    io.stdout:write("[ ")
    io.stdout:flush()

    Flora.native.setConsoleColors(Flora.native.consoleColor.DARK_MAGENTA)

    local time = os.date("*t")
    local hour = time.hour % 12
    if time.hour == 0 then
        hour = 12
    end
    io.stdout:write(tostring(hour):lpad(2, "0") .. ":" .. tostring(time.min):lpad(2, "0") .. ":" .. tostring(time.sec):lpad(2, "0"))
    io.stdout:flush()
    
    Flora.native.setConsoleColors()

    io.stdout:write(" | ")
    io.stdout:flush()

    Flora.native.setConsoleColors(logTypeColor)

    io.stdout:write(logType)
    io.stdout:flush()

    Flora.native.setConsoleColors()
    
    if curFile and #curFile > 0 then
        io.stdout:write(" ] ")
        io.stdout:flush()
        
        Flora.native.setConsoleColors(logTypeColor)

        io.stdout:write(curFile .. ":" .. curLine .. ": ")
        io.stdout:flush()

        Flora.native.setConsoleColors()
    else
        io.stdout:write(" ] ")
        io.stdout:flush()
    end
    Flora.native.setConsoleColors(outputColor and outputColor or Flora.native.consoleColor.NONE)
    
    io.stdout:write(tostring(output))
    io.stdout:flush()
    
    Flora.native.setConsoleColors()

    io.stdout:write("\r\n")
    io.stdout:flush()
end

---
--- Returns a string representation of this object.
---
function Log:__tostring()
    return "log"
end

return Log