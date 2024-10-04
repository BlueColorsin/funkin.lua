---
--- A class that tweens can attach to, which manages
--- updating them.
---
--- @class flora.plugins.TweenManager : flora.base.Basic
---
local TweenManager = Basic:extend("TweenManager", ...)

---
--- @type flora.plugins.TweenManager?
---
TweenManager.global = nil

function TweenManager:constructor()
    TweenManager.super.constructor(self)

    ---
    --- The list of all tweens attached to this manager.
    --- 
    --- @type flora.display.Group
    ---
    self.list = Group:new()

    Flora.signals.preStateCreate:connect(function()
        self:reset()
    end)
end

function TweenManager:reset()
    while self.list.length > 0 do
        ---
        --- @type flora.tweens.Tween
        ---
        local tween = self.list.members[1]
        tween:dispose()
    end
end

function TweenManager:update(dt)
    self.list:update(dt)
end

return TweenManager