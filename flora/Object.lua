---
--- @class flora.Object
---
--- A base object class for flora.
---
local Object = Class:extend("Object", ...)

---
--- Constructs a new object.
---
function Object:constructor()
end

---
--- Removes this object and it's properties from memory.
---
function Object:dispose()
end

return Object