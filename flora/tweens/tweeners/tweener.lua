---
--- A basic tween class.
---
--- @class flora.tweens.tweeners.tweener : flora.base.basic
---
local tweener = basic:extend()

function tweener:constructor(parent)
    tweener.super.constructor(self)

    self.visible = false

    ---
    --- @type flora.tweens.tween
    ---
    self.parent = parent

    ---
    --- @type function?
    ---
    self.on_complete = nil
end

return tweener