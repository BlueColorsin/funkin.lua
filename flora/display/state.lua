--- 
--- A class with functionality similar to a `Group`, but
--- designed to be a primary scene/state of sorts.
--- 
--- @class flora.display.State : flora.display.Group
--- 
local State = Group:extend("state", ...)

function State:constructor()
    State.super.constructor(self)

    ---
    --- Controls whether or not this state is allowed
    --- to keep updating even if a substate is opened on it.
    --- 
    --- @type boolean
    ---
    self.persistentUpdate = false

    ---
    --- Controls whether or not this state is allowed
    --- to keep drawing even if a substate is opened on it.
    --- 
    --- @type boolean
    ---
    self.persistentDraw = true
end

---
--- The function that gets called when this scene
--- is done initializing internal Flora stuff.
--- 
--- Initialize your stuff here, instead of in the constructor!
---
function State:ready()
end

return State