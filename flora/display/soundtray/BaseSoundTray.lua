---
--- @class flora.display.soundtray.BaseSoundTray : flora.display.Object2D
---
local BaseSoundTray = Object2D:extend("BaseSoundTray", ...)

function BaseSoundTray:constructor()
    BaseSoundTray.super.constructor(self)

    self.volumeUpKeys = {KeyCode.EQUALS, KeyCode.NUMPAD_PLUS}
    self.volumeDownKeys = {KeyCode.MINUS, KeyCode.NUMPAD_MINUS}
    self.volumeMuteKeys = {KeyCode.ZERO, KeyCode.NUMPAD_0}
end

function BaseSoundTray:show(up)
    Flora.save.data.volume = Flora.sound.volume
    Flora.save.data.muted = Flora.sound.muted
    Flora.save:flush()
end

function BaseSoundTray:update(dt)
    for i = 1, #self.volumeUpKeys do
        local key = self.volumeUpKeys[i]
        if Flora.keys.justPressed[key] then
            Flora.sound.volume = math.clamp(math.truncate(Flora.sound.volume + 0.1, 1), 0.0, 1.0)
            self:show(true)
        end
    end
    for i = 1, #self.volumeDownKeys do
        local key = self.volumeDownKeys[i]
        if Flora.keys.justPressed[key] then
            Flora.sound.volume = math.clamp(math.truncate(Flora.sound.volume - 0.1, 1), 0.0, 1.0)
            self:show(false)
        end
    end
    for i = 1, #self.volumeMuteKeys do
        local key = self.volumeMuteKeys[i]
        if Flora.keys.justPressed[key] then
            Flora.sound.muted = not Flora.sound.muted
            self:show(true)
        end
    end
end

return BaseSoundTray