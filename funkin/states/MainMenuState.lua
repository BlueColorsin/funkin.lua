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
--- @class funkin.states.MainMenuState : chip.core.Scene
---
local MainMenuState = Scene:extend("MainMenuState", ...)
MainMenuState.lastSelected = 1

function MainMenuState:init()
    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:loadTexture(Paths.image("yellow", "images/menus"))
    self.bg.scale:set(1.17, 1.17)
    self.bg:screenCenter("xy")
    self.bg.scrollFactor:set(0, 0.17)
    self:add(self.bg)

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

    self.itemList = MainMenuList:new() --- @type funkin.ui.mainmenu.MainMenuList
    self.itemList:addItem("storymode", "Story Mode", function(_)
        print("i desire penis")
    end)
    self.itemList:addItem("freeplay", "Freeplay", function(_)
        print("i desire penis")
    end)
    self.itemList:addItem("options", "Options", function(_)
        print("i desire penis")
    end)
    self.itemList:addItem("credits", "Credits", function(_)
        print("i desire penis")
    end)
    self.itemList:centerItems()
    self.itemList:selectItem(MainMenuState.lastSelected)
    self.uiLayer:add(self.itemList)
end

function MainMenuState:free()
    MainMenuState.lastSelected = self.itemList.selectedItem
    MainMenuState.super.free(self)
end

return MainMenuState