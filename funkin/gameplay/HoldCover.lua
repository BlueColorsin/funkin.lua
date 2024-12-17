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
--- @class funkin.gameplay.HoldCover : chip.graphics.Sprite
---
local HoldCover = Sprite:extend("HoldCover", ...)

function HoldCover:constructor(x, y, lane, skin)
    HoldCover.super.constructor(self, x, y)

    ---
    --- @protected
    ---
    self._skin = nil --- @type string

    ---
    --- @protected
    ---
    self._lane = lane --- @type integer

    ---
    --- @protected
    ---
    self._strumLine = nil --- @type funkin.gameplay.StrumLine

    self.animation:setCompletionCallback(function(name)
        if name:endsWith("start") then
            self.animation:play(dirs[self._lane + 1] .. " hold")
        
        elseif name:endsWith("end") then
            self:kill()
        end
    end)
    self:setSkin(skin)
end

function HoldCover:getLaneID()
    return self._lane
end

function HoldCover:setLaneID(id)
    self._lane = id % 4
    self.animation:play(dirs[self._lane + 1] .. " start", true)
end

function HoldCover:getSkin()
    return self._skin
end

---
--- @param  skin  string
---
function HoldCover:setSkin(skin)
    if self._skin == skin then
        return
    end
    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?

    if json.holdCovers.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.holdCovers.texture, "images/" .. json.holdCovers.folder))
        for i = 1, #json.holdCovers.animations do
            local animData = json.holdCovers.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = dirs[j] .. " " .. animData.name --- @type string
                if animData.indices and #animData.indices > 0 then
                    self.animation:addByIndices(animName, animData.prefixes[j], animData.indices[j], animData.fps, animData.looped)
                else
                    self.animation:addByPrefix(animName, animData.prefixes[j], animData.fps, animData.looped)
                end
                if animData.offsets then
                    self.animation:setOffset(animName, animData.offsets[j].x, animData.offsets[j].y)
                end
            end
        end
    elseif json.holdCovers.atlasType == "grid" then
        -- TODO
    elseif json.holdCovers.atlasType == "animate" then
        -- TODO
    end
    self.scale:set(json.holdCovers.scale, json.holdCovers.scale)
    self:setLaneID(self:getLaneID())

    self:setAlpha(json.holdCovers.alpha or 1.0)

    self.offset:set(json.holdCovers.offset.x, json.holdCovers.offset.y)
    self._skin = skin
end

function HoldCover:getStrumLine()
    return self._strumLine
end

function HoldCover:setStrumLine(strumLine)
    self._strumLine = strumLine
end

---
--- @param  strumLine  funkin.gameplay.StrumLine  The strumline that the note splash belongs to.
--- @param  lane       integer                    The lane that the splash belongs to. (from 0 to 4)
--- @param  skin       string                     The skin of the note splash.
---
function HoldCover:setup(strumLine, lane, skin)
    self:setSkin(skin)
    self:setLaneID(lane)

    self:revive()
    self:setStrumLine(strumLine)

    local r = strumLine.receptors:getMembers()[lane + 1] --- @type funkin.gameplay.Receptor
    self:setPosition(
        r:getX() - (self:getWidth() * 0.5),
        r:getY() - (self:getHeight() * 0.5)
    )
end

function HoldCover:splurge()
    self:revive()
    self.animation:play(dirs[self._lane + 1] .. " end", true)
end

return HoldCover