---
--- @class flora.native
---
--- A class for easily accessing native system functionality.
---
local native = {}
native.consoleColor = {
	BLACK = 0,
	DARK_BLUE = 1,
	DARK_GREEN = 2,
	DARK_CYAN = 3,
	DARK_RED = 4,
	DARK_MAGENTA = 5,
	DARK_YELLOW = 6,
	LIGHT_GRAY = 7,
	GRAY = 8,
	BLUE = 9,
	GREEN = 10,
	CYAN = 11,
	RED = 12,
	MAGENTA = 13,
	YELLOW = 14,
	WHITE = 15,
	NONE = -1
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