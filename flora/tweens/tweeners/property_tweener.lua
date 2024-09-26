local tweener = require("flora.tweens.tweeners.tweener")

---
--- @class flora.tweens.tweeners.property_tweener : flora.tweens.tweeners.tweener
---
local property_tweener = tweener:extend()

function property_tweener:constructor(parent, object, property, initial_value, final_value, duration, ease)
    property_tweener.super.constructor(self, parent)

    ---
    --- @class table
    ---
    self.object = object

    ---
    --- @type string
    ---
    self.property = property

    ---
    --- @type number|table
    ---
    self.initial_value = initial_value

    ---
    --- @type number|table
    ---
    self.final_value = final_value

    ---
    --- @type number
    ---
    self.duration = nil

    ---
    --- @type function
    ---
    self.ease = ease

    ---
    --- @type number
    ---
    self.start_delay = 0.0

    ---
    --- @type number
    ---
    self.progress = nil

    ---
    --- @protected
    --- @type number
    ---
    self._elapsed_time = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._duration = duration
end

function property_tweener:delay(delay)
    self.start_delay = delay
end

function property_tweener:update(dt)
    self._elapsed_time = self._elapsed_time + dt
    if self._elapsed_time >= self.start_delay then
        local e = self.ease and self.ease or (self.parent.ease and self.parent.ease or ease.linear)
        self.object[self.property] = math.lerp(self.initial_value, self.final_value, e(self.progress))
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function property_tweener:__get(var)
    if var == "duration" then
        return self._duration + self.start_delay

    elseif var == "progress" then
        if self._elapsed_time <= self.start_delay then
            return 0.0
        end
        return (self._elapsed_time - self.start_delay) / self._duration
    end
    return property_tweener.super.__get(self, var)
end

---
--- @protected
---
function property_tweener:__set(var, val)
    if var == "duration" then
        self._duration = val
        return false
    end
    return true
end

return property_tweener