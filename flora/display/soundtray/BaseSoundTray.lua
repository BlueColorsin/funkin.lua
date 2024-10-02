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
    if Flora.keys:anyJustPressed(self.volumeUpKeys) then
        Flora.sound.volume = math.clamp(math.truncate(Flora.sound.volume + 0.1, 1), 0.0, 1.0)
        self:show(true)
    end
    if Flora.keys:anyJustPressed(self.volumeDownKeys) then
        Flora.sound.volume = math.clamp(math.truncate(Flora.sound.volume - 0.1, 1), 0.0, 1.0)
        self:show(false)
    end
    if Flora.keys:anyJustPressed(self.volumeMuteKeys) then
        Flora.sound.muted = not Flora.sound.muted
        self:show(true)
    end
end

return BaseSoundTray