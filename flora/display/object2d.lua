--- 
--- A basic object with 2D positional and sizing data.
--- 
--- @class flora.display.object2d : flora.base.basic
--- 
local object2d = basic:extend("object2d", ...)

---
--- Constructs a new object2d.
---
function object2d:constructor(x, y, width, height)
    object2d.super.constructor(self)

    ---
    --- The X coordinate of this object on-screen.
    ---
    self.x = x and x or 0.0

    ---
    --- The Y coordinate of this object on-screen.
    ---
    self.y = y and y or 0.0

    ---
    --- The width of this object. (in pixels)
    ---
    self.width = width and width or 0.0

    ---
    --- The height of this object. (in pixels)
    ---
    self.height = height and height or 0.0
end

function object2d:set_position(x, y)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
end

---
--- Returns a string representation of this object.
---
function object2d:__tostring()
    return "object2d (x: " .. self.x .. ", y: " .. self.y .. ")"
end

return object2d