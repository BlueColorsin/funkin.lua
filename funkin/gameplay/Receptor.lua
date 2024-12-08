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

local dirs = {"left", "down", "up", "right"}
local NoteSkin = require("funkin.backend.data.NoteSkin") --- @type funkin.backend.data.NoteSkin

---
--- @class funkin.gameplay.Receptor : chip.graphics.Sprite
---
local Receptor = Sprite:extend("Receptor", ...)

function Receptor:constructor(x, y, lane, skin)
    Receptor.super.constructor(self, x, y)

    ---
    --- @protected
    ---
    self._skin = nil --- @type string

    ---
    --- @protected
    ---
    self._lane = lane --- @type integer

    self:setSkin(skin)
end

function Receptor:getLaneID()
    return self._lane
end

function Receptor:setLaneID(id)
    self._lane = id % 4
    self.animation:play(dirs[self._lane + 1] .. " static")
end

function Receptor:getSkin()
    return self._skin
end

---
--- @param  skin  string
--- @param  json  funkin.backend.data.NoteSkin
---
function Receptor:setSkin(skin)
    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?

    if json.receptors.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.receptors.texture, "images/" .. json.receptors.folder))
        for i = 1, #json.receptors.animations do
            local animData = json.receptors.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = dirs[j] .. " " .. animData.name --- @type string
                if animData.indices and #animData.indices > 0 then
                    self.animation:addByIndices(animName, animData.prefixes[j], animData.indices[j], animData.fps, animData.looped)
                else
                    self.animation:addByPrefix(animName, animData.prefixes[j], animData.fps, animData.looped)
                end
            end
        end
    elseif json.receptors.atlasType == "grid" then
        -- TODO
    elseif json.receptors.atlasType == "animate" then
        -- TODO
    end
    self.scale:set(json.receptors.scale, json.receptors.scale)
    self.animation:play(dirs[self._lane + 1] .. " static")

    self._skin = skin
end

return Receptor