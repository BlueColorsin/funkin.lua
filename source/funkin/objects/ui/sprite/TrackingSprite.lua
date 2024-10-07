---
--- @type funkin.objects.ui.sprite.TrackingMode
---
local TrackingMode = Flora.import("funkin.objects.ui.sprite.TrackingMode")

---
--- @class funkin.objects.ui.sprite.TrackingSprite : flora.display.Sprite
---
local TrackingSprite = Sprite:extend("TrackingSprite", ...)

function TrackingSprite:constructor(x, y, texture)
    TrackingSprite.super.constructor(self, x, y, texture)

    ---
    --- The offset in X and Y to the tracked object.
    ---
    --- @type flora.math.Vector2
    ---
    self.trackingOffset = Vector2:new(10.0, -30.0)

    ---
    --- The object / sprite we are tracking.
    ---
    --- @type flora.display.Object2D?
    ---
    self.tracked = nil

    ---
    --- Tracking mode (or direction) of this sprite.
    ---
    --- @type funkin.objects.ui.sprite.TrackingMode
    ---
    self.trackingMode = "right"

    ---
    --- Whether or not to copy the alpha from
	--- the sprite being tracked.
    ---
    --- @type boolean
    ---
    self.copyAlpha = true

    ---
    --- Whether or not to copy the visibility from
	--- the sprite being tracked.
    ---
    --- @type boolean
    ---
    self.copyVisibility = true
end

function TrackingSprite:update(dt)
    if self.tracked then
        if self.trackingMode == "right" then
            self:setPosition(self.tracked.x + self.tracked.width + self.trackingOffset.x, self.tracked.y + self.trackingOffset.y)
        
        elseif self.trackingMode == "left" then
            self:setPosition(self.tracked.x + self.trackingOffset.x, self.tracked.y + self.trackingOffset.y)
        
        elseif self.trackingMode == "up" then
            self:setPosition(self.tracked.x + (self.tracked.width * 0.5) + self.trackingOffset.x, self.tracked.y - self.height + self.trackingOffset.y)
        
        elseif self.trackingMode == "down" then
            self:setPosition(self.tracked.x + (self.tracked.width * 0.5) + self.trackingOffset.x, self.tracked.y + self.tracked.height + self.trackingOffset.y)
        end
        if self.copyAlpha and self.tracked:is(Sprite) then
            self.alpha = self.tracked.alpha
        end
        if self.copyVisibility and self.tracked:is(Sprite) then
            self.visible = self.tracked.visible
        end
    end
    TrackingSprite.super.update(self, dt)
end

return TrackingSprite