local base_sound_tray = require("flora.display.sound_tray.base_sound_tray")

---
--- @class flora.display.sound_tray.default_sound_tray : flora.display.sound_tray.base_sound_tray
---
local default_sound_tray = base_sound_tray:extend("default_sound_tray", ...)

function default_sound_tray:constructor()
    default_sound_tray.super.constructor(self)

    self.color = color:new(color.black)
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
    self.cur_icon = 4
end

function default_sound_tray:show(up)
    self.y = 10
    self.visible = true

    self._timer = 0.0

    flora.sound:play("flora/embed/sounds/pop.ogg")
    default_sound_tray.super.show(self, up)
end

function default_sound_tray:update(dt)
    default_sound_tray.super.update(self, dt)

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

function default_sound_tray:draw()
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.draw(self.icons[self.cur_icon], self.x + 5, self.y + 3)

    local bar_x = self.x + 35
    local bar_y = self.y + 10

    local bar_width = self.width - 45
    local bar_height = self.height - 20
    
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_width, bar_height)

    if flora.sound.volume > 0 and not flora.sound.muted then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", bar_x, bar_y, bar_width * flora.sound.volume, bar_height)
    end
    love.graphics.setColor(pr, pg, pb, pa)
end

function default_sound_tray:dispose()
    default_sound_tray.super.dispose(self)

    for i = 1, #self.icons do
        ---
        --- @type love.Image
        ---
        local icon = self.icons[i]
        icon:release()
    end
end

return default_sound_tray