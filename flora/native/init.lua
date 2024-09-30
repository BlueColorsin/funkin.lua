---
--- @class flora.native
---
--- A class for easily accessing native system functionality.
---
local native = {}
native.consoleColor = {
	black = 0,
	dark_blue = 1,
	dark_green = 2,
	dark_cyan = 3,
	dark_red = 4,
	dark_magenta = 5,
	dark_yellow = 6,
	light_gray = 7,
	gray = 8,
	blue = 9,
	green = 10,
	cyan = 11,
	red = 12,
	magenta = 13,
	yellow = 14,
	white = 15,
	none = -1
}

function native.askOpenFile(title, file_types)
	return ""
end
function native.askSaveAsFile(title, file_types, initial_file)
	return ""
end
function native.setCursor(type) end
function native.setDarkMode(enable) end
function native.setConsoleColors(fg_color, bg_color) end

-----------------------------------------
-- Don't worry about the stuff below!! --
-----------------------------------------

local os = love.system.getOS()
local os_native = {}

if os == "Windows" then
	os_native = require((...) .. ".windows")
end

local ret_native = Class:extend()
for key, value in pairs(native) do
	if os_native[key] then
		ret_native[key] = os_native[key]
	else
		ret_native[key] = value
	end
end

return ret_native