---
--- A state which can go on top of other states, typically
--- used for pause menus, inventory menus, transitions, etc.
---
--- @class flora.display.SubState : flora.display.State
---
local SubState = State:extend("SubState", ...)

function SubState:constructor()
    SubState.super.constructor(self)

    ---
    --- The function that is called when this substate
    --- is opened on-top of another state.
    --- 
    --- @type function?
    ---
    self.onOpen = nil

    ---
    --- The function that is called when this substate is closed.
    --- 
    --- @type function?
    ---
    self.onClose = nil

    ---
    --- The color displayed as the background of this substate. (default: `Color.TRANSPARENT`)
    --- 
    --- @type flora.utils.Color|integer
    ---
    self.bgColor = nil

    ---
    --- @protected
    --- @type flora.display.State
    ---
    self._parentState = nil

    ---
    --- @protected
    --- @type flora.utils.Color|integer
    ---
    self._bgColor = Color:new(Color.TRANSPARENT)
end

function SubState:close()
    if self._parentState and self._parentState.subState == self then
        self._parentState:closeSubState()
    end
end

function SubState:draw()
    for i = 1, #self.cameras do
        ---
        --- @type flora.display.Camera
        ---
        local cam = self.cameras[i]
        cam:drawRect(0, 0, cam.width, cam.height, 0, 0, 0, self.bgColor)
    end
    SubState.super.draw(self)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function SubState:get_bgColor()
    return self._bgColor
end

---
--- @protected
---
function SubState:set_bgColor(val)
    self._bgColor = Color:new(val)
    return self._bgColor
end

return SubState