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

local NoteSkin = require("funkin.backend.data.NoteSkin") --- @type funkin.backend.data.NoteSkin
local Receptor = require("funkin.gameplay.Receptor") --- @type funkin.gameplay.Receptor

---
--- @class funkin.gameplay.StrumLine : chip.graphics.CanvasLayer
---
local StrumLine = CanvasLayer:extend("StrumLine", ...)

function StrumLine:constructor(x, y, downscroll, skin)
    StrumLine.super.constructor(self, x, y, downscroll, skin)

    self._downscroll = downscroll

    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?
    for i = 1, 4 do
        local receptor = Receptor:new((i - 3) * 112, 0, i, "default") --- @type funkin.gameplay.Receptor
        self:add(receptor)
    end
end

function StrumLine:isDownscroll()
    return self._downscroll
end

function StrumLine:setDownscroll(downscroll)
    self._downscroll = downscroll
end

return StrumLine