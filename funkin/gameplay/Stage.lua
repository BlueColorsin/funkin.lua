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

local StageData = require("funkin.backend.data.StageData") --- @type funkin.backend.data.StageData

---
--- @class funkin.gameplay.Stage : chip.graphics.CanvasLayer
---
local Stage = CanvasLayer:extend("Stage", ...)

function Stage:constructor(stageID)
    Stage.super.constructor(self)

    ---
    --- @protected
    ---
    self._stageID = stageID --- @type string

    local json = StageData.get(self._stageID) --- @type funkin.backend.data.StageData
end

function Stage:getStageID()
    return self._stageID
end

return Stage