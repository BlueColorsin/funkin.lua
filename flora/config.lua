---
--- @class flora.config
---
--- A class for configuring Flora.
---
local config = class:extend()

function config:constructor()
    self.source_folder = "source"
    self.debug_mode = false
    
    self.game_width = 0.0
    self.game_height = 0.0

    self.max_fps = 60

    ---
    --- @type flora.display.state
    ---
    self.initial_state = nil
end

return config