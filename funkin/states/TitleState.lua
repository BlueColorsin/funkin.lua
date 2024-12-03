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
    if not BGM.isPlaying() then
        -- TODO: make some kind of util function for this
        CoolUtil.playMusic("girlfriendsRingtone", 0)
        Conductor.instance.hasMetronome = true
        BGM.fade(0, 1, 4)
    end

    self.titleGroup = Group:new() --- @type chip.core.Group
    self.titleGroup:kill()
    self:add(self.titleGroup)

    self.logo = Sprite:new(-150, -100) --- @type chip.graphics.Sprite
    self.logo:setFrames(Paths.getSparrowAtlas("logo", "images/menus/title"))
    self.logo.animation:addByPrefix("idle", "logo bumpin", 24, false)
    self.logo.animation:play("idle")
    self.titleGroup:add(self.logo)

    self.gfDance = Sprite:new(Engine.gameWidth * 0.4, Engine.gameHeight * 0.07) --- @type chip.graphics.Sprite
    self.gfDance:setFrames(Paths.getSparrowAtlas("gf", "images/menus/title"))
    self.gfDance.animation:addByPrefix("idle", "gfDance", 24, false)
    self.gfDance.animation:play("idle")
    self.titleGroup:add(self.gfDance)

    self.titleText = Sprite:new(100, Engine.gameHeight * 0.8) --- @type chip.graphics.Sprite
    self.titleText:setFrames(Paths.getSparrowAtlas("enter", "images/menus/title"))
    self.titleText.animation:addByPrefix("idle", "Press Enter to Begin", 24)
    self.titleText.animation:addByPrefix("press", "ENTER PRESSED", 24, false)
    self.titleText.animation:play("idle")
    self.titleGroup:add(self.titleText)

    self.introText = AtlasText:new(0, 200, "bold", "center", "negative money\nim in credit card debt") --- @type funkin.ui.AtlasText
    self.introText:screenCenter("x")
    self:add(self.introText)
end

return TitleState