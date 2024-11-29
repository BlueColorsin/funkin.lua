local AtlasFrames = qrequire("chip.animation.frames.AtlasFrames") --- @type chip.animation.frames.AtlasFrames

---
--- @class funkin.states.TitleState : chip.core.Scene
---
local TitleState = Scene:extend("TitleState", ...)

function TitleState:init()
    self.spinnies = Group:new() --- @type chip.core.Group
    self:add(self.spinnies)

    local leFrames = AtlasFrames.fromSparrow("assets/images/menus/main/buttons.png", "assets/images/menus/main/buttons.xml")
    for i = 1, 100 do
        local spinny = Sprite:new(0 + (i * 30), 0) --- @type chip.graphics.Sprite
        spinny:setFrames(leFrames)
        spinny.animation:addByPrefix("idle", "options selected", 24)
        spinny.animation:play("idle")
        self.spinnies:add(spinny)
    end

    self.crying = Text:new(30, 30, 0, "i'm going to shit everywhere") --- @type chip.graphics.Text
    self.crying:setSize(16)
    self.crying:setFont("assets/fonts/vcr.ttf")
    self.crying:setBorderSize(1)
    self.crying:setBorderColor(Color.BLUE)
    self:add(self.crying)

    -- self.leCam = Camera:new() --- @type chip.graphics.Camera
    -- Camera.currentCamera = self.leCam
end

function TitleState:update(delta)
    local spinnyMembers = self.spinnies:getMembers()
    for i = 1, self.spinnies:getLength() do
        local spinny = spinnyMembers[i] --- @type chip.graphics.Sprite
        spinny:setRotationDegrees(spinny:getRotationDegrees() + (delta * 100))
    end
    TitleState.super.update(self, delta)
end

return TitleState