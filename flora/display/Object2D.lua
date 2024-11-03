--- 
--- A basic object with 2D positional and sizing data.
--- 
--- @class flora.display.Object2D : flora.Basic
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
--- Centers this object to the middle of the screen.
---
--- @param  axes  integer  The axes to center this object on. (`X`, `Y`, or `XY`)
---
function Object2D:screenCenter(axes)
    if Axes.hasX(axes) then
        self.x = math.floor((Flora.gameWidth - self.width) * 0.5)
    end
    if Axes.hasY(axes) then
        self.y = math.floor((Flora.gameHeight - self.height) * 0.5)
    end
end

function Object2D:getMidpoint(vec)
    if not vec then
        vec = Vector2:new()
    end
    return vec:set(self.x + self.width * 0.5, self.y + self.height * 0.5)
end

---
--- Returns a string representation of this object.
---
function Object2D:__tostring()
    return "Object2D (x: " .. self.x .. ", y: " .. self.y .. ")"
end

return Object2D