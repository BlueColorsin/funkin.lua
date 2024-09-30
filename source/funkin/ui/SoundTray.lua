local BaseSoundTray = require("flora.display.soundtray.BaseSoundTray")

---
--- @class funkin.ui.SoundTray : flora.display.soundtray.BaseSoundTray
---
local SoundTray = BaseSoundTray:extend("SoundTray", ...)

function SoundTray:constructor()
    SoundTray.super.constructor(self)
    
    self.box = love.graphics.newImage(Paths.image("volumebox", "images/volume"))
    self.box:setFilter("linear", "linear")
    
    self.alpha = 0.0

    ---
    --- @type flora.math.Vector2
    ---
    self.scale = Vector2:new(0.6, 0.6)

    self.width = self.box:getWidth() * self.scale.x
    self.height = self.box:getHeight() * self.scale.y

    self.y = -(self.height + 10)

    self.offsetX = 0.0
    self.offsetY = 0.0

    self._timer = math.huge
    self._shakeMult = 0.0

    self.bars = {
        love.graphics.newImage(Paths.image("bars_1", "images/volume")),
        love.graphics.newImage(Paths.image("bars_2", "images/volume")),
        love.graphics.newImage(Paths.image("bars_3", "images/volume")),
        love.graphics.newImage(Paths.image("bars_4", "images/volume")),
        love.graphics.newImage(Paths.image("bars_5", "images/volume")),
        love.graphics.newImage(Paths.image("bars_6", "images/volume")),
        love.graphics.newImage(Paths.image("bars_7", "images/volume")),
        love.graphics.newImage(Paths.image("bars_8", "images/volume")),
        love.graphics.newImage(Paths.image("bars_9", "images/volume")),
        love.graphics.newImage(Paths.image("bars_10", "images/volume")),
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
                Vector2:new(0.62, 0.58),
                Vector2:new(0.6, 0.6),
            }
        }
    }
    self.curAnim = "adjust"
    self.curFrame = #self.anims[self.curAnim].frames

    self._elapsedAnimTime = 0.0
end

function SoundTray:show(up)
    self.visible = true
    self._timer = 0.0

    if not (up and flora.sound.volume >= 1.0) then
        self.curAnim = "adjust"
        self.curFrame = 1

        self._elapsedAnimTime = 0.0
    end
    if up then
        if flora.sound.volume >= 1.0 then
            self._shakeMult = 1.0
            flora.sound:play("assets/sounds/volume/max.ogg")
        else
            flora.sound:play("assets/sounds/volume/up.ogg")
        end
    else
        flora.sound:play("assets/sounds/volume/down.ogg")
    end
    SoundTray.super.show(self, up)
end

function SoundTray:update(dt)
    local curAnim = self.anims[self.curAnim]
    self.scale:set(
        curAnim.frames[self.curFrame].x,
        curAnim.frames[self.curFrame].y
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

    self.offsetX = (math.random(-2.0, 2.0) * self._shakeMult)
    self.offsetY = (math.random(-2.0, 2.0) * self._shakeMult)
    
    self._shakeMult = math.max(self._shakeMult - (dt * 3), 0)
    self._elapsedAnimTime = self._elapsedAnimTime + dt

    if self._elapsedAnimTime >= (1.0 / curAnim.fps) then
        self.curFrame = math.min(self.curFrame + 1, #curAnim.frames)
        self._elapsedAnimTime = 0.0
    end
    SoundTray.super.update(self, dt)
end

function SoundTray:draw()
    local pr, pg, pb, pa = love.graphics.getColor()

    love.graphics.setColor(1, 1, 1, 1 * self.alpha)
    love.graphics.draw(self.box, self.x + self.offsetX, self.y + self.offsetY, 0, self.scale.x, self.scale.y)

    local bar_x = self.x + (28 * self.scale.x) + self.offsetX
    local bar_y = self.y + (16 * self.scale.y) + self.offsetY
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

function SoundTray:dispose()
    SoundTray.super.dispose(self)

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

return SoundTray