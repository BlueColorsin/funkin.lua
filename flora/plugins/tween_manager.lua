---
--- A class that tweens can attach to, which manages
--- updating them.
---
--- @class flora.plugins.tween_manager : flora.base.basic
---
local tween_manager = basic:extend()

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
end

function tween_manager:update(dt)
    self.list:update(dt)
end

return tween_manager