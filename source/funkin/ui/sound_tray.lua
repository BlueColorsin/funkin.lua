local base_sound_tray = require("flora.display.sound_tray.base_sound_tray")

---
--- @class funkin.ui.sound_tray : flora.display.sound_tray.base_sound_tray
---
local sound_tray = base_sound_tray:extend()

function sound_tray:constructor()
    sound_tray.super.constructor(self)
    
    self.box = love.graphics.newImage(paths.image("volumebox", "images/volume"))
    self.box:setFilter("linear", "linear")
    
    self.alpha = 0.0

    ---
    --- @type flora.math.vector2
    ---
    self.scale = vector2:new(0.6, 0.6)

    self.width = self.box:getWidth() * self.scale.x
    self.height = self.box:getHeight() * self.scale.y

    self.y = -(self.height + 10)

    self.offset_x = 0.0
    self.offset_y = 0.0

    self._timer = math.huge
    self._shake_mult = 0.0

    self.bars = {
        love.graphics.newImage(paths.image("bars_1", "images/volume")),
        love.graphics.newImage(paths.image("bars_2", "images/volume")),
        love.graphics.newImage(paths.image("bars_3", "images/volume")),
        love.graphics.newImage(paths.image("bars_4", "images/volume")),
        love.graphics.newImage(paths.image("bars_5", "images/volume")),
        love.graphics.newImage(paths.image("bars_6", "images/volume")),
        love.graphics.newImage(paths.image("bars_7", "images/volume")),
        love.graphics.newImage(paths.image("bars_8", "images/volume")),
        love.graphics.newImage(paths.image("bars_9", "images/volume")),
        love.graphics.newImage(paths.image("bars_10", "images/volume")),
    }
    for i = 1, #self.bars do
        ---
        --- @type love.Image
        ---
        local bar = self.bars[i]
        bar:setFilter("linear", "linear")
    end
    self.anims = {
        adjust = {
            fps = 18,
            frames = {
                vector2:new(0.62, 0.58),
                vector2:new(0.6, 0.6),
            }
        }
    }
    self.cur_anim = "adjust"
    self.cur_frame = #self.anims[self.cur_anim].frames

    self._elapsed_anim_time = 0.0
end

function sound_tray:show(up)
    self.visible = true
    self._timer = 0.0

    if not (up and flora.sound.volume >= 1.0) then
        self.cur_anim = "adjust"
        self.cur_frame = 1
    
        self._elapsed_anim_time = 0.0
    end
    if up then
        if flora.sound.volume >= 1.0 then
            self._shake_mult = 1.0
            flora.sound:play("assets/sounds/volume/max.ogg")
        else
            flora.sound:play("assets/sounds/volume/up.ogg")
        end
    else
        flora.sound:play("assets/sounds/volume/down.ogg")
    end
    sound_tray.super.show(self, up)
end

function sound_tray:update(dt)
    local cur_anim = self.anims[self.cur_anim]
    self.scale:set(
        cur_anim.frames[self.cur_frame].x,
        cur_anim.frames[self.cur_frame].y
    )
    self.width = self.box:getWidth() * self.scale.x
    self.height = self.box:getHeight() * self.scale.y

    self._timer = self._timer + dt

    if self._timer > 1.5 then
        self.y = math.lerp(self.y, -(self.height + 10), dt * 15.0)
        self.alpha = math.lerp(self.alpha, 0.0, dt * 30.0)

        if self.y <= -self.height then
            self.visible = false
        end
    else
        self.y = math.lerp(self.y, 20, dt * 15.0)
        self.alpha = math.lerp(self.alpha, 1.0, dt * 15.0)
    end
    
    local ww = love.graphics.getWidth()
    self.x = ((ww - self.width) * 0.5)

    self.offset_x = (math.random(-2.0, 2.0) * self._shake_mult)
    self.offset_y = (math.random(-2.0, 2.0) * self._shake_mult)
    
    self._shake_mult = math.max(self._shake_mult - (dt * 3), 0)
    self._elapsed_anim_time = self._elapsed_anim_time + dt

    if self._elapsed_anim_time >= (1.0 / cur_anim.fps) then
        self.cur_frame = math.min(self.cur_frame + 1, #cur_anim.frames)
        self._elapsed_anim_time = 0.0
    end
    sound_tray.super.update(self, dt)
end

function sound_tray:draw()
    local pr, pg, pb, pa = love.graphics.getColor()

    love.graphics.setColor(1, 1, 1, 1 * self.alpha)
    love.graphics.draw(self.box, self.x + self.offset_x, self.y + self.offset_y, 0, self.scale.x, self.scale.y)

    local bar_x = self.x + (28 * self.scale.x) + self.offset_x
    local bar_y = self.y + (16 * self.scale.y) + self.offset_y
    local bar_count = #self.bars

    love.graphics.setColor(1, 1, 1, 0.5 * self.alpha)
    love.graphics.draw(self.bars[bar_count], bar_x, bar_y, 0, self.scale.x, self.scale.y)
    
    love.graphics.setColor(1, 1, 1, 1 * self.alpha)

    local vol = flora.sound.volume
    if vol > 0 and not flora.sound.muted then
        love.graphics.draw(self.bars[math.floor(vol * bar_count)], bar_x, bar_y, 0, self.scale.x, self.scale.y)
    end
    love.graphics.setColor(pr, pg, pb, pa)
end

function sound_tray:dispose()
    sound_tray.super.dispose(self)

    if self.image then
        self.image:release()
    end
    for i = 1, #self.bars do
        ---
        --- @type love.Image
        ---
        local bar = self.bars[i]
        bar:release()
    end
end

return sound_tray