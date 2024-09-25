---
--- A class that timers can attach to, which manages
--- updating them.
---
--- @class flora.plugins.timer_manager : flora.base.basic
---
local timer_manager = basic:extend()

function timer_manager:constructor()
    timer_manager.super.constructor(self)

    ---
    --- The list of all timers attached to this manager.
    --- 
    --- @type flora.display.group
    ---
    self.list = group:new()
end

function timer_manager:update(dt)
    self.list:update(dt)
end

return timer_manager