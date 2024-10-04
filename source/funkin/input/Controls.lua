local InputState = require("flora.input.InputState")

---
--- @type funkin.input.InputAction
---
local InputAction = Flora.import("funkin.input.InputAction")

---
--- @class funkin.input.Controls
---
local Controls = {}

function Controls.init()
    ---
    --- @type flora.utils.Save
    ---
    Controls._save = Save:new()
    Controls._save:bind("controls")

    Controls.list = {
        -- Gameplay Bindings
        NOTE_LEFT  = InputAction:new("note_left",  {KeyCode.A, KeyCode.LEFT}),
        NOTE_DOWN  = InputAction:new("note_down",  {KeyCode.S, KeyCode.DOWN}),
        NOTE_UP    = InputAction:new("note_up",    {KeyCode.W, KeyCode.UP}),
        NOTE_RIGHT = InputAction:new("note_right", {KeyCode.D, KeyCode.RIGHT}),

        -- UI Bindings
        UI_LEFT  = InputAction:new("ui_left",  {KeyCode.A, KeyCode.LEFT}),
        UI_DOWN  = InputAction:new("ui_down",  {KeyCode.S, KeyCode.DOWN}),
        UI_UP    = InputAction:new("ui_up",    {KeyCode.W, KeyCode.UP}),
        UI_RIGHT = InputAction:new("ui_right", {KeyCode.D, KeyCode.RIGHT}),

        RESET    = InputAction:new("reset", {KeyCode.R, KeyCode.NONE}),
        ACCEPT   = InputAction:new("accept", {KeyCode.ENTER, KeyCode.SPACE}),
        BACK     = InputAction:new("back",   {KeyCode.ESCAPE, KeyCode.BACKSPACE}),
        PAUSE    = InputAction:new("pause", {KeyCode.ENTER, KeyCode.ESCAPE}),

        -- Window Bindings
        SCREENSHOT = InputAction:new("screenshot", {KeyCode.F3, KeyCode.NONE}),
        FULLSCREEN = InputAction:new("fullscreen", {KeyCode.F11, KeyCode.NONE}),

        -- Volume Bindings
        VOLUME_UP = InputAction:new("volume_up", {KeyCode.EQUALS, KeyCode.NUMPAD_PLUS}),
        VOLUME_DOWN = InputAction:new("volume_down", {KeyCode.MINUS, KeyCode.NUMPAD_MINUS}),
        VOLUME_MUTE = InputAction:new("volume_mute", {KeyCode.ZERO, KeyCode.NUMPAD_0}),

        -- Debug Bindings
        EDITORS = InputAction:new("editors", {KeyCode.EIGHT, KeyCode.NUMPAD_8}),
        CHARTER = InputAction:new("charter", {KeyCode.SEVEN, KeyCode.NUMPAD_7}),
        SWITCH_MOD = InputAction:new("switch_mod", {KeyCode.TAB, KeyCode.NONE}),
    }
    ---
    --- Helpful dot syntax for checking if an action was just pressed.
    ---
    Controls.justPressed = {
        NOTE_LEFT  = nil,
        NOTE_DOWN  = nil,
        NOTE_UP    = nil,
        NOTE_RIGHT = nil,
        UI_LEFT  = nil,
        UI_DOWN  = nil,
        UI_UP    = nil,
        UI_RIGHT = nil,
        RESET    = nil,
        ACCEPT   = nil,
        BACK     = nil,
        PAUSE    = nil,
        SCREENSHOT = nil,
        FULLSCREEN = nil,
        VOLUME_UP = nil,
        VOLUME_DOWN = nil,
        VOLUME_MUTE = nil,
        EDITORS = nil,
        CHARTER = nil,
        SWITCH_MOD = nil,
    }

    ---
    --- Helpful dot syntax for checking if an action is pressed.
    ---
    Controls.pressed = {
        NOTE_LEFT  = nil,
        NOTE_DOWN  = nil,
        NOTE_UP    = nil,
        NOTE_RIGHT = nil,
        UI_LEFT  = nil,
        UI_DOWN  = nil,
        UI_UP    = nil,
        UI_RIGHT = nil,
        RESET    = nil,
        ACCEPT   = nil,
        BACK     = nil,
        PAUSE    = nil,
        SCREENSHOT = nil,
        FULLSCREEN = nil,
        VOLUME_UP = nil,
        VOLUME_DOWN = nil,
        VOLUME_MUTE = nil,
        EDITORS = nil,
        CHARTER = nil,
        SWITCH_MOD = nil,
    }

    ---
    --- Helpful dot syntax for checking if an action was just released.
    ---
    Controls.justReleased = {
        NOTE_LEFT  = nil,
        NOTE_DOWN  = nil,
        NOTE_UP    = nil,
        NOTE_RIGHT = nil,
        UI_LEFT  = nil,
        UI_DOWN  = nil,
        UI_UP    = nil,
        UI_RIGHT = nil,
        RESET    = nil,
        ACCEPT   = nil,
        BACK     = nil,
        PAUSE    = nil,
        SCREENSHOT = nil,
        FULLSCREEN = nil,
        VOLUME_UP = nil,
        VOLUME_DOWN = nil,
        VOLUME_MUTE = nil,
        EDITORS = nil,
        CHARTER = nil,
        SWITCH_MOD = nil,
    }

    ---
    --- Helpful dot syntax for checking if an action is released.
    ---
    Controls.released = {
        NOTE_LEFT  = nil,
        NOTE_DOWN  = nil,
        NOTE_UP    = nil,
        NOTE_RIGHT = nil,
        UI_LEFT  = nil,
        UI_DOWN  = nil,
        UI_UP    = nil,
        UI_RIGHT = nil,
        RESET    = nil,
        ACCEPT   = nil,
        BACK     = nil,
        PAUSE    = nil,
        SCREENSHOT = nil,
        FULLSCREEN = nil,
        VOLUME_UP = nil,
        VOLUME_DOWN = nil,
        VOLUME_MUTE = nil,
        EDITORS = nil,
        CHARTER = nil,
        SWITCH_MOD = nil,
    }

    setmetatable(Controls.justPressed, {
        __index = function(_, control)
            ---
            --- @type funkin.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.JUST_PRESSED)
        end
    })
    setmetatable(Controls.pressed, {
        __index = function(_, control)
            ---
            --- @type funkin.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.PRESSED)
        end
    })
    setmetatable(Controls.justReleased, {
        __index = function(_, control)
            ---
            --- @type funkin.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.JUST_RELEASED)
        end
    })
    setmetatable(Controls.released, {
        __index = function(_, control)
            ---
            --- @type funkin.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.RELEASED)
        end
    })
end

return Controls