---
--- @class flora.display.sound_tray.base_sound_tray : flora.display.object2d
---
local base_sound_tray = object2d:extend()

function base_sound_tray:constructor()
    base_sound_tray.super.constructor(self)

    self.volume_up_keys = {keycode.equals, keycode.numpad_plus}
    self.volume_down_keys = {keycode.minus, keycode.numpad_minus}
    self.volume_mute_keys = {keycode.zero, keycode.numpad_0}
end

function base_sound_tray:show(up)
    flora.save.data.volume = flora.sound.volume
    flora.save.data.muted = flora.sound.muted
    flora.save:flush()
end

function base_sound_tray:update(dt)
    for i = 1, #self.volume_up_keys do
        local key = self.volume_up_keys[i]
        if flora.keys.just_pressed[key] then
            flora.sound.volume = math.clamp(math.truncate(flora.sound.volume + 0.1, 1), 0.0, 1.0)
            self:show(true)
        end
    end
    for i = 1, #self.volume_down_keys do
        local key = self.volume_down_keys[i]
        if flora.keys.just_pressed[key] then
            flora.sound.volume = math.clamp(math.truncate(flora.sound.volume - 0.1, 1), 0.0, 1.0)
            self:show(false)
        end
    end
    for i = 1, #self.volume_mute_keys do
        local key = self.volume_mute_keys[i]
        if flora.keys.just_pressed[key] then
            flora.sound.muted = not flora.sound.muted
            self:show(true)
        end
    end
end

return base_sound_tray