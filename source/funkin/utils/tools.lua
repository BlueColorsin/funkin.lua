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
    local split_csv = csv:trim():replace("\r", ""):split("\n")
    for i = 1, #split_csv do
        ---
        --- @type string
        ---
        local line = split_csv[i]
        table.insert(line:split(","))
    end
    return list
end

return Tools