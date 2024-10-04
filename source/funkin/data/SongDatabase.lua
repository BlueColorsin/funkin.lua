---
--- @class funkin.data.SongDatabase
---
local SongDatabase = {}

SongDatabase.levels = {}
SongDatabase.songs = {}

---
--- @return boolean
---
function SongDatabase.updateLevelList()
    SongDatabase.levels = {}

    -- TODO: support mods
    if not File.exists(Paths.json("levelList")) then
        Flora.log:warn("levelList.json doesn't exist!")
        return false
    end
    local levelListData = Json.parse(File.read(Paths.json("levelList")))
    for i = 1, #levelListData.levels do
        ---
        --- @type string
        ---
        local levelID = levelListData.levels[i]
        if not File.exists(Paths.json(levelID, "data/levels")) then
            Flora.log:warn("Level called \"" .. levelID .. "\" doesn't exist!")
            return false
        end
        local levelData = Json.parse(File.read(Paths.json(levelID, "data/levels")))
        table.insert(SongDatabase.levels, levelData)
    end
    if Flora.config.debugMode then
        Flora.log:verbose("Found " .. #SongDatabase.levels .. " level" .. (#SongDatabase.levels ~= 1 and "s" or ""))
    end
    return true
end

---
--- @return boolean
---
function SongDatabase.updateSongList()
    SongDatabase.songs = {}

    -- TODO: support mods
    if #SongDatabase.levels == 0 then
        Flora.log:warn("No levels were found, please call updateLevelList() first!")
        return false
    end
    for i = 1, #SongDatabase.levels do
        local levelData = SongDatabase.levels[i]
        for j = 1, #levelData.songs do
            ---
            --- @type string
            ---
            local songID = levelData.songs[j]
            table.insert(SongDatabase.songs, songID)
        end
    end
    if Flora.config.debugMode then
        Flora.log:verbose("Found " .. #SongDatabase.songs .. " song" .. (#SongDatabase.songs ~= 1 and "s" or ""))
    end
    return true
end

function SongDatabase.getSongMetadata(song)

end

return SongDatabase