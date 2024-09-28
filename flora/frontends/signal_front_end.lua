---
--- Accessed via `flora.plugins`.
---
--- @class flora.frontends.signal_front_end : flora.base.basic
---
local signal_front_end = basic:extend("signal_front_end", ...)

function signal_front_end:constructor()
    signal_front_end.super.constructor(self)

    ---
    --- @type flora.utils.signal
    ---
    self.pre_update = signal:new()

    ---
    --- @type flora.utils.signal
    ---
    self.post_update = signal:new()

    ---
    --- @type flora.utils.signal
    ---
    self.pre_draw = signal:new()

    ---
    --- @type flora.utils.signal
    ---
    self.post_draw = signal:new()

    ---
    --- @type flora.utils.signal
    ---
    self.pre_state_switch = signal:new()

    ---
    --- @type flora.utils.signal
    ---
    self.pre_state_create = signal:new():type(state)

    ---
    --- @type flora.utils.signal
    ---
    self.post_state_switch = signal:new()
end

return signal_front_end