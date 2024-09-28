---
--- @class flora.base.basic : flora.base.object
---
--- A basic object class for flora, with a few flags
--- such as: `exists`, `active`, and `visible`.
---
local basic = object:extend("basic", ...)

---
--- Constructs a new basic object.
---
function basic:constructor()
    basic.super.constructor(self)

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
function basic:kill()
    self.exists = false
end

---
--- Allows this object to update and draw again, if
--- said flags are set to `true`.
---
function basic:revive()
    self.exists = true
end

---
--- Updates this object's properties and fields.
---
function basic:update(dt)
end

---
--- Draws this object to the screen.
---
function basic:draw()
end

---
--- Removes this object and it's properties from memory.
---
function basic:dispose()
    self._cameras = {}
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function basic:get_cameras()
    if not self._cameras then
        return flora.cameras.default_cameras
    end
    return self._cameras
end

---
--- @protected
---
function basic:set_cameras(val)
    self._cameras = val
    return val
end

return basic