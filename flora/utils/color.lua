local bit = require("flora.utils.bit")

---
--- A simple class storing RGBA values for a color.
---
--- @class flora.utils.color
---
local color = class:extend()

function color:constructor(data)
	---
	--- The value of the red channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.r = 0.0

	---
	--- The value of the green channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.g = 0.0

	---
	--- The value of the blue channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.b = 0.0

	---
	--- The value of the alpha channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.a = 0.0

    if data then
        local t = type(data)
        if t == "string" then
            self.r, self.g, self.b, self.a = self.int_to_rgb(tonumber(data:replace("#", "0x")))
        elseif t == "number" or t == "integer" then
            self.r, self.g, self.b, self.a = self.int_to_rgb(data)
        elseif t == "table" then
            self.r, self.g, self.b, self.a = data.r, data.g, data.b, data.a
        else
            flora.log:error("Cannot convert type: " .. t .. " into a color!")
        end
    end
end

function color:interpolate(other, ratio)
	return color:new({
		r = math.lerp(self.r, other.r, ratio),
		g = math.lerp(self.g, other.g, ratio),
		b = math.lerp(self.b, other.b, ratio),
		a = math.lerp(self.a, other.a, ratio)
	})
end

function color:copy_from(other)
    self.r = other.r
    self.g = other.g
    self.b = other.b
    self.a = other.a
    return self
end

function color.int_to_rgb(int)
	return
		bit.band(bit.rshift(int, 16), 0xFF) / 255,
		bit.band(bit.rshift(int, 8), 0xFF) / 255,
		bit.band(int, 0xFF) / 255,
		bit.band(bit.rshift(int, 24), 0xFF) / 255
end

function color.int_to_rgb255(int)
	return
		bit.band(bit.rshift(int, 16), 0xFF),
		bit.band(bit.rshift(int, 8), 0xFF),
		bit.band(int, 0xFF),
		bit.band(bit.rshift(int, 24), 0xFF)
end

function color:__tostring()
	return "color (r: " .. self.r .. ", g: " .. self.g .. ", b: " .. self.b .. ", a: " .. self.a .. ")"
end

color.transparent = color:new(0x00000000)
color.white       = color:new(0xFFFFFFFF)
color.gray        = color:new(0xFF808080)
color.black       = color:new(0xFF000000)
color.red         = color:new(0xFFFF0000)
color.orange      = color:new(0xFFFFA500)
color.yellow      = color:new(0xFFFFFF00)
color.lime        = color:new(0xFF00FF00)
color.green       = color:new(0xFF008000)
color.cyan        = color:new(0xFF00FFFF)
color.blue        = color:new(0xFF0000FF)
color.purple      = color:new(0xFF800080)
color.magenta     = color:new(0xFFFF00FF)
color.pink        = color:new(0xFFFFC0CB)
color.brown       = color:new(0xFF8B4513)

return color