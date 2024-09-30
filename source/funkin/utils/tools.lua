---
--- @class funkin.utils.tools
---
local tools = class:extend()

---
--- @param  csv  string
---
--- @return table
---
function tools.parse_csv(csv)
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

return tools