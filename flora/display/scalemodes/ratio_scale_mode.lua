local base_scale_mode = require("flora.display.scalemodes.base_scale_mode")

---
--- @class flora.display.scalemodes.ratio_scale_mode : flora.display.scalemodes.base_scale_mode
---
local ratio_scale_mode = base_scale_mode:extend()

function ratio_scale_mode:constructor(fill_screen)
    ratio_scale_mode.super.constructor(self, fill_screen)

    self.fill_screen = fill_screen and fill_screen or false
end

function ratio_scale_mode:update_game_size(width, height)
    local ratio = flora.game_width / flora.game_height
    local real_ratio = width / height

    local scale_y = real_ratio < ratio
    if self.fill_screen then
        scale_y = not scale_y
    end

    if scale_y then
        self.game_size.x = width
        self.game_size.y = math.floor(self.game_size.x / ratio)
    else
        self.game_size.y = height
        self.game_size.x = math.floor(self.game_size.y * ratio)
    end
end

return ratio_scale_mode