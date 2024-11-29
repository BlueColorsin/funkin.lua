---
--- @class funkin.states.InitState : chip.core.Scene
---
local InitState = Scene:extend("InitState", ...)

function InitState:init()
    Engine.switchScene(require("funkin.states.TitleState"):new())
end

return InitState