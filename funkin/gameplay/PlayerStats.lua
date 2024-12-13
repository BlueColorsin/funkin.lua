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
--- @class funkin.gameplay.PlayerStats
---
local PlayerStats = Class:extend("PlayerStats", ...)

function PlayerStats:constructor()
    self.score = 0 --- @type integer

    self.misses = 0 --- @type integer
    self.comboBreaks = 0 --- @type integer

    self.combo = 0 --- @type integer
    self.missCombo = 0 --- @type integer

    self.judgementHits = {} --- @type table<string, integer>

    self.totalNotesHit = 0 --- @type integer
    self.accuracyScore = 0.0 --- @type number
end

function PlayerStats:reset()
    self.score = 0

    self.misses = 0
    self.comboBreaks = 0

    self.combo = 0
    self.missCombo = 0

    self.judgementHits = {}

    self.totalNotesHit = 0
    self.accuracyScore = 0.0
end

function PlayerStats:increaseScore(by)
    self.score = self.score + by
end

function PlayerStats:increaseMisses()
    self.misses = self.misses + 1
end

function PlayerStats:increaseComboBreaks()
    self.comboBreaks = self.comboBreaks + 1
end

function PlayerStats:increaseCombo()
    self.combo = self.combo + 1
end

function PlayerStats:increaseMissCombo()
    self.missCombo = self.missCombo + 1
end

function PlayerStats:resetCombo()
    self.combo = 0
end

function PlayerStats:resetMissCombo()
    self.missCombo = 0
end

return PlayerStats