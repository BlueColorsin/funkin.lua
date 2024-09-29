---
--- @class flora.math.vector2
---
--- A basic class for storing a 2D vector.
---
local vector2 = class:extend("vector2", ...)

function vector2:constructor(x, y)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
end

---
--- Rounds the vector to the nearest whole number.
---
function vector2:round()
    return vector2:new(math.round(self.x), math.round(self.y))
end

---
--- Floors the vector to the nearest whole number.
---
function vector2:floor()
    return vector2:new(math.floor(self.x), math.floor(self.y))
end

---
--- Copies the components of the given vector to this vector.
--- 
--- @param  vec  flora.math.vector2  The vector to copy.
---
function vector2:copy_from(vec)
    self.x = vec.x
    self.y = vec.y
    return self
end

---
--- Sets the components of this vector to given values.
--- 
--- @param  x  number  The new value for the X component
--- @param  y  number  The new value for the Y component
---
function vector2:set(x, y)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
    return self
end

---
--- Adds two values to this vector.
---
function vector2:add(x, y)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

---
--- Subtracts two values from this vector.
---
function vector2:subtract(x, y)
    self.x = self.x - x
    self.y = self.y - y
    return self
end

---
--- Multiplies two values to this vector.
---
function vector2:multiply(x, y)
    self.x = self.x * x
    self.y = self.y * y
    return self
end

---
--- Divides two values from this vector.
---
function vector2:divide(x, y)
    self.x = self.x / x
    self.y = self.y / y
    return self
end

---
--- Mods two values to this vector.
---
function vector2:modulo(x, y)
    self.x = self.x % x
    self.y = self.y % y
    return self
end

---
--- Pows two values to this vector.
---
function vector2:pow(x, y)
    self.x = self.x ^ x
    self.y = self.y ^ y
    return self
end

---
--- Returns a string representation of this vector.
---
function vector2:__tostring()
    return "vector2(" .. self.x .. ", " .. self.y .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- Adds two vectors and returns the result.
---
function vector2.__add(a, b)
    return a:add(b.x, b.y)
end

---
--- Subtracts two vectors and returns the result.
---
function vector2.__sub(a, b)
    return a:subtract(b.x, b.y)
end

---
--- Multiplies two vectors and returns the result.
---
function vector2.__mul(a, b)
    return a:multiply(b.x, b.y)
end

---
--- Divides two vectors and returns the result.
---
function vector2.__div(a, b)
    return a:divide(b.x, b.y)
end

---
--- Negates two vectors and returns the result.
---
function vector2.__unm(a)
    a.x = -a.x
    a.y = -a.y
    return a
end

---
--- Modulos two vectors and returns the result.
---
function vector2.__mod(a, b)
    return a:modulo(b.x, b.y)
end

---
--- Pows two vectors and returns the result.
---
function vector2.__pow(a, b)
    return a:pow(b.x, b.y)
end

return vector2