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

    for i = 1, notes:getLength() do
        local note = noteMembers[i] --- @type funkin.gameplay.Note
        if note:isExisting() and note:isActive() then
            if note:getTime() < note:getAttachedConductor():getTime() then
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
            local strumLine = note:getStrumLine() --- @type funkin.gameplay.StrumLine
    
            if note:getTime() < note:getAttachedConductor():getTime() - (300 / strumLine:getScrollSpeed()) then
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

return Player