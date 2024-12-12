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

local SongMetadata = require("funkin.backend.song.SongMetadata") --- @type funkin.backend.song.SongMetadata

local StrumLine = require("funkin.gameplay.StrumLine") --- @type funkin.gameplay.StrumLine
local Player = require("funkin.gameplay.Player") --- @type funkin.gameplay.Player
local NoteSpawner = require("funkin.gameplay.NoteSpawner") --- @type funkin.gameplay.NoteSpawner

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
        difficulty = "normal",
        gameMode = "freeplay"
    }
end

function Gameplay:init()
    -- stop any playing music
    if BGM.isPlaying() then
        BGM.stop()
    end
    -- load chart
    self.currentChart = Json.parse(File.read(Paths.chart(self._params.song, self._params.difficulty))) --- @type funkin.backend.song.chart.ChartData
    self.currentChart.meta = SongMetadata.get(self._params.song)

    -- load inst
    BGM.audioPlayer:setVolume(1.0)
    BGM.load(Paths.inst(self._params.song))

    -- setup conductor
    self.mainConductor = Conductor.instance
    self.mainConductor:setupFromChart(self.currentChart)
    self.mainConductor:setTime(self.mainConductor:getCrotchet() * -5.0)

    -- hook song ending signal shit
    BGM.audioPlayer.finished:connect(function()
        self:endSong()
    end)

    -- setup misc variables
    self.startingSong = true
    self.endingSong = false
    
    -- make strumlines
    self.opponentStrumLine = StrumLine:new(Engine.gameWidth * 0.25, 50, Options.downscroll, "default") --- @type funkin.gameplay.StrumLine
    self.opponentStrumLine:attachNotes(table.filter(self.currentChart.notes, function(note)
        return note.lane < 4
    end))
    self.opponentStrumLine:setScrollSpeed(self.currentChart.meta.scrollSpeed[self._params.difficulty])
    self:add(self.opponentStrumLine)
    
    self.playerStrumLine = StrumLine:new(Engine.gameWidth * 0.75, 50, Options.downscroll, "default") --- @type funkin.gameplay.StrumLine
    self.playerStrumLine:attachNotes(table.filter(self.currentChart.notes, function(note)
        return note.lane > 3
    end))
    self.playerStrumLine:setScrollSpeed(self.currentChart.meta.scrollSpeed[self._params.difficulty])
    self:add(self.playerStrumLine)

    -- position strumlines on downscroll
    if Options.downscroll then
        self.opponentStrumLine:setY(Engine.gameHeight - self.opponentStrumLine:getY() - self.opponentStrumLine.receptors:getHeight())
        self.playerStrumLine:setY(Engine.gameHeight - self.playerStrumLine:getY() - self.playerStrumLine.receptors:getHeight())
    end

    -- make players (these control behaviors for the 2 strumlines)
    self.opponent = Player:new(true) --- @type funkin.gameplay.Player
    self.opponent:attachStrumLines({self.opponentStrumLine})
    self:add(self.opponent)
    
    self.player = Player:new(false) --- @type funkin.gameplay.Player
    self.player:attachStrumLines({self.playerStrumLine})
    self:add(self.player)
    
    self.noteSpawner = NoteSpawner:new() --- @type funkin.gameplay.NoteSpawner
    self.noteSpawner:attachStrumLines({self.opponentStrumLine, self.playerStrumLine})
    self:add(self.noteSpawner)

    self:setPlaybackRate(1.25)
end

function Gameplay:update(dt)
    local mainConductor = self.mainConductor
    if self.startingSong then
        mainConductor:setTime(mainConductor:getRawTime() + (dt * 1000.0))
        if mainConductor:getRawTime() >= 0 then
            mainConductor.rawTime = 0.0
            self:startSong()
        end
    end
    if self.endingSong then
        -- if you're softlocked on song end, just press end or your back binds
        -- to instantly go to freeplay
        if Controls.justPressed.BACK then
            Engine.switchScene(require("funkin.scenes.FreeplayMenu"):new())
        end
    end
    Gameplay.super.update(self, dt)
end

function Gameplay:startSong()
    self.startingSong = false

    BGM.play(nil, false)
    BGM.audioPlayer:setPitch(self:getPlaybackRate())

    self.mainConductor.music = BGM.audioPlayer
end

function Gameplay:endSong()
    if self.endingSong then
        return
    end
    self.endingSong = true

    BGM.stop()
    self.mainConductor.music = nil

    if self._params.gameMode == "story" then
        -- TODO: story mode in general lol!!
    
    elseif self._params.gameMode == "freeplay" then
        -- TODO: highscore :O
        CoolUtil.playMenuMusic()
        Engine.switchScene(require("funkin.scenes.FreeplayMenu"):new())
    
    else
        print("Unknown game mode: " .. self._params.gameMode .. ", press one of your BACK binds to go to freeplay")
    end
end

function Gameplay:getPlaybackRate()
    return Engine.timeScale
end

function Gameplay:setPlaybackRate(newRate)
    Engine.timeScale = newRate
    BGM.audioPlayer:setPitch(newRate)
end

return Gameplay