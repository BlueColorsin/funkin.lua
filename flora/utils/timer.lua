---
--- A basic timer class.
---
--- @class flora.utils.timer : flora.base.basic
---
local timer = basic:extend()

function timer:constructor()
    timer.super.constructor(self)

    ---
    --- The function that gets called when this
    --- timer completes.
    ---
    --- @type function
    ---
    self.on_complete = nil
end

function timer:start(duration, on_complete)
    self.on_complete = on_complete
    print("bro i'm not finished yet :[")
end

return timer