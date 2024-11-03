---
--- A class that timers can attach to, which manages
--- updating them.
---
--- @class flora.plugins.TimerManager : flora.Basic
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

    Flora.signals.preStateCreate:connect(function()
        self:reset()
    end)
end

function TimerManager:reset()
    while self.list.length > 0 do
        ---
        --- @type flora.utils.Timer
        ---
        local timer = self.list.members[1]
        timer:dispose()
    end
end

function TimerManager:update(dt)
    self.list:update(dt)
end

return TimerManager