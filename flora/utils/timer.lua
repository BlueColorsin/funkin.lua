local timer_manager = require("flora.plugins.timer_manager")

---
--- A basic timer class.
---
--- @class flora.utils.timer : flora.base.basic
---
local timer = basic:extend()

---
--- @param  manager  flora.plugins.timer_manager?  The manager that this timer belongs to. (default: `timer_manager.global`)
---
function timer:constructor(manager)
    timer.super.constructor(self)

    self._type = "timer"

    self.visible = false

    ---
    --- The manager that this timer belongs to.
    ---
    --- @type flora.plugins.timer_manager?
    ---
    self.manager = manager and manager or timer_manager.global

    ---
    --- The amount of time that has elapsed since this timer started. (in seconds)
    ---
    self.elapsed_time = 0.0

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
    self.on_complete = nil

    ---
    --- The amount of times that this timer will loop.
    ---
    self.loops = 1

    ---
    --- The amount of loops left on this timer.
    ---
    self.loops_left = 1
end

---
--- Starts this timer with the given duration and completion callback.
---
--- @param  duration     number     The duration of the timer in seconds.
--- @param  on_complete  function?  A function that gets called when the timer completes, once for each loop.
--- @param  loops        integer?   An optional number of times to loop the timer.
--- 
--- @return flora.utils.timer
---
function timer:start(duration, on_complete, loops)
    self.duration = duration
    self.on_complete = on_complete

    self.loops = loops and loops or 1
    self.loops_left = self.loops

    self.manager.list:add(self)
    return self
end

---
--- Updates this timer.
--- This function is automatically called by the timer manager.
---
function timer:update(dt)
    self.elapsed_time = self.elapsed_time + dt

    if self.elapsed_time >= self.duration then
        self.elapsed_time = 0.0

        if self.loops > 0 then
            self.loops_left = self.loops_left - 1
            
            if self.on_complete then
                self.on_complete(self)
            end

            if self.loops_left <= 0 then
                self:stop()
            end
        else
            if self.on_complete then
                self.on_complete(self)
            end
        end
    end
end

---
--- Stops this timer and resets its properties
--- 
--- @return flora.utils.timer
---
function timer:stop()
    self.elapsed_time = 0.0
    self.duration = 0.0

    self.loops = 1
    self.loops_left = 1

    self.on_complete = nil
    self.manager.list:remove(self)

    return self
end

---
--- Resets this timer with the given duration.
--- The timer will not be removed from the manager.
---
--- @param  duration  number  The new duration of the timer in seconds.
--- 
--- @return flora.utils.timer
---
function timer:reset(duration)
    self.duration = duration
    self.elapsed_time = 0.0
    self.loops_left = self.loops
    return self
end

return timer