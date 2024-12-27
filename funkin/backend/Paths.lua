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

local AtlasFrames = crequire("animation.frames.AtlasFrames") --- @type chip.animation.frames.AtlasFrames

---
--- @class funkin.backend.Paths
---
local Paths = {}

---@type string
---## IDEA
---the global redirect for EVERY asset gotten with Paths.get   
---allows you to do similar stuff to lime asset libraries without the need for   
---checks if said prefixed path exists before returning it
---
---example:   
---```lua
---local path = Paths.get("BOYFRIEND") -- return is "assets/BOYFRIEND"
---
---Paths.globalRedirect = "weeks/week1" -- sets the redirect
---local new_path = Paths.get("BOYFRIEND") -- return is "assets/weeks/week1/BOYFRIEND" if the file exists or fallback to "assets/BOYFRIEND"
---```
Paths.globalRedirect = ""

---fancy string prefixer that accounts for mods
---@param key string the name of the asset
---@param subfolder? string the folder that the asset is in
---@param mods? boolean if you want to check if it is in the mod folders as well
---@return string assetpath 
function Paths.get(key, subfolder, mods)
    local filepath = (subfolder and subfolder .. "/" or "") .. key

    if (mods or true) then
        local path = Paths.mods(key, subfolder)
        if love.filesystem.getInfo(path, "file") then return path end
    end

    return "assets/" .. filepath
end

---basically just scans the global and current mods to find any files
---@param key string
---@param subfolder? string
---@return string
function Paths.mods(key, subfolder)
    local filepath = (subfolder and subfolder .. "/" or "") .. key

    for _, mod in ipairs(Mods.modsList) do
        path = "mods/" .. mod .. "/" .. filepath
        if love.filesystem.getInfo(path, "file") then return path end
    end

    return "mods/" .. filepath
end

function Paths.image(key, subfolder)
    return Paths.get(key .. "." .. Constants.IMAGE_EXT, (subfolder or "images"))
end

function Paths.xml(key, subfolder)
    return Paths.get(key .. ".xml", (subfolder or "data"))
end

function Paths.json(key, subfolder)
    print(Paths.get(key .. ".json", (subfolder or "data")))
    return Paths.get(key .. ".json", (subfolder or "data"))
end

function Paths.csv(key, subfolder)
    return Paths.get(key .. ".csv", (subfolder or "data"))
end

function Paths.music(key, subfolder)
    return Paths.get(key .. "/music." .. Constants.SOUND_EXT, (subfolder or "music"))
end

function Paths.sound(key, subfolder)
    return Paths.get(key .. "." .. Constants.SOUND_EXT, (subfolder or "sounds"))
end

function Paths.inst(song, subfolder)
    return Paths.get(song:lower() .. "/song/Inst." .. Constants.SOUND_EXT, (subfolder or "songs"))
end

function Paths.voices(song, character, subfolder)
    return Paths.get(song:lower() .. "/song/Voices" .. ((character and #character > 0) and ("-" .. character) or "") .. "." .. Constants.SOUND_EXT, (subfolder or "songs"))
end

function Paths.chart(song, difficulty, subfolder)
    return Paths.get(song:lower() .. "/charts/" .. difficulty:lower() .. ".json", (subfolder or "songs"))
end

function Paths.songMeta(song, subfolder)
    return Paths.get(song:lower() .. "/meta.json", (subfolder or "songs"))
end

function Paths.font(key, subfolder)
    return Paths.get(key, (subfolder or "fonts"))
end

function Paths.getSparrowAtlas(key, dir)
    local imgPath = Paths.image(key, (dir or "images"))
    local xmlPath = Paths.xml(key, (dir or "images"))

    local cache = Cache.atlasCache
    local atlasKey = "#_SPARROW_" .. imgPath .. "|" .. xmlPath
    
    if not cache[atlasKey] then
        cache[atlasKey] = AtlasFrames.fromSparrow(imgPath, xmlPath)
        cache[atlasKey]:reference()
    end
    return cache[atlasKey]
end

return Paths