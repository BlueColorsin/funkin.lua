---
--- @class funkin.ui.transition.InstantTransition : funkin.ui.transition.BaseTransition
---
local InstantTransition = BaseTransition:extend("InstantTransition", ...)

function InstantTransition:startIn()
    local canContinue = InstantTransition.super.startIn(self)
    if canContinue then
        self:finish()
        return true
    end
    return false
end

function InstantTransition:startOut()
    local canContinue = InstantTransition.super.startOut(self)
    if canContinue then
        self:finish()
        return true
    end
    return false
end

return InstantTransition