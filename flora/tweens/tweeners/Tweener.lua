---
--- A basic tween class.
---
--- @class flora.tweens.tweeners.Tweener : flora.Basic
---
local Tweener = Basic:extend("Tweener", ...)

function Tweener:constructor(parent)
    Tweener.super.constructor(self)

    self.visible = false

    ---
    --- @type flora.tweens.tween
    ---
    self.parent = parent

    ---
    --- @type function?
    ---
    self.onComplete = nil
end

return Tweener