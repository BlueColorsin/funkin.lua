local group = require("flora.display.group")

--- 
--- A class with functionality similar to a `group`, but
--- designed to be a primary scene/state of sorts.
--- 
--- @class flora.display.state : flora.display.group
--- 
local state = group:extend()

---
--- The function that gets called when this scene
--- is done initializing internal Flora stuff.
--- 
--- Initialize your stuff here, instead of in the constructor!
---
function state:ready()
end

return state