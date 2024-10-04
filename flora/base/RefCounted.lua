---
--- @class flora.base.RefCounted : flora.base.Object
---
--- A base class for reference-counted objects.
---
local RefCounted = Object:extend("RefCounted", ...)

---
--- Constructs a new reference-counted object.
---
function RefCounted:constructor()
    RefCounted.super.constructor(self)

    self.references = nil
    
    self._references = 0
end

---
--- Increments the reference counter.
--- 
--- Use this only if you know what you're doing!
---
function RefCounted:reference()
    self.references = self.references + 1
end

---
--- Decrements the reference counter.
--- 
--- Use this only if you know what you're doing!
---
function RefCounted:unreference()
    self.references = self.references - 1
end

---
--- Returns a string representation of this object.
---
function RefCounted:__tostring()
    return self.__class .. " (refs: " .. self.references .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function RefCounted:get_references()
    return self._references
end

---
--- @protected
---
function RefCounted:set_references(val)
    self._references = val
    if self._references <= 0 then
        self:dispose()
        if Flora.config.debugMode then
            Flora.log:print("A " .. self.__class .. " object has no references, disposing!")
        end
    end
    return self._references
end

return RefCounted