---@diagnostic disable: invisible
--- 
--- A class with functionality similar to a `Group`, but
--- designed to be a primary scene/state of sorts.
--- 
--- @class flora.display.State : flora.display.Group
--- 
local State = Group:extend("State", ...)

function State:constructor()
    State.super.constructor(self)

    ---
    --- @type flora.display.SubState
    ---
    self.subState = nil

    ---
    --- Controls whether or not this state is allowed
    --- to keep updating even if a substate is opened on it.
    --- 
    --- @type boolean
    ---
    self.persistentUpdate = false

    ---
    --- Controls whether or not this state is allowed
    --- to keep drawing even if a substate is opened on it.
    --- 
    --- @type boolean
    ---
    self.persistentDraw = true

    ---
    --- Controls whether or not substates will be disposed
    --- upon being closed. Turning this off could reduce state
    --- creation times, at the cost of memory usage.
    ---
    self.disposeSubStates = true

    ---
    --- The signal that gets emitted when a substate is opened.
    ---
    --- @type flora.utils.Signal
    ---
    self.subStateOpened = Signal:new():type(SubState)

    ---
    --- The signal that gets emitted when a substate is closed.
    ---
    --- @type flora.utils.Signal
    ---
    self.subStateClosed = Signal:new():type(SubState)

    ---
    --- @protected
    --- @type boolean
    ---
    self._requestSubStateReset = false

    ---
    --- @protected
    --- @type flora.display.SubState
    ---
    self._requestedSubState = nil
end

---
--- The function that gets called when this scene
--- is done initializing internal Flora stuff.
--- 
--- Initialize your stuff here, instead of in the constructor!
---
function State:ready()
end

---
--- @param  subState  flora.display.SubState
---
function State:openSubState(subState)
    self._requestSubStateReset = true
    self._requestedSubState = subState
end

function State:closeSubState()
    self._requestSubStateReset = true
    self._requestedSubState = nil
end

function State:tryUpdate(dt)
    if self.persistentUpdate or not self.subState then
        self:update(dt)
    end
    if self._requestSubStateReset then
        self._requestSubStateReset = false
        self:_resetSubState()
    end
    if self.subState then
        self.subState:tryUpdate(dt)
    end
end

function State:draw()
    if self.persistentDraw or not self.subState then
        State.super.draw(self)
    end
    if self.subState then
        self.subState:draw()
    end
end

function State:startOutro(onOutroComplete)
    if onOutroComplete then
        onOutroComplete()
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function State:_resetSubState()
    if self.subState then
        if self.subState.onClose then
            self.subState.onClose()
        end
        self.subStateClosed:emit(self.subState)
        if self.disposeSubStates then
            self.subState:dispose()
        end
    end

    self.subState = self._requestedSubState
    self._requestedSubState = nil

    if self.subState then
        if not self.persistentUpdate then
            Flora.keys:onStateSwitch()
            Flora.mouse:onStateSwitch()
        end
        self.subState._parentState = self
        self.subState:ready()

        if self.subState.onOpen then
            self.subState.onOpen()
        end
        self.subStateOpened:emit(self.subState)
    end
end

return State