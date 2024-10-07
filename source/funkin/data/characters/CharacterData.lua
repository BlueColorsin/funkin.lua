---
--- @class funkin.data.characters.CharacterData
---
local CharacterData = {
    ---
    --- @type funkin.data.characters.HealthIconData?
    ---
    healthIcon = nil,

    ---
    --- @type funkin.data.enums.AtlasType
    ---
    atlasType = nil,

    ---
    --- @type string
    ---
    atlasPath = nil,

    ---
    --- @type table<string, boolean>?
    ---
    gridSize = nil,

    ---
    --- @type table<funkin.data.characters.CharacterAnimationData>
    ---
    animations = nil,

    ---
    --- @type table<string, number>?
    ---
    position = nil,

    ---
    --- @type table<string, number>?
    ---
    camera = nil,

    ---
    --- @type number?
    ---
    scale = nil,

    ---
    --- @type table<string, boolean>?
    ---
    flip = nil,

    ---
    --- @type boolean?
    ---
    isPlayer = nil,

    ---
    --- @type boolean?
    ---
    antialiasing = nil,

    ---
    --- @type number?
    ---
    singDuration = nil,

    ---
    --- @type table<string>?
    ---
    danceSteps = nil
}

---
--- @param  character  string  The name of the character to load.
---
--- @return funkin.data.characters.CharacterData?
---
function CharacterData.load(character)
    -- TODO: support mods
    if not Cache.characterDataCache[character] then
        if not File.exists(Paths.json(character, "data/characters")) then
            Flora.log:warn("Character data for " .. character .. " doesn't exist!")
            return nil
        end
        Cache.characterDataCache[character] = Json.parse(File.read(Paths.json(character, "data/characters")))
    end
    return Cache.characterDataCache[character]
end

return CharacterData