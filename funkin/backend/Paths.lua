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

local AtlasFrames = qrequire("chip.animation.frames.AtlasFrames") --- @type chip.animation.frames.AtlasFrames

---
--- @class funkin.backend.Paths
---
local Paths = {}

function Paths.getPath(key)
    return "assets/" .. key
end

function Paths.image(key, dir)
    return Paths.getPath((dir or "images") .. "/" .. key .. "." .. Constants.IMAGE_EXT)
end

function Paths.xml(key, dir)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".xml")
end

function Paths.json(key, dir)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".json")
end

function Paths.music(key, dir)
    return Paths.getPath((dir or "music") .. "/" .. key .. "." .. Constants.SOUND_EXT)
end

function Paths.sound(key, dir)
    return Paths.getPath((dir or "sounds") .. "/" .. key .. "." .. Constants.SOUND_EXT)
end

function Paths.getSparrowAtlas(key, dir)
    local imgPath = Paths.image(key, (dir or "images"))
    local xmlPath = Paths.xml(key, (dir or "images"))

    local cache = Cache.atlasCache
    local atlasKey = "#_SPARROW_" .. imgPath .. "|" .. xmlPath
    
    if not cache[atlasKey] then
        cache[atlasKey] = AtlasFrames.fromSparrow(imgPath, xmlPath)
    end
    return cache[atlasKey]
end

return Paths