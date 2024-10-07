---
--- @class funkin.data.charts.ChartNote
---
local ChartNote = {
    ---
    --- The time that this note is played at
    --- during the song. (in seconds)
    ---
    --- @type number
    ---
    time = nil,

    ---
    --- The index/ID corresponding to the strum that
    --- this note should belong to.
    ---
    --- @type integer
    ---
    lane = nil,

    ---
    --- The sustain length of this note. (in seconds)
    ---
    --- @type number
    ---
    length = nil,

    ---
    --- The type of this note.
    --- 
    --- Note types control the behavior of notes,
    --- such as if they should be hit or not.
    ---
    --- @type string
    ---
    type = nil
}
return ChartNote