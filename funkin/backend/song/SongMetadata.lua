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
--- @class funkin.backend.song.SongMetadata
---
local SongMetadata = {
    title = nil, --- @type string
    
    icon = nil, --- @type string
    color = nil, --- @type string

    variants = nil, --- @type table<string>
    difficulties = nil, --- @type table<string>

    bpm = nil, --- @type number
    timeSignature = nil, --- @type string

    artist = nil, --- @type string
    charter = nil, --- @type string

    characters = nil, --- @type table<string, string>
    scrollSpeed = nil, --- @type table<string, number>

    stage = nil, --- @type string
    uiSkin = nil, --- @type string

    generatedBy = nil, --- @type string
}

---
--- Retrieves the metadata for a song.
--- 
--- @param  song  string  ID of the song to get the metadata of.
---
--- @return funkin.backend.song.SongMetadata?
---
function SongMetadata.get(song)
    if not File.exists(Paths.json("meta", "songs/" .. song)) then
        return nil
    end
    return Json.parse(File.read(Paths.json("meta", "songs/" .. song)))
end

return SongMetadata