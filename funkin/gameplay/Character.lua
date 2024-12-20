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

local CharacterData = require("funkin.backend.data.CharacterData") --- @type funkin.backend.data.CharacterData

---
--- @class funkin.gameplay.Character : chip.graphics.Sprite
---
local Character = Sprite:extend("Character", ...)

function Character:constructor(x, y, characterID)
    Character.super.constructor(self, x, y)

    self._characterID = characterID

    local json = CharacterData.get(characterID) --- @type funkin.backend.data.CharacterData?
    if not json then
        characterID = "bf"
        self._characterID = characterID
        
        json = CharacterData.get("bf")
    end

    ---
    --- @protected
    ---
    self._config = json --- @type funkin.backend.data.CharacterData?

    ---
    --- @protected
    ---
    self._curDanceStep = 1

    if json.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.atlasPath, "images/game/characters"))
        for i = 1, #json.animations do
            local animData = json.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            if animData.indices and #animData.indices > 0 then
                self.animation:addByIndices(animData.name, animData.prefix, animData.indices, animData.fps, animData.looped)
            else
                self.animation:addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped)
            end
        end
    elseif json.atlasType == "grid" then
        self:loadTexture(Paths.image(json.atlasPath, "images/game/characters"), true, json.gridSize.x, json.gridSize.y)
        for i = 1, #json.animations do
            local animData = json.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            self.animation:add(animData.name, animData.indices, animData.fps, animData.looped)
        end
    
    elseif json.atlasType == "animate" then
        -- TODO
    end
    self:dance(true)
    self.offset:set(self:getWidth() * 0.5, self:getHeight() * 0.5)
end

function Character:getConfig()
    return self._config
end

function Character:dance(force)
    local danceSteps = self._config.danceSteps
    self.animation:play(danceSteps[self._curDanceStep], force)
    self._curDanceStep = math.wrap(self._curDanceStep + 1, 1, #danceSteps)
end

return Character