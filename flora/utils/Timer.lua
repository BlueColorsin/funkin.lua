local TimerManager = require("flora.plugins.TimerManager")

---
--- A basic timer class.
---
--- @class flora.utils.Timer : flora.base.Basic
---
local Timer = Basic:extend("Timer", ...)

---
--- @param  manager  flora.plugins.TimerManager?  The manager that this timer belongs to. (default: `TimerManager.global`)
---
function Timer:constructor(manager)
    Timer.super.constructor(self)

    self.visible = false

    ---
    --- The manager that this timer belongs to.
    ---
    --- @type flora.plugins.TimerManager?
    ---
    self.manager = manager and manager or TimerManager.global

    ---
    --- The amount of time that has elapsed since this timer started. (in seconds)
    ---
    self.elapsedTime = 0.0

    ---
    --- The duration of this timer. (in seconds)
    ---
    self.duration = 0.0

    ---
    --- The function that gets called when this
    --- timer completes.
    ---
    --- @type function?
    ---
    self.onComplete = nil

    ---
    --- The amount of times that this timer will loop.
    ---
    self.loops = 1

    ---
    --- The amount of loops left on this timer.
    ---
    self.loopsLeft = 1
end

---
--- Starts this timer with the given duration and completion callback.
---
--- @param  duration     number     The duration of the timer in seconds.
--- @param  onComplete  function?  A function that gets called when the timer completes, once for each loop.
--- @param  loops        integer?   An optional number of times to loop the timer.
--- 
--- @return flora.utils.Timer
---
function Timer:start(duration, onComplete, loops)
    self.duration = duration
    self.onComplete = onComplete

    self.loops = loops and loops or 1
    self.loopsLeft = self.loops

    self.manager.list:add(self)
    return self
end

---
--- Updates this timer.
--- This function is automatically called by the timer manager.
---
function Timer:update(dt)
    self.elapsedTime = self.elapsedTime + dt

    if self.elapsedTime >= self.duration then
        self.elapsedTime = 0.0

        if self.loops > 0 then
            self.loopsLeft = self.loopsLeft - 1
            
            if self.onComplete then
                self.onComplete(self)
            end

            if self.loopsLeft <= 0 then
                self:stop()
            end
        else
            if self.onComplete then
                self.onComplete(self)
            end
        end
    end
end

---
--- Stops this timer and resets its properties
--- 
--- @return flora.utils.Timer
---
function Timer:stop()
    self.elapsedTime = 0.0
    self.duration = 0.0

    self.loops = 1
    self.loopsLeft = 1

    self.onComplete = nil
    self.manager.list:remove(self)

    return self
end

---
--- Resets this timer with the given duration.
--- The timer will not be removed from the manager.
---
--- @param  duration  number  The new duration of the timer in seconds.
--- 
--- @return flora.utils.Timer
---
function Timer:reset(duration)
    self.duration = duration
    self.elapsedTime = 0.0
    self.loopsLeft = self.loops
    return self
end

function Timer:dispose()
    Timer.super.dispose(self)
    self:stop()
end

return Timer