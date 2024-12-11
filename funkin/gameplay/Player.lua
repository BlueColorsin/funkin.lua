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
--- @param  strumLine  funkin.gameplay.StrumLine
---
function Player:processOpponent(strumLine)
    local notes = strumLine.notes --- @type chip.graphics.CanvasLayer
    local noteMembers = notes:getMembers() --- @type table<funkin.gameplay.Note>

    local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>
    for i = 1, notes:getLength() do
        local note = noteMembers[i] --- @type funkin.gameplay.Note
        if note:isExisting() and note:isActive() then
            if note:getTime() < note:getAttachedConductor():getTime() then
                local receptor = receptors[note:getLaneID() + 1] --- @type funkin.gameplay.Receptor
                receptor:press(true, note:getAttachedConductor():getStepCrotchet() + 100)
                note:kill()
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
            if note:isTooLate() and not note:wasMissed() then
                note:miss()
            end
            if note:wasMissed() and note:getTime() < note:getAttachedConductor():getTime() - (320 / strumLine:getScrollSpeed()) then
                note:kill()
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

function Player:input(_)
    if self.cpu then
        return
    end
    local actions = self._inputActions --- @type table<funkin.backend.input.InputAction>
    for i = 1, #actions do
        local action = actions[i] --- @type funkin.backend.input.InputAction
        if action:check(InputState.JUST_PRESSED) then
            for j = 1, #self._attachedStrumLines do
                local strumLine = self._attachedStrumLines[j] --- @type funkin.gameplay.StrumLine
                local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>

                local receptor = receptors[i] --- @type funkin.gameplay.Receptor
                local availableNotes = table.filter(strumLine.notes:getMembers(), function(n)
                    return n:getLaneID() == i - 1 and n:isExisting() and n:isActive() and n:canBeHit() and not n:isTooLate()
                end)
                table.sort(availableNotes, noteSort)

                if #availableNotes > 0 then
                    local note = availableNotes[1] --- @type funkin.gameplay.Note
                    note:kill()
                    receptor:press(true)
                else
                    receptor:press(false)
                end
            end
        elseif action:check(InputState.JUST_RELEASED) then
            for j = 1, #self._attachedStrumLines do
                local strumLine = self._attachedStrumLines[j] --- @type funkin.gameplay.StrumLine
                local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>

                local receptor = receptors[i] --- @type funkin.gameplay.Receptor
                receptor:release()
            end
        end
    end
    Player.super.input(self)
end

return Player