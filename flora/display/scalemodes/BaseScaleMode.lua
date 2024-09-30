---
--- @class flora.display.scalemodes.BaseScaleMode
---
local BaseScaleMode = Class:extend("BaseScaleMode", ...)

function BaseScaleMode:constructor()
    ---
    --- @type flora.math.Vector2
    ---
    self.deviceSize = Vector2:new()

    ---
    --- @type flora.math.Vector2
    ---
    self.gameSize = Vector2:new()

    ---
    --- @type flora.math.Vector2
    ---
    self.scale = Vector2:new()

    ---
    --- @type flora.math.Vector2
    ---
    self.offset = Vector2:new()

    ---
    --- @type integer
    ---
    self.horizontalAlign = HorizontalAlign.CENTER

    ---
    --- @type integer
    ---
    self.verticalAlign = VerticalAlign.CENTER
end

function BaseScaleMode:onMeasure(width, height)
    self:updateGameSize(width, height)
    self:updateDeviceSize(width, height)
    self:updateScaleOffset()
end

function BaseScaleMode:updateGameSize(width, height)
    self.gameSize:set(width, height)
end

function BaseScaleMode:updateDeviceSize(width, height)
    self.deviceSize:set(width, height)
end

function BaseScaleMode:updateScaleOffset()
    self.scale.x = self.gameSize.x / flora.gameWidth
    self.scale.y = self.gameSize.y / flora.gameHeight
    self:update_offset_x()
    self:update_offset_y()
end

function BaseScaleMode:update_offset_x()
    if self.horizontalAlign == HorizontalAlign.LEFT then
        self.offset.x = 0
    
    elseif self.horizontalAlign == HorizontalAlign.CENTER then
        self.offset.x = math.ceil((self.deviceSize.x - self.gameSize.x) * 0.5)
    
    elseif self.horizontalAlign == HorizontalAlign.RIGHT then
        self.offset.x = self.deviceSize.x - self.gameSize.x
    end
end

function BaseScaleMode:update_offset_y()
    if self.verticalAlign == VerticalAlign.LEFT then
        self.offset.y = 0
    
    elseif self.verticalAlign == VerticalAlign.CENTER then
        self.offset.y = math.ceil((self.deviceSize.y - self.gameSize.y) * 0.5)
    
    elseif self.verticalAlign == VerticalAlign.RIGHT then
        self.offset.y = self.deviceSize.y - self.gameSize.y
    end
end

return BaseScaleMode