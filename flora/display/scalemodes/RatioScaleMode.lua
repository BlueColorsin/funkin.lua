local BaseScaleMode = require("flora.display.scalemodes.BaseScaleMode")

---
--- @class flora.display.scalemodes.RatioScaleMode : flora.display.scalemodes.BaseScaleMode
---
local RatioScaleMode = BaseScaleMode:extend("RatioScaleMode", ...)

function RatioScaleMode:constructor(fill_screen)
    RatioScaleMode.super.constructor(self, fill_screen)

    self.fill_screen = fill_screen and fill_screen or false
end

function RatioScaleMode:updateGameSize(width, height)
    local ratio = Flora.gameWidth / Flora.gameHeight
    local realRatio = width / height

    local scaleY = realRatio < ratio
    if self.fill_screen then
        scaleY = not scaleY
    end

    if scaleY then
        self.gameSize.x = width
        self.gameSize.y = math.floor(self.gameSize.x / ratio)
    else
        self.gameSize.y = height
        self.gameSize.x = math.floor(self.gameSize.y * ratio)
    end
end

return RatioScaleMode