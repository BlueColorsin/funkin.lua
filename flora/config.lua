---
--- @class flora.config
---
--- A class for configuring Flora.
---
local config = class:extend()

function config:constructor()
    self.source_folder = "source"
    self.debug_mode = false
    
    ---
    --- @type flora.math.vector2
    ---
    self.game_size = vector2:new(640, 480)
    self.max_fps = 0

    ---
    --- @type flora.display.screen
    ---
    self.initial_screen = nil
end

return config