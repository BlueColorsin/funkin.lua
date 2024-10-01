local KeyCode = require("flora.input.keyboard.KeyCode")

---
--- A class for managing keyboard input.
---
--- @class flora.input.keyboard.KeyboardManager
---
local KeyboardManager = Class:extend("KeyboardManager", ...)

function KeyboardManager:constructor()
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
    self.justPressed = {}

    ---
    --- A map of every key currently just released.
    ---
    self.justReleased = {}

    for key, _ in pairs(KeyCode) do
        self.pressed[key] = false
        self.released[key] = true

        self.justPressed[key] = false
        self.justReleased[key] = false
    end
end

function KeyboardManager:update()
    for key, value in pairs(self.justPressed) do
        if value then
            self.justPressed[key] = false
        end
    end
    for key, value in pairs(self.justReleased) do
        if value then
            self.justReleased[key] = false
        end
    end
end

function KeyboardManager:keyPressed(key, _, _)
    local realKey = key
    for k, value in pairs(KeyCode) do
        if value == key then
            realKey = k
        end
    end
    self.pressed[realKey] = true
    self.released[realKey] = false
    self.justPressed[realKey] = true
end

function KeyboardManager:keyReleased(key, _, _)
    local realKey = key
    for k, value in pairs(KeyCode) do
        if value == key then
            realKey = k
            break
        end
    end
    self.pressed[realKey] = false
    self.released[realKey] = true
    self.justReleased[realKey] = true
end

return KeyboardManager