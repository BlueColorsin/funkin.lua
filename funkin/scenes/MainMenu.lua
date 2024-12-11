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

local MainMenuList = require("funkin.ui.mainmenu.MainMenuList") --- @type funkin.ui.mainmenu.MainMenuList
local MainMenuButton = require("funkin.ui.mainmenu.MainMenuButton") --- @type funkin.ui.mainmenu.MainMenuButton

---
--- @class funkin.scenes.MainMenu : chip.core.Scene
---
local MainMenu = Scene:extend("MainMenu", ...)
MainMenu.lastSelected = 1

function MainMenu:init()
    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:loadTexture(Paths.image("yellow", "images/menus"))
    self.bg.scale:set(1.17, 1.17)
    self.bg:screenCenter("xy")
    self.bg.scrollFactor:set(1, 0.17)
    self:add(self.bg)

    self.magenta = Sprite:new() --- @type chip.graphics.Sprite
    self.magenta:loadTexture(Paths.image("desat", "images/menus"))
    self.magenta.scale:set(1.17, 1.17)
    self.magenta:screenCenter("xy")
    self.magenta.scrollFactor:set(1, 0.17)
    self.magenta:setTint(0xFFFD719B)
    self.magenta:setVisibility(false)
    self:add(self.magenta)

    self.camera = Camera:new() --- @type chip.graphics.Camera
    self.camera:makeCurrent()
    self.camera:setSmoothing(3.6)
    self.camera:snapToTargetPos()
    self:add(self.camera)

    self.uiLayer = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.uiLayer)

    self.versionText = Text:new(2, Engine.gameHeight - 2) --- @type chip.graphics.Text
    self.versionText:setFont(Paths.font("vcr.ttf"))
    self.versionText:setBorderSize(1)
    self.versionText:setBorderColor(Color.BLACK)

    local text = "v" .. Constants.ENGINE_VERSION
    if Constants.COMMIT_HASH then
        text = text .. " - " .. Constants.COMMIT_HASH
    end
    self.versionText:setContents(text)
    self.versionText:setY(self.versionText:getY() - self.versionText:getHeight())
    self.uiLayer:add(self.versionText)

    self.menuItems = MainMenuList:new() --- @type funkin.ui.mainmenu.MainMenuList
    self.menuItems:addItem("storymode", "Story Mode", function(_)
        print("STORY MODE SELECTED, TODO!!!")
        self:startExitScene(require("funkin.scenes.StoryMenu"):new())
    end)
    self.menuItems:addItem("freeplay", "Freeplay", function(_)
        self:startExitScene(require("funkin.scenes.FreeplayMenu"):new())
    end)
    self.menuItems:addItem("options", "Options", function(_)
        print("STORY MODE SELECTED, TODO!!!")
        self:startExitScene(require("funkin.scenes.OptionsMenu"):new())
    end)
    self.menuItems:addItem("credits", "Credits", function(_)
        print("CREDITS SELECTED, TODO!!!")
        self:startExitScene(require("funkin.scenes.CreditsMenu"):new())
    end)
    self.menuItems.onChange:connect(function(item)
        self.camera:setY(item:getY())
    end)
    self.menuItems.onAcceptPress:connect(function(item)
        if Options.flashingLights then
            FlickerEffect.flicker(self.magenta, 1.1, 0.15, false, true)
        end
    end)
    self.menuItems:centerItems()
    self.menuItems:selectItem(MainMenu.lastSelected)
    self.uiLayer:add(self.menuItems)
end

function MainMenu:update(dt)
    if Controls.justPressed.BACK then
        AudioPlayer.playSFX(Paths.sound("cancel", "sounds/menus"))
        Engine.switchScene(require("funkin.scenes.TitleScreen"):new())
    end
    MainMenu.super.update(self, dt)
end

function MainMenu:startExitScene(scene)
    self.menuItems.enabled = false

    local duration = 0.4
    for i = 1, self.menuItems:getLength() do
        local item = self.menuItems:getMembers()[i] --- @type funkin.ui.mainmenu.MainMenuButton
        if i ~= self.menuItems.selectedItem then
            local t = Tween:new() --- @type chip.tweens.Tween
            t:tweenProperty(item, "alpha", 0, duration, Ease.quadOut)
        else
            item:setVisibility(false)
        end
    end
    local t = Timer:new() --- @type chip.utils.Timer
    t:start(duration + 0.05, function(_)
        Engine.switchScene(scene)
    end)
end

function MainMenu:free()
    MainMenu.lastSelected = self.menuItems.selectedItem
    MainMenu.super.free(self)
end

return MainMenu