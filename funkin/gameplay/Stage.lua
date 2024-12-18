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
--- @class funkin.gameplay.Stage : chip.core.Group
---
local Stage = Group:extend("Stage", ...)

function Stage:constructor(stageID)
    Stage.super.constructor(self)

    ---
    --- @protected
    ---
    self._stageID = stageID --- @type string

    local json = StageData.get(self._stageID) --- @type funkin.backend.data.StageData?

    self.zoom = json and json.zoom or 1.0 --- @type number
    self.folder = json and json.folder or "game/stages/stage" --- @type string
    self.objects = json and json.objects or {
        {
            type = "spectator",
            properties = {}
        },
        {
            type = "opponent",
            properties = {}
        },
        {
            type = "player",
            properties = {}
        }
    } --- @type table<funkin.backend.data.StageObjectData>

    self.startingCameraPos = json and json.cameraPosition or {x = 100, y = 100} --- @type {x: number, y: number}

    local function addObject(tag, obj)
        -- TODO: utilize tag for stage scripts
        self:add(obj)
    end
    ---
    --- @param  object  funkin.backend.data.StageObjectData
    ---
    local function spectatorCase(object)
        print("adding spectator,,")
    end
    ---
    --- @param  object  funkin.backend.data.StageObjectData
    ---
    local function opponentCase(object)
        print("adding opponent,,")
    end
    ---
    --- @param  object  funkin.backend.data.StageObjectData
    ---
    local function playerCase(object)
        print("adding player,,")
    end
    local cases = {
        ---
        --- @param  object  funkin.backend.data.StageObjectData
        ---
        sprite = function(object)
            local sprite = Sprite:new() --- @type chip.graphics.Sprite
            if object.properties.texture then
                local gridSize = object.properties.gridSize --- @type {x: number, y: number}?
                if gridSize then
                    sprite:loadTexture(Paths.image(object.properties.texture, "images/" .. self.folder), true, gridSize.x, gridSize.y)
                else
                    sprite:loadTexture(Paths.image(object.properties.texture, "images/" .. self.folder))
                end
            end
            local scale = object.properties.scale --- @type {x: number, y: number}?
            if scale then
                sprite.scale:set(scale.x, scale.y)
            end
            local position = object.properties.position --- @type {x: number, y: number}?
            if position then
                sprite:setPosition(position.x, position.y)
            end
            local scroll = object.properties.scroll --- @type number|{x: number, y: number}?
            if scroll then
                if type(scroll) == "number" then
                    sprite.scrollFactor:set(scroll, scroll)
                else
                    sprite.scrollFactor:set(scroll.x, scroll.y)
                end
            end
            addObject(object.tag, sprite)
        end,
        ---
        --- @param  object  funkin.backend.data.StageObjectData
        ---
        box = function(object)
            local sprite = Sprite:new() --- @type chip.graphics.Sprite
            local color = Color:new(object.properties.color) --- @type chip.utils.Color

            local size = object.properties.size --- @type {x: number, y: number}
            sprite:makeSolid(size.x, size.y, color)
            
            local position = object.properties.position --- @type {x: number, y: number}?
            if position then
                sprite.position:set(position.x, position.y)
            end
            local scroll = object.properties.scroll --- @type {x: number, y: number}?
            if scroll then
                sprite.scrollFactor:set(scroll.x, scroll.y)
            end
            addObject(object.tag, sprite)
        end,
        spectator = spectatorCase,
        gf = spectatorCase,
        girlfriend = spectatorCase,

        opponent = opponentCase,
        dad = opponentCase,

        player = playerCase,
        bf = playerCase,
        boyfriend = playerCase
    
    } --- @type table<funkin.backend.data.StageObjectType, function>

    local objects = self.objects --- @type table<funkin.backend.data.StageObjectData>
    for i = 1, #objects do
        local object = objects[i] --- @type funkin.backend.data.StageObjectData
        local case = cases[object.type:lower()] --- @type function?
        if case then
            case(object)
        end
    end
end

function Stage:getStageID()
    return self._stageID
end

return Stage