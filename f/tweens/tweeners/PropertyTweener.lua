local Tweener = require("flora.tweens.tweeners.Tweener")

---
--- @class flora.tweens.tweeners.PropertyTweener : flora.tweens.tweeners.Tweener
---
local PropertyTweener = Tweener:extend("PropertyTweener", ...)

function PropertyTweener:constructor(parent, object, property, initialValue, finalValue, duration, ease)
    PropertyTweener.super.constructor(self, parent)

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
    self.initialValue = initialValue

    ---
    --- @type number|table
    ---
    self.finalValue = finalValue

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
    self.startDelay = 0.0

    ---
    --- @type number
    ---
    self.progress = nil

    ---
    --- @protected
    --- @type number
    ---
    self._elapsedTime = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._duration = duration
end

function PropertyTweener:set_ease(ease)
    self.ease = ease
    return self
end

function PropertyTweener:set_delay(secs)
    self.startDelay = secs
    return self
end

function PropertyTweener:update(dt)
    if self._duration <= 0.0 then
        return
    end
    self._elapsedTime = self._elapsedTime + dt
    if self._elapsedTime >= self.startDelay then
        local e = self.ease and self.ease or (self.parent.ease and self.parent.ease or Ease.linear)
        if type(self.finalValue) == "table" then
            local prop = self.object[self.property]
            for key, value in pairs(self.finalValue) do
                if type(value) == "number" then
                    prop[key] = math.lerp(self.initialValue[key], value, e(self.progress))
                end
            end
        else
            self.object[self.property] = math.lerp(self.initialValue, self.finalValue, e(self.progress))
        end
        if self.progress >= 1.0 then
            self._duration = 0.0
            self._elapsedTime = 0.0

            if self.onComplete then
                self.onComplete(self)
            end
        end
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function PropertyTweener:get_duration()
    return self._duration + self.startDelay
end

---
--- @protected
---
function PropertyTweener:get_progress()
    if self._elapsedTime <= self.startDelay then
        return 0.0
    end
    return (self._elapsedTime - self.startDelay) / self._duration
end

---
--- @protected
---
function PropertyTweener:set_duration(val)
    self._duration = val
    return self._duration
end

return PropertyTweener