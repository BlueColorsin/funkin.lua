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
--- @class funkin.scenes.Gameplay : chip.core.Scene
---
local Gameplay = Scene:extend("Gameplay", ...)

function Gameplay:constructor(params)
    Gameplay.super.constructor(self)

    ---
    --- @protected
    --- @type funkin.backend.data.GameplayParams
    ---
    self._params = params or {
        song = "test",
        difficulty = "normal"
    }
end

function Gameplay:init()
    if BGM.isPlaying() then
        BGM.stop()
    end
end

return Gameplay