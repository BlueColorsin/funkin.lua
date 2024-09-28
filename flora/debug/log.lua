---
--- @class flora.debug.log
---
--- A class for logging to the console and debug menu.
---
local log = class:extend()

-- TODO: clean this shit up

function log:constructor()
    self._type = "log"
end

---
--- Logs something to the console and debugger.
---
--- @param  output  any  What you want to log.
---
function log:print(output, cur_file, cur_line)
    cur_file = cur_file and cur_file or debug.getinfo(2, "S").source:sub(2)
    cur_line = cur_line and cur_line or debug.getinfo(2, "l").currentline
    flora.native.set_console_colors(flora.native.console_color.cyan)
    
    io.stdout:write("[  PRINT  | " .. cur_file .. ":" .. cur_line .. " ] ")
    io.stdout:flush()

    flora.native.set_console_colors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as a warning.
---
--- @param  output  any  What you want to log.
---
function log:warn(output, cur_file, cur_line)
    cur_file = cur_file and cur_file or debug.getinfo(2, "S").source:sub(2)
    cur_line = cur_line and cur_line or debug.getinfo(2, "l").currentline
    flora.native.set_console_colors(flora.native.console_color.yellow)
    
    io.stdout:write("[ WARNING | " .. cur_file .. ":" .. cur_line .. " ] ")
    io.stdout:flush()

    flora.native.set_console_colors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as an error.
---
--- @param  output  any  What you want to log.
---
function log:error(output, cur_file, cur_line)
    cur_file = cur_file and cur_file or debug.getinfo(2, "S").source:sub(2)
    cur_line = cur_line and cur_line or debug.getinfo(2, "l").currentline
    flora.native.set_console_colors(flora.native.console_color.dark_red)
    
    io.stdout:write("[  ERROR  | " .. cur_file .. ":" .. cur_line .. " ] ")
    io.stdout:flush()

    flora.native.set_console_colors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as a success log.
---
--- @param  output  any  What you want to log.
---
function log:success(output, cur_file, cur_line)
    cur_file = cur_file and cur_file or debug.getinfo(2, "S").source:sub(2)
    cur_line = cur_line and cur_line or debug.getinfo(2, "l").currentline
    flora.native.set_console_colors(flora.native.console_color.green)
    
    io.stdout:write("[ SUCCESS | " .. cur_file .. ":" .. cur_line .. " ] ")
    io.stdout:flush()

    flora.native.set_console_colors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Logs something to the console and debugger, as a verbose log.
---
--- @param  output  any  What you want to log.
---
function log:verbose(output, cur_file, cur_line)
    cur_file = cur_file and cur_file or debug.getinfo(2, "S").source:sub(2)
    cur_line = cur_line and cur_line or debug.getinfo(2, "l").currentline
    flora.native.set_console_colors(flora.native.console_color.magenta)
    
    io.stdout:write("[ VERBOSE | " .. cur_file .. ":" .. cur_line .. " ] ")
    io.stdout:flush()

    flora.native.set_console_colors()

    io.stdout:write(tostring(output) .. "\n")
    io.stdout:flush()
end

---
--- Returns a string representation of this object.
---
function log:__tostring()
    return "log"
end

return log