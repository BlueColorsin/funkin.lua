local keycode = require("flora.input.keyboard.keycode")

---
--- A class for managing keyboard input.
---
--- @class flora.input.keyboard.keyboard_manager
---
local keyboard_manager = class:extend("keyboard_manager", ...)

function keyboard_manager:constructor()
    ---
    --- A map of every key currently pressed.
    ---
    self.pressed = {}

    ---
    --- A map of every key currently released.
    ---
    self.released = {}

    ---
    --- A map of every key currently just pressed.
    ---
    self.just_pressed = {}

    ---
    --- A map of every key currently just released.
    ---
    self.just_released = {}

    for key, _ in pairs(keycode) do
        self.pressed[key] = false
        self.released[key] = true

        self.just_pressed[key] = false
        self.just_released[key] = false
    end
end

function keyboard_manager:update()
    for key, value in pairs(self.just_pressed) do
        if value then
            self.just_pressed[key] = false
        end
    end
    for key, value in pairs(self.just_released) do
        if value then
            self.just_released[key] = false
        end
    end
end

function keyboard_manager:key_pressed(key, _, _)
    self.pressed[key] = true
    self.released[key] = false

    self.just_pressed[key] = true
end

function keyboard_manager:key_released(key, _, _)
    self.pressed[key] = false
    self.released[key] = true

    self.just_released[key] = true
end

return keyboard_manager