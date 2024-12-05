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

---
--- @class funkin.states.FreeplayState : chip.core.Scene
---
local FreeplayState = Scene:extend("FreeplayState", ...)

function FreeplayState:init()
    self.songMetas = {} --- @type table<string, table<string, funkin.backend.song.SongMetadata>>

    -- TODO: modding support for levelList
    local failedSongs = {} --- @type table<string, boolean>
    local levelList = Json.parse(File.read(Paths.json("levelList")))

    for i = 1, #levelList.levels do
        -- go through each level
        local levelID = levelList.levels[i] --- @type string
        if not File.exists(Paths.json(levelID, "data/levels")) then
            -- if it doesn't exist, skip
            goto levelContinue
        end
        local levelData = Json.parse(File.read(Paths.json(levelID, "data/levels")))
        for j = 1, #levelData.songs do
            -- go through each song in this level
            local songID = levelData.songs[j] --- @type string
            local songMeta = SongMetadata.get(songID) --- @type funkin.backend.song.SongMetadata?
            
            if not songMeta then
                -- if it doesn't exist, skip
                table.insert(failedSongs, songID)
                goto songContinue
            end
            local data = {
                default = songMeta
            }
            Log.info({text = "[FREEPLAY] ", fgColor = Native.ConsoleColor.CYAN}, nil, nil, "Metadata found for " .. songID)

            for k = 1, #songMeta.variants do
                -- go through each variant
                local variant = songMeta.variants[k] --- @type string
                local variantMeta = SongMetadata.get(songID .. "-" .. variant) --- @type funkin.backend.song.SongMetadata?
                
                if variantMeta then
                    -- if it exists, add it
                    data[variant] = variantMeta
                    Log.info({text = "[FREEPLAY] ", fgColor = Native.ConsoleColor.CYAN}, nil, nil, "Metadata found for " .. songID .. " [" .. variant .. "]")
                end
            end
            self.songMetas[songID] = data
            ::songContinue::
        end
        ::levelContinue::
    end
    if #failedSongs ~= 0 then
        print("============================================================")
        Log.info({text = "[FREEPLAY] ", fgColor = Native.ConsoleColor.CYAN}, nil, nil, "Non-existent songs: " .. table.join(failedSongs, ", "))
    end
    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:loadTexture(Paths.image("desat", "images/menus"))
    self.bg:screenCenter("xy")
    self:add(self.bg)
end

function FreeplayState:update(dt)
    if Controls.justPressed.BACK then
        Engine.switchScene(require("funkin.states.MainMenuState"):new())
    end
    FreeplayState.super.update(self, dt)
end

function FreeplayState:free()
    FreeplayState.super.free(self)
end

return FreeplayState