local BaseSoundTray = require("flora.display.soundtray.BaseSoundTray")

---
--- @class flora.display.soundtray.DefaultSoundTray : flora.display.soundtray.BaseSoundTray
---
local DefaultSoundTray = BaseSoundTray:extend("DefaultSoundTray", ...)

function DefaultSoundTray:constructor()
    DefaultSoundTray.super.constructor(self)

    self.color = Color:new(Color.BLACK)
    self.color.a = 0.6

    self.width = 200
    self.height = 30
    
    self.y = -self.height
    self._timer = 0.0

    self.icons = {
        love.graphics.newImage("flora/embed/images/volume/muted.png"),
        love.graphics.newImage("flora/embed/images/volume/none.png"),
        love.graphics.newImage("flora/embed/images/volume/half.png"),
        love.graphics.newImage("flora/embed/images/volume/full.png"),
    }
    self.curIcon = 4
end

function DefaultSoundTray:show(up)
    self.y = 10
    self.visible = true

    self._timer = 0.0

    flora.sound:play("flora/embed/sounds/pop.ogg")
    DefaultSoundTray.super.show(self, up)
end

function DefaultSoundTray:update(dt)
    DefaultSoundTray.super.update(self, dt)

    self._timer = self._timer + dt
    if self._timer > 1.0 then
        self.y = math.max(self.y - (dt * 200), -self.height)
        if self.y <= -self.height then
            self.visible = false
        end
    end

    local ww = love.graphics.getWidth()
    self.x = (ww - self.width) * 0.5
end

function DefaultSoundTray:draw()
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.draw(self.icons[self.curIcon], self.x + 5, self.y + 3)

    local barX = self.x + 35
    local barY = self.y + 10

    local barWidth = self.width - 45
    local barHeight = self.height - 20
    
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    if flora.sound.volume > 0 and not flora.sound.muted then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", barX, barY, barWidth * flora.sound.volume, barHeight)
    end
    love.graphics.setColor(pr, pg, pb, pa)
end

function DefaultSoundTray:dispose()
    DefaultSoundTray.super.dispose(self)

    for i = 1, #self.icons do
        ---
        --- @type love.Image
        ---
        local icon = self.icons[i]
        icon:release()
    end
end

return DefaultSoundTray