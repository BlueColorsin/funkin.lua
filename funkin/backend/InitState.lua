local AtlasFrames = qrequire("chip.animation.frames.AtlasFrames") --- @type chip.animation.frames.AtlasFrames

---
--- @class funkin.backend.InitState : chip.core.Scene
---
local InitState = Scene:extend("InitState", ...)

function InitState:init()
    self.spinnies = Group:new() --- @type chip.core.Group
    self:add(self.spinnies)

    for i = 1, 100 do
        local spinny = Sprite:new(0 + (i * 30), 0) --- @type chip.graphics.Sprite
        spinny:setFrames(AtlasFrames.fromSparrow("assets/images/menus/main/options.png", "assets/images/menus/main/options.xml"))
        spinny.animation:addByPrefix("idle", "options selected", 24)
        spinny.animation:play("idle")
        self.spinnies:add(spinny)
    end

    self.leCam = Camera:new() --- @type chip.graphics.Camera
    Camera.currentCamera = self.leCam
end

function InitState:update(delta)
    for i = 1, self.spinnies:getLength() do
        local spinny = self.spinnies:getMembers()[i] --- @type chip.graphics.Sprite
        spinny:setRotationDegrees(spinny:getRotationDegrees() + (delta * 100))
    end
    InitState.super.update(self, delta)
end

return InitState