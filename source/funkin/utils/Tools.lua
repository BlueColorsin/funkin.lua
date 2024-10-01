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
        table.insert(line:split(","))
    end
    return list
end

return Tools