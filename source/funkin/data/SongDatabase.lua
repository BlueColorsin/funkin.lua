---
--- @class funkin.data.SongDatabase
---
local SongDatabase = {}

SongDatabase.levelList = {}
SongDatabase.songList = {}
SongDatabase.songMetadataList = {}

---
--- @return boolean
---
function SongDatabase.updateLevelList()
    SongDatabase.levelList = {}

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
        table.insert(SongDatabase.levelList, levelData)
    end
    if Settings.data.verboseLogging then
        Flora.log:verbose("Found " .. #SongDatabase.levelList .. " level" .. (#SongDatabase.levelList ~= 1 and "s" or ""))
    end
    return true
end

---
--- @return boolean
---
function SongDatabase.updateSongList()
    SongDatabase.songList = {}
    SongDatabase.songMetadataList = {}

    -- TODO: support mods
    if #SongDatabase.levelList == 0 then
        Flora.log:warn("No levels were found, please call updateLevelList() first!")
        return false
    end
    for i = 1, #SongDatabase.levelList do
        local levelData = SongDatabase.levelList[i]
        for j = 1, #levelData.songs do
            ---
            --- @type string
            ---
            local songID = levelData.songs[j]
            table.insert(SongDatabase.songList, songID)
        end
    end
    if Settings.data.verboseLogging then
        Flora.log:verbose("Found " .. #SongDatabase.songList .. " song" .. (#SongDatabase.songList ~= 1 and "s" or ""))
    end
    return true
end

---
--- @param  song  string
---
--- @return table?
---
function SongDatabase.getSongMetadata(song)
    if not SongDatabase.songMetadataList[song] then
        -- TODO: support mods
        if not File.exists(Paths.json("meta", "songs/" .. song)) then
            Flora.log:warn("Song metadata for " .. song .. " doesn't exist!")
            return nil
        end
        local raw = Json.parse(File.read(Paths.json("meta", "songs/" .. song)))
        SongDatabase.songMetadataList[song] = {
            title = raw.title or song,
    
            icon = raw.icon or "face",
            color = Color:new(raw.color or "#FFFFFF"),
    
            variants = raw.variants or {"base"},
            difficulties = raw.difficulties or {"easy", "normal", "hard"},
            
            bpm = raw.bpm or 120,
            timeSignature = raw.timeSignature or "4/4",
    
            artist = raw.artist or "Unknown",
            charter = raw.charter or "Unknown",
    
            characters = raw.characters or {
                opponent = "bf",
                spectator = "gf",
                player = "bf"
            },
            uiSkin = raw.uiSkin or "base",
            scrollSpeed = raw.scrollSpeed or {
                default = 2.0
            }
        }
    end
    return SongDatabase.songMetadataList[song]
end

return SongDatabase