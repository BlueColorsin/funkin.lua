local tween_manager = require("flora.plugins.tween_manager")
local property_tweener = require("flora.tweens.tweeners.property_tweener")

---
--- A basic tween class.
---
--- @class flora.tweens.tween : flora.base.basic
---
local tween = basic:extend()

---
--- @param  manager  flora.plugins.tween_manager?  The manager that this tween belongs to. (default: `tween_manager.global`)
---
function tween:constructor(manager)
    tween.super.constructor(self)

    self.visible = false

    ---
    --- The manager that this tween belongs to.
    ---
    --- @type flora.plugins.tween_manager?
    ---
    self.manager = manager and manager or tween_manager.global

    ---
    --- The default easing used for tweeners
    --- belonging to this tween.
    ---
    --- @type function
    ---
    self.ease = ease.linear

    ---
    --- The total duration of this tween. (in seconds)
    --- 
    --- @type number
    ---
    self.duration = nil

    ---
    --- The start delay of this tween. (in seconds)
    ---
    --- @type number
    ---
    self.start_delay = 0.0

    ---
    --- The function to call when this tween completes.
    --- 
    --- @type function?
    ---
    self.on_complete = nil

    ---
    --- The progress percentage of this tween. Ranges from 0 to 1.
    --- 
    --- @type number
    ---
    self.progress = nil

    ---
    --- @protected
    --- @type flora.display.group
    ---
    self._tweeners = group:new()

    ---
    --- @protected
    --- @type number
    ---
    self._elapsed_time = nil

    ---
    --- @protected
    --- @type number
    ---
    self._cached_duration = nil
end

---
--- Sets the default easing of this tween to
--- a given easing function.
---
--- @param  ease  function  The easing function to provide to this tween.
--- 
--- @return flora.tweens.tween
---
function tween:set_ease(ease)
    self.ease = ease
    return self
end

---
--- Tweens a specific property from a given object to a
--- new value over a given duration of time.
--- 
--- You can use this function as many times as you want
--- on just one tween, thus avoiding tween spamming.
---
--- @param  obj          table         The object to tween a property on.
--- @param  property     string        The name of the property to tween.
--- @param  final_value  number|table  The value that the property should tween towards.
--- @param  duration     number        The duration of the property tween.
--- @param  ease         function?     The easing function to use on the property tween (default: `ease.linear`)
---
--- @return flora.tweens.tweeners.property_tweener
---
function tween:tween_property(obj, property, final_value, duration, ease)
    self._cached_duration = nil

    local tweener = property_tweener:new(self, obj, property, obj[property], final_value, duration, ease)
    self._tweeners:add(tweener)

    return tweener
end

function tween:delay(secs)
    self.start_delay = secs
end

---
--- Starts this tween.
--- 
--- @return flora.tweens.tween
---
function tween:start()
    self._elapsed_time = 0.0

    for i = 1, #self._tweeners do
        ---
        --- @type flora.tweens.tweeners.tweener
        ---
        local tweener = self._tweeners.members[i]

        if tweener._elapsed_time then
            tweener._elapsed_time = 0.0
        end
    end

    self.manager.list:add(self)
    return self
end

---
--- Stops this tween.
--- 
--- @return flora.tweens.tween
---
function tween:stop()
    self._elapsed_time = 0.0
    self._cached_duration = nil

    self.start_delay = 0.0
    self.manager.list:remove(self)

    return self
end

---
--- Updates this tween.
--- This function is automatically called by the tween manager.
---
function tween:update(dt)
    self._elapsed_time = self._elapsed_time + dt
    if self._elapsed_time >= self.start_delay then
        self._tweeners:update(dt)

        if self.progress >= 1.0 then
            if self.on_complete then
                self.on_complete(self)
            end
            self:dispose()
        end
    end
end

function tween:dispose()
    tween.super.dispose(self)
    self:stop()

    if flora.config.debug_mode then
        flora.log:verbose("Disposing tweener " .. tostring(self._tweeners))
    end
    self._tweeners:dispose()
    self._tweeners = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function tween:__get(var)
    if var == "duration" then
        if self._cached_duration then
            return self._cached_duration + self.start_delay
        end
        local total = 0.0
        for i = 1, self._tweeners.length do
            ---
            --- @type flora.tweens.tweeners.tweener
            ---
            local tweener = self._tweeners.members[i]
            if tweener.duration > total then
                total = tweener.duration
            end
        end
        self._cached_duration = total
        return total + self.start_delay

    elseif var == "progress" then
        if self._elapsed_time <= self.start_delay then
            return 0.0
        end
        return (self._elapsed_time - self.start_delay) / (self.duration - self.start_delay)
    end
    return tween.super.__get(self, var)
end

return tween