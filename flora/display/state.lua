local group = require("flora.display.group")

--- 
--- A class with functionality similar to a `group`, but
--- designed to be a primary scene/state of sorts.
--- 
--- @class flora.display.state : flora.display.group
--- 
local state = group:extend()

function state:constructor()
    state.super.constructor(self)

    ---
    --- Controls whether or not this state is allowed
    --- to keep updating even if a substate is opened on it.
    --- 
    --- @type boolean
    ---
    self.persistent_update = false

    ---
    --- Controls whether or not this state is allowed
    --- to keep drawing even if a substate is opened on it.
    --- 
    --- @type boolean
    ---
    self.persistent_draw = true
end

---
--- The function that gets called when this scene
--- is done initializing internal Flora stuff.
--- 
--- Initialize your stuff here, instead of in the constructor!
---
function state:ready()
end

return state