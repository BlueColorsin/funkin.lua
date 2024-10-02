---
--- @class funkin.input.InputAction
---
local InputAction = Class:extend("InputAction", ...)

-- TODO: store gamepad shit in here alongside keys

function InputAction:constructor(id, defaultKeys)
    ---
    --- The ID of this action in save data.
    ---
    --- @type string
    ---
    self.id = id

    ---
    --- The keys registered to this action.
    --- 
    --- @type table<string>
    ---
    self.keys = {}

    if not Controls._save.data[id] then
        self.keys = defaultKeys
        local newAction = {
            keys = self.keys
        }
        Controls._save.data[id] = newAction
    else
        local action = Controls._save.data[id]
        self.keys = action.keys or defaultKeys
    end
end

---
--- @param  state  integer
---
--- @return boolean
---
function InputAction:check(state)
    for i = 1, #self.keys do
        if Flora.keys:checkState(self.keys[i], state) then
            return true
        end
    end
    return false
end

return InputAction