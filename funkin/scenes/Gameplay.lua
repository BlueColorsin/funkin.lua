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

local StrumLine = require("funkin.gameplay.StrumLine") --- @type funkin.gameplay.StrumLine
local SongMetadata = require("funkin.backend.song.SongMetadata") --- @type funkin.backend.song.SongMetadata

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
    self.currentChart = Json.parse(File.read(Paths.chart(self._params.song, self._params.difficulty))) --- @type funkin.backend.song.chart.ChartData
    self.currentChart.meta = SongMetadata.get(self._params.song)

    BGM.audioPlayer:setVolume(1.0)
    BGM.load(Paths.inst(self._params.song))

    self.mainConductor = Conductor.instance
    self.mainConductor.hasMetronome = true
    self.mainConductor:setupFromChart(self.currentChart)
    self.mainConductor:setTime(self.mainConductor:getCrotchet() * -5.0)

    self.startingSong = true

    self.opponentStrumLine = StrumLine:new(Engine.gameWidth * 0.25, 50, false, "default") --- @type funkin.gameplay.StrumLine
    self:add(self.opponentStrumLine)
    
    self.playerStrumLine = StrumLine:new(Engine.gameWidth * 0.75, 50, false, "default") --- @type funkin.gameplay.StrumLine
    self:add(self.playerStrumLine)
end

function Gameplay:update(dt)
    Gameplay.super.update(self, dt)

    local mainConductor = self.mainConductor
    if self.startingSong then
        mainConductor:setTime(mainConductor:getRawTime() + (dt * 1000.0))
        if mainConductor:getRawTime() >= 0 then
            mainConductor.rawTime = 0.0
            self:startSong()
        end
    end
end

function Gameplay:startSong()
    self.startingSong = false
    BGM.play(nil, false)
end

return Gameplay