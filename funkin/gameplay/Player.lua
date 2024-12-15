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

local max = math.max

local Scoring = require("funkin.gameplay.scoring.Scoring") --- @type funkin.gameplay.scoring.Scoring
local PlayerStats = require("funkin.gameplay.PlayerStats") --- @type funkin.gameplay.PlayerStats

local NoteSplash = require("funkin.gameplay.NoteSplash") --- @type funkin.gameplay.NoteSplash

local function noteSort(a, b)
    return a:getTime() < b:getTime()
end

---
--- @class funkin.gameplay.Player : chip.core.Actor
---
local Player = Actor:extend("Player", ...)

function Player:constructor(cpu)
    Player.super.constructor(self)

    self.cpu = cpu --- @type boolean

    self.stats = PlayerStats:new() --- @type funkin.gameplay.PlayerStats

    ---
    --- @protected
    ---
    self._attachedStrumLines = {} --- @type table<funkin.gameplay.StrumLine>

    ---
    --- @protected
    --- @type table<funkin.backend.input.InputAction>
    ---
    self._inputActions = {
        Controls.list.NOTE_LEFT,
        Controls.list.NOTE_DOWN,
        Controls.list.NOTE_UP,
        Controls.list.NOTE_RIGHT
    }
end

function Player:getAttachedStrumLines()
    return self._attachedStrumLines
end

---
--- @param  strumLines  table<funkin.gameplay.StrumLine>
---
function Player:attachStrumLines(strumLines)
    self._attachedStrumLines = strumLines
end

---
--- @param  note  funkin.gameplay.Note
---
function Player:missNote(note)
    note:miss()

    self.stats:resetCombo()
    self.stats:increaseMissCombo()

    self.stats:increaseScore(-10)
    self.stats:increaseHealth(-(0.0475 + math.min(note:getLength() * 0.001, 0.1)))

    if self.cpu then
        return
    end
    -- TODO: make a signal that gameplay hooks to instead
    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    if not Options.comboStacking then
        game.comboPopups:killAllSprites()
    end
    game.comboPopups:showJudgement("miss", note:getSkin())
    game.comboPopups:showCombo(-self.stats.missCombo, note:getSkin(), true)
    game:updateScoreText()
end

---
--- @param  note  funkin.gameplay.Note
---
function Player:hitNote(note)
    local songPos = note:getAttachedConductor():getTime()

    local judgement = Scoring.judgeNote(note, songPos)
    local accScore = Scoring.getAccuracyScore(judgement)
    
    local stats = self.stats
    stats:resetMissCombo()
    stats:increaseCombo()
    
    local score = Scoring.scoreNote(note, songPos)
    stats:increaseScore(score)
    stats:increaseHealth(0.023)

    stats:increaseTotalNotesHit()
    stats:increaseAccuracyScore(accScore)

    note:hit()
    
    if self.cpu then
        return
    end
    local strumLine = note:getStrumLine() --- @type funkin.gameplay.StrumLine

    -- TODO: make a signal that gameplay hooks to instead
    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    if not Options.comboStacking then
        game.comboPopups:killAllSprites()
    end
    game.comboPopups:showJudgement(judgement, note:getSkin())
    game.comboPopups:showCombo(self.stats.combo, note:getSkin())
    game:updateScoreText()

    if Scoring.splashAllowed(judgement) then
        --- @type funkin.gameplay.NoteSplash
        local splash = strumLine.splashes:recycle(NoteSplash, function()
            return NoteSplash:new(-999999, -999999, note:getLaneID())
        end)
        splash:setup(strumLine, note:getLaneID(), note:getSkin())
    end
end

---
--- @param  strumLine  funkin.gameplay.StrumLine
---
function Player:processOpponent(strumLine)
    local notes = strumLine.notes --- @type chip.graphics.CanvasLayer
    local noteMembers = notes:getMembers() --- @type table<funkin.gameplay.Note>

    local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>
    for i = 1, notes:getLength() do
        local note = noteMembers[i] --- @type funkin.gameplay.Note
        if note:isExisting() and note:isActive() then
            local wasHit = note:wasHit()
            local wasMissed = note:wasMissed()

            local time = note:getTime()
            local length = note:getLength()

            local songPos = note:getAttachedConductor():getTime()

            -- if the note is able to be hit, hit it
            if not wasHit and time < songPos then
                local receptor = receptors[note:getLaneID() + 1] --- @type funkin.gameplay.Receptor
                receptor:press(true, max(length, note:getAttachedConductor():getStepCrotchet()))
                self:hitNote(note)
            end
            -- kill note if it was held fully
            if wasHit and not wasMissed and time < songPos - length then
                note:kill()
                note:getSustain():kill()
            end
        end
    end
end

---
--- @param  strumLine  funkin.gameplay.StrumLine
---
function Player:processPlayer(strumLine)
    local notes = strumLine.notes --- @type chip.graphics.CanvasLayer
    local noteMembers = notes:getMembers() --- @type table<funkin.gameplay.Note>

    for i = 1, notes:getLength() do
        local note = noteMembers[i] --- @type funkin.gameplay.Note
        if note:isExisting() and note:isActive() then
            local wasHit = note:wasHit()
            local wasMissed = note:wasMissed()

            local time = note:getTime()
            local length = note:getLength()

            local songPos = note:getAttachedConductor():getTime()
            local stepCrotchet = note:getAttachedConductor():getStepCrotchet()

            -- if note is too late, miss it
            if note:isTooLate() and not wasHit and not wasMissed then
                self:missNote(note)
            end
            -- give points for sustains
            if wasHit and not wasMissed and length > 0 then
                local dt = Engine.deltaTime
                self.stats:increaseHealth(dt * 0.125)
                self.stats:increaseScore(dt * 250.0)

                -- TODO: make a signal that gameplay hooks to instead
                local game = Gameplay.instance --- @type funkin.scenes.Gameplay
                game:updateScoreText()
            end
            -- kill note if it was held fully
            if wasHit and not wasMissed and time < songPos - length then
                note:kill()
                note:getSustain():kill()
            end
            -- kill note if it was missed and is off screen
            if wasMissed and time < songPos - ((length + 320) / strumLine:getScrollSpeed()) then
                note:kill()
                note:getSustain():kill()
                print("A")
            end
        end
    end
end

function Player:update(dt)
    for i = 1, #self._attachedStrumLines do
        local strumLine = self._attachedStrumLines[i] --- @type funkin.gameplay.StrumLine
        if self.cpu then
            self:processOpponent(strumLine)
        else
            self:processPlayer(strumLine)
        end
    end
end

---
--- @param  event  chip.input.InputEvent
---
function Player:input(event)
    if self.cpu then
        return
    end
    local actions = self._inputActions --- @type table<funkin.backend.input.InputAction>
    for i = 1, #actions do
        local action = actions[i] --- @type funkin.backend.input.InputAction
        if event:isPressed() then
            if action:check(InputState.JUST_PRESSED) then
                for j = 1, #self._attachedStrumLines do
                    local strumLine = self._attachedStrumLines[j] --- @type funkin.gameplay.StrumLine
                    local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>
    
                    local receptor = receptors[i] --- @type funkin.gameplay.Receptor
                    local availableNotes = table.filter(strumLine.notes:getMembers(), function(n)
                        return n:getLaneID() == i - 1 and n:isExisting() and n:isActive() and n:canBeHit() and not n:isTooLate()
                    end)
                    table.sort(availableNotes, noteSort)
    
                    local canHitNote = #availableNotes > 0
                    if canHitNote then
                        local note = availableNotes[1] --- @type funkin.gameplay.Note
                        self:hitNote(note)
                    end
                    receptor:press(canHitNote)
                end
            end
        else
            if action:check(InputState.JUST_RELEASED) then
                for j = 1, #self._attachedStrumLines do
                    local strumLine = self._attachedStrumLines[j] --- @type funkin.gameplay.StrumLine
                    local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>
    
                    local receptor = receptors[i] --- @type funkin.gameplay.Receptor
                    receptor:release()

                    local noteMembers = strumLine.notes:getMembers() --- @type table<funkin.gameplay.Note>
                    for k = 1, strumLine.notes:getLength() do
                        local note = noteMembers[k] --- @type funkin.gameplay.Note
                        if note:isExisting() and note:isActive() and note:getLaneID() == i - 1 and note:wasHit() and not note:wasMissed() and note:getTime() > note:getAttachedConductor():getTime() - (note:getLength() - 200) then
                            self:missNote(note)
                        end
                    end
                end
            end
        end
    end
    Player.super.input(self)
end

return Player