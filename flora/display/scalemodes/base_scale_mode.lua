local horizontal_align = require("flora.utils.horizontal_align")
local vertical_align = require("flora.utils.vertical_align")

---
--- @class flora.display.scalemodes.base_scale_mode
---
local base_scale_mode = class:extend("base_scale_mode", ...)

function base_scale_mode:constructor()
    ---
    --- @type flora.math.vector2
    ---
    self.device_size = vector2:new()

    ---
    --- @type flora.math.vector2
    ---
    self.game_size = vector2:new()

    ---
    --- @type flora.math.vector2
    ---
    self.scale = vector2:new()

    ---
    --- @type flora.math.vector2
    ---
    self.offset = vector2:new()

    ---
    --- @type integer
    ---
    self.horizontal_align = horizontal_align.CENTER

    ---
    --- @type integer
    ---
    self.vertical_align = vertical_align.CENTER
end

function base_scale_mode:on_measure(width, height)
    self:update_game_size(width, height)
    self:update_device_size(width, height)
    self:update_scale_offset()
end

function base_scale_mode:update_game_size(width, height)
    self.game_size:set(width, height)
end

function base_scale_mode:update_device_size(width, height)
    self.device_size:set(width, height)
end

function base_scale_mode:update_scale_offset()
    self.scale.x = self.game_size.x / flora.game_width
    self.scale.y = self.game_size.y / flora.game_height
    self:update_offset_x()
    self:update_offset_y()
end

function base_scale_mode:update_offset_x()
    if self.horizontal_align == horizontal_align.LEFT then
        self.offset.x = 0
    
    elseif self.horizontal_align == horizontal_align.CENTER then
        self.offset.x = math.ceil((self.device_size.x - self.game_size.x) * 0.5)
    
    elseif self.horizontal_align == horizontal_align.RIGHT then
        self.offset.x = self.device_size.x - self.game_size.x
    end
end

function base_scale_mode:update_offset_y()
    if self.vertical_align == vertical_align.LEFT then
        self.offset.y = 0
    
    elseif self.vertical_align == vertical_align.CENTER then
        self.offset.y = math.ceil((self.device_size.y - self.game_size.y) * 0.5)
    
    elseif self.vertical_align == vertical_align.RIGHT then
        self.offset.y = self.device_size.y - self.game_size.y
    end
end

return base_scale_mode