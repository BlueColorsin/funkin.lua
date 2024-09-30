---
--- @class flora.Config
---
--- A class for configuring Flora.
---
local Config = Class:extend("Config", ...)

function Config:constructor()
    self.sourceFolder = "source"
    self.debugMode = false
    
    self.gameWidth = 0.0
    self.gameHeight = 0.0

    self.maxFPS = 60

    ---
    --- @type flora.display.State
    ---
    self.initialState = nil
end

return Config