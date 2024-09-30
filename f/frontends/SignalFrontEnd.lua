---
--- Accessed via `flora.plugins`.
---
--- @class flora.frontends.SignalFrontEnd : flora.base.Basic
---
local SignalFrontEnd = Basic:extend("SignalFrontEnd", ...)

function SignalFrontEnd:constructor()
    SignalFrontEnd.super.constructor(self)

    ---
    --- @type flora.utils.Signal
    ---
    self.preUpdate = Signal:new()

    ---
    --- @type flora.utils.Signal
    ---
    self.postUpdate = Signal:new()

    ---
    --- @type flora.utils.Signal
    ---
    self.preDraw = Signal:new()

    ---
    --- @type flora.utils.Signal
    ---
    self.postDraw = Signal:new()

    ---
    --- @type flora.utils.Signal
    ---
    self.preStateSwitch = Signal:new()

    ---
    --- @type flora.utils.Signal
    ---
    self.preStateCreate = Signal:new():type(State)

    ---
    --- @type flora.utils.Signal
    ---
    self.postStateSwitch = Signal:new()
end

return SignalFrontEnd