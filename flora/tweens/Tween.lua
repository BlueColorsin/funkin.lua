local TweenManager = require("flora.plugins.TweenManager")
local PropertyTweener = require("flora.tweens.tweeners.PropertyTweener")

---
--- A basic tween class.
---
--- @class flora.tweens.Tween : flora.base.Basic
---
local Tween = Basic:extend("Tween", ...)

---
--- @param  manager  flora.plugins.TweenManager?  The manager that this tween belongs to. (default: `TweenManager.global`)
---
function Tween:constructor(manager)
    Tween.super.constructor(self)

    self.visible = false

    ---
    --- Controls whether or not this tween is paused.
    --- 
    --- @type boolean
    ---
    self.paused = false

    ---
    --- The manager that this tween belongs to.
    ---
    --- @type flora.plugins.TweenManager?
    ---
    self.manager = manager and manager or TweenManager.global

    ---
    --- The default easing used for tweeners
    --- belonging to this Tween.
    ---
    --- @type function
    ---
    self.ease = Ease.linear

    ---
    --- The total duration of this Tween. (in seconds)
    --- 
    --- @type number
    ---
    self.duration = nil

    ---
    --- The start delay of this Tween. (in seconds)
    ---
    --- @type number
    ---
    self.startDelay = 0.0

    ---
    --- The function to call when this tween completes.
    --- 
    --- @type function?
    ---
    self.onComplete = nil

    ---
    --- The progress percentage of this Tween. Ranges from 0 to 1.
    --- 
    --- @type number
    ---
    self.progress = nil

    ---
    --- @protected
    --- @type flora.display.Group
    ---
    self._tweeners = Group:new()

    ---
    --- @protected
    --- @type number
    ---
    self._elapsedTime = nil

    ---
    --- @protected
    --- @type number
    ---
    self._cachedDuration = nil
end

---
--- Sets the default easing of this tween to
--- a given easing function.
---
--- @param  ease  function  The easing function to provide to this Tween.
--- 
--- @return flora.tweens.Tween
---
function Tween:setEase(ease)
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
--- @param  property     string        The name of the property to Tween.
--- @param  final_value  number|table  The value that the property should tween towards.
--- @param  duration     number        The duration of the property Tween.
--- @param  ease         function?     The easing function to use on the property tween (default: `ease.linear`)
---
--- @return flora.tweens.tweeners.PropertyTweener
---
function Tween:tweenProperty(obj, property, final_value, duration, ease)
    self._cachedDuration = nil

    local initial_value = obj[property]
    if type(final_value) == "table" then
        initial_value = {}
        
        local prop = obj[property]
        for key, _ in pairs(final_value) do
            initial_value[key] = prop[key]
        end
    end
    local tweener = PropertyTweener:new(self, obj, property, initial_value, final_value, duration, ease and ease or self.ease)
    self._tweeners:add(tweener)

    return tweener
end

function Tween:setDelay(secs)
    self.startDelay = secs
    return self
end

---
--- Starts this Tween.
--- 
--- @return flora.tweens.Tween
---
function Tween:start()
    self._elapsedTime = 0.0

    for i = 1, #self._tweeners do
        local tweener = self._tweeners.members[i]
        if tweener._elapsedTime then
            tweener._elapsedTime = 0.0
        end
    end
    self.manager.list:add(self)
    return self
end

---
--- Stops this Tween.
--- 
--- @return flora.tweens.Tween
---
function Tween:stop()
    self._elapsedTime = 0.0
    self._cachedDuration = nil

    self.startDelay = 0.0
    self.manager.list:remove(self)

    return self
end

---
--- Updates this Tween.
--- This function is automatically called by the tween manager.
---
function Tween:update(dt)
    if self.paused then
        return
    end
    self._elapsedTime = self._elapsedTime + dt
    if self._elapsedTime >= self.startDelay then
        self._tweeners:update(dt)

        if self.progress >= 1.0 then
            if self.onComplete then
                self.onComplete(self)
            end
            self:dispose()
        end
    end
end

function Tween:cancel()
    self:stop()

    for i = 1, self._tweeners.length do
        local obj = self._tweeners.members[i]
        if obj then
            if Flora.config.debugMode then
                Flora.log:verbose("Disposing object " .. tostring(obj))
            end
            obj:dispose()
            self._tweeners:remove(obj)
        end
    end
end

function Tween:dispose()
    Tween.super.dispose(self)
    self:stop()

    if Flora.config.debugMode then
        Flora.log:verbose("Disposing tweener " .. tostring(self._tweeners))
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
function Tween:get_duration()
    if self._cachedDuration then
        return self._cachedDuration + self.startDelay
    end
    local total = 0.0
    for i = 1, self._tweeners.length do
        ---
        --- @type flora.tweens.tweeners.Tweener
        ---
        local tweener = self._tweeners.members[i]
        if tweener.duration > total then
            total = tweener.duration
        end
    end
    self._cachedDuration = total
    return total + self.startDelay
end

---
--- @protected
---
function Tween:get_progress()
    if self._elapsedTime <= self.startDelay then
        return 0.0
    end
    return (self._elapsedTime - self.startDelay) / (self.duration - self.startDelay)
end

return Tween