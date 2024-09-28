---
--- A class that tweens can attach to, which manages
--- updating them.
---
--- @class flora.plugins.tween_manager : flora.base.basic
---
local tween_manager = basic:extend("tween_manager", ...)

---
--- @type flora.plugins.tween_manager?
---
tween_manager.global = nil

function tween_manager:constructor()
    tween_manager.super.constructor(self)

    ---
    --- The list of all tweens attached to this manager.
    --- 
    --- @type flora.display.group
    ---
    self.list = group:new()

    flora.signals.pre_state_create:connect(function()
        self:reset()
    end)
end

function tween_manager:reset()
    for i = 1, self.list.length do
        ---
        --- @type flora.tweens.tween
        ---
        local tween = self.list.members[i]
        tween:dispose()
    end
end

function tween_manager:update(dt)
    self.list:update(dt)
end

return tween_manager