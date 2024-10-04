---
--- @class funkin.utils.Tools
---
local Tools = Class:extend()

---
--- @param  csv  string
---
--- @return table
---
function Tools.parseCSV(csv)
    local list = {}
    local splitCSV = csv:trim():replace("\r", ""):split("\n")
    for i = 1, #splitCSV do
        ---
        --- @type string
        ---
        local line = splitCSV[i]
        table.insert(list, line:split(","))
    end
    return list
end

function Tools.playMusic(music, volume, looping)
    local meta = Json.parse(File.read(Path.directory(music) .. "/meta.json"))
    Flora.sound:playMusic(music, nil, volume and volume or 1.0, looping and looping or true)

    Conductor.instance:reset(meta.bpm)
    Conductor.instance.timeSignature = Conductor.timeSignatureFromString(meta.timeSignature)
    Conductor.instance.music = Flora.sound.music
end

return Tools