---
--- A class that timers can attach to, which manages
--- updating them.
---
--- @class flora.plugins.TimerManager : flora.base.Basic
---
local TimerManager = Basic:extend("TimerManager", ...)

---
--- @type flora.plugins.TimerManager?
---
TimerManager.global = nil

function TimerManager:constructor()
    TimerManager.super.constructor(self)

    ---
    --- The list of all timers attached to this manager.
    --- 
    --- @type flora.display.Group
    ---
    self.list = Group:new()

    flora.signals.preStateCreate:connect(function()
        self:reset()
    end)
end

function TimerManager:reset()
    for i = 1, self.list.length do
        ---
        --- @type flora.utils.timer
        ---
        local timer = self.list.members[i]
        timer:dispose()
    end
end

function TimerManager:update(dt)
    self.list:update(dt)
end

return TimerManager