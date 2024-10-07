---
--- @class funkin.data.characters.CharacterAnimationData
---
local CharacterAnimationData = {
    ---
    --- @type string
    ---
    name = nil,

    ---
    --- @type string?
    ---
    prefix = nil,

    ---
    --- @type table<integer>?
    ---
    indices = nil,

    ---
    --- @type number
    ---
    fps = nil,

    ---
    --- @type boolean
    ---
    looped = nil,

    ---
    --- @type table<string, integer>
    ---
    offset = nil
}
return CharacterAnimationData