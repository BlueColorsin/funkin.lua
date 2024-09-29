---
--- @class flora.base.ref_counted : flora.base.object
---
--- A base class for reference-counted objects.
---
local ref_counted = object:extend("ref_counted", ...)

---
--- Constructs a new reference-counted object.
---
function ref_counted:constructor()
    ref_counted.super.constructor(self)

    self.references = nil
    
    self._references = 0
end

---
--- Increments the reference counter.
--- 
--- Use this only if you know what you're doing!
---
function ref_counted:reference()
    self.references = self.references + 1
end

---
--- Decrements the reference counter.
--- 
--- Use this only if you know what you're doing!
---
function ref_counted:unreference()
    self.references = self.references - 1
end

---
--- Returns a string representation of this object.
---
function ref_counted:__tostring()
    return self.__class .. " (refs: " .. self.references .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function ref_counted:get_references()
    return self._references
end

---
--- @protected
---
function ref_counted:set_references(val)
    self._references = val
    if self._references <= 0 then
        self:dispose()
        if flora.config.debug_mode then
            flora.log:print("A ref_counted object has no references, disposing!")
        end
    end
    return self._references
end

return ref_counted