---
--- @class flora.base.object
---
--- A base object class for flora.
---
local object = class:extend()

---
--- Constructs a new object.
---
function object:constructor()
end

---
--- Removes this object and it's properties from memory.
---
function object:dispose()
end

---
--- Returns a string representation of this object.
---
function object:__tostring()
    return "object"
end

return object