local group = require("flora.display.group")

--- 
--- A class with functionality similar to a `group`, but
--- designed to be a primary scene/screen of sorts.
--- 
--- @class flora.display.screen : flora.display.group
--- 
local screen = group:extend()

---
--- The function that gets called when this scene
--- is done initializing internal Flora stuff.
--- 
--- Initialize your stuff here, instead of in the constructor!
---
function screen:ready()
end

return screen