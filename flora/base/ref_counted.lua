---
--- @class flora.base.ref_counted : flora.base.object
---
--- A base class for reference-counted objects.
---
local ref_counted = object:extend()

---
--- Constructs a new reference-counted object.
---
function ref_counted:constructor()
    ref_counted.super.constructor(self)

    self._type = "ref_counted"

    self.references = 0
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
    return "ref_counted (refs: " .. self.references .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

function ref_counted:__set(var, val)
    if var == "references" then
        if val <= 0 then
            self:dispose()
            if flora.config.debug_mode then
                flora.log:print("A ref_counted object has no references, disposing!")
            end
        end
    end
    return true
end

return ref_counted