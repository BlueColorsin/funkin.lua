---
--- @class flora.base.object
---
--- A base object class for flora.
---
local object = class:extend("object", ...)

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

return object