---
--- @class funkin.data.charts.ChartEvent
---
local ChartEvent = {
    ---
    --- The time that this event is executed at
    --- during the song. (in seconds)
    ---
    --- @type number
    ---
    time = nil,

    ---
    --- The type of this note.
    --- 
    --- Note types control the behavior of notes,
    --- such as if they should be hit or not.
    ---
    --- @type string
    ---
    type = nil,

    ---
    --- The parameters given to this event when
    --- it is executed during a song.
    ---
    --- @type table<string, any>
    ---
    params = nil
}
return ChartEvent