--[[
    Copyright 2024 swordcube

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

---
--- @class funkin.states.TitleState : chip.core.Scene
---
local TitleState = Scene:extend("TitleState", ...)

function TitleState:init()
    self.spinnies = Group:new() --- @type chip.core.Group
    self:add(self.spinnies)
    
    for i = 1, 100 do
        local spinny = Sprite:new(0 + (i * 30), 0) --- @type chip.graphics.Sprite
        spinny:setFrames(Paths.getSparrowAtlas("buttons", "images/menus/main"))
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