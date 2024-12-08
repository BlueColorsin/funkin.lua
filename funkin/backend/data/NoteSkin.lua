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
--- @class funkin.backend.data.NoteSkinAnimationData
---
local NoteSkinAnimationData = {
    name = nil, --- @type string
    prefixes = nil, --- @type table<string>?
    indices = nil, --- @type table<table<integer>>?
    fps = nil, --- @type integer
    looped = nil, --- @type boolean
    offsets = nil, --- @type table<table<string, number>>
}

---
--- @class funkin.backend.data.NoteSkinData
---
local NoteSkinData = {
    scale = nil, --- @type number
    spacing = nil, --- @type number

    folder = nil, --- @type string
    texture = nil, --- @type string

    atlasType = nil, --- @type funkin.backend.enums.AtlasType
    gridSize = nil, --- @type table<string, number>?

    animations = nil, --- @type table<funkin.backend.data.NoteSkinAnimationData>
    offset = nil, --- @type table<string, number>

    antialiasing = nil --- @type boolean?
}

---
--- @class funkin.backend.data.NoteSkin
---
local NoteSkin = {
    receptors = nil, --- @type funkin.backend.data.NoteSkinData
    notes = nil, --- @type funkin.backend.data.NoteSkinData
    sustains = nil --- @type funkin.backend.data.NoteSkinData
}

---
--- @param  noteSkin  string  The name of the noteskin to load.
---
--- @return funkin.backend.data.NoteSkin?
---
function NoteSkin.get(noteSkin)
    if not Cache.noteSkinCache[noteSkin] then
        Cache.noteSkinCache[noteSkin] = Json.parse(File.read(Paths.json(noteSkin, "data/noteskins")))
    end
    return Cache.noteSkinCache[noteSkin]
end

return NoteSkin