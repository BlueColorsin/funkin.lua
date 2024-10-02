---
--- @enum flora.input.InputState
---
local InputState = {
    NONE = 0,
    PRESSED = 1,
    JUST_PRESSED = 2,
    RELEASED = 4,
    JUST_RELEASED = 8,
}
return InputState