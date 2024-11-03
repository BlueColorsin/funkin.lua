---
--- @class flora.Basic : flora.Object
---
--- A basic object class for flora, with a few flags
--- such as: `exists`, `active`, and `visible`.
---
local Basic = Object:extend("Basic", ...)

---
--- Constructs a new basic object.
---
function Basic:constructor()
    Basic.super.constructor(self)

    ---
    --- Whether or not this object is allowed to update and draw,
    --- regardless of the `active` and `visible` flags.
    ---
    self.exists = true

    ---
    --- Whether or not this object can update.
    ---
    self.active = true

    ---
    --- Whether or not this object can draw.
    ---
    self.visible = true

    ---
    --- The cameras that this object will draw to.
    --- 
    --- If specified as `nil`, then it will simply draw to
    --- the first available camera instead.
    ---
    self.cameras = nil

    ---
    --- @protected
    ---
    self._cameras = nil
end

---
--- Prevents this object from updating and drawing entirely,
--- regardless of the `active` and `visible` flags.
---
function Basic:kill()
    self.exists = false
end

---
--- Allows this object to update and draw again, if
--- said flags are set to `true`.
---
function Basic:revive()
    self.exists = true
end

---
--- Updates this object's properties and fields.
---
function Basic:update(dt)
end

---
--- Draws this object to the screen.
---
function Basic:draw()
end

---
--- Removes this object and it's properties from memory.
---
function Basic:dispose()
    self._cameras = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Basic:get_cameras()
    if not self._cameras then
        return Flora.cameras.defaultCameras
    end
    return self._cameras
end

---
--- @protected
---
function Basic:set_cameras(val)
    self._cameras = val
    return val
end

return Basic