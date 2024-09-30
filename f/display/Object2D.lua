--- 
--- A basic object with 2D positional and sizing data.
--- 
--- @class flora.display.Object2D : flora.base.Basic
--- 
local Object2D = Basic:extend("Object2D", ...)

---
--- Constructs a new Object2D.
---
function Object2D:constructor(x, y, width, height)
    Object2D.super.constructor(self)

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

function Object2D:setPosition(x, y)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
end

---
--- Returns a string representation of this object.
---
function Object2D:__tostring()
    return "Object2D (x: " .. self.x .. ", y: " .. self.y .. ")"
end

return Object2D