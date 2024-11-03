---
--- @class funkin.backend.InitState : chip.core.Scene
---
local InitState = Scene:extend("InitState", ...)

function InitState:init()
    self.spinnies = Group:new() --- @type chip.core.Group
    self:add(self.spinnies)

    for i = 1, 10 do
        local spinny = Sprite:new():setPosition(0 + (i * 10), 0) --- @type chip.graphics.Sprite
        spinny.texture = Assets.getTexture("assets/images/spinner.png")
        spinny.rotation = 45
        self.spinnies:add(spinny)
    end
end

function InitState:update(delta)
    for i = 1, self.spinnies.length do
        local spinny = self.spinnies.members[i] --- @type chip.graphics.Sprite
        spinny.rotationDegrees = spinny.rotationDegrees + (delta * 100)
    end
    InitState.super.update(self, delta)
end

return InitState