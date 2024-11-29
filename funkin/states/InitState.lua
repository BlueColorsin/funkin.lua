local StatsDisplay = require("funkin.backend.StatsDisplay")

---
--- @class funkin.states.InitState : chip.core.Scene
---
local InitState = Scene:extend("InitState", ...)

function InitState:init()
    StatsDisplay.init()
    Engine.switchScene(require("funkin.states.TitleState"):new())
end

return InitState