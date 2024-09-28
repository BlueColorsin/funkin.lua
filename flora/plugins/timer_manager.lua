---
--- A class that timers can attach to, which manages
--- updating them.
---
--- @class flora.plugins.timer_manager : flora.base.basic
---
local timer_manager = basic:extend("timer_manager", ...)

---
--- @type flora.plugins.timer_manager?
---
timer_manager.global = nil

function timer_manager:constructor()
    timer_manager.super.constructor(self)

    ---
    --- The list of all timers attached to this manager.
    --- 
    --- @type flora.display.group
    ---
    self.list = group:new()

    flora.signals.pre_state_create:connect(function()
        self:reset()
    end)
end

function timer_manager:reset()
    for i = 1, self.list.length do
        ---
        --- @type flora.utils.timer
        ---
        local timer = self.list.members[i]
        timer:dispose()
    end
end

function timer_manager:update(dt)
    self.list:update(dt)
end

return timer_manager