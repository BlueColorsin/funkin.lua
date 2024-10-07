local TweenManager = require("flora.plugins.TweenManager")
local TimerManager = require("flora.plugins.TimerManager")

---
--- @class funkin.objects.ui.transition.BaseTransition : funkin.states.MusicBeatSubstate
---
local BaseTransition = MusicBeatSubstate:extend("BaseTransition", ...)

---
--- @param  transitionType  "in"|"out"
---
function BaseTransition:constructor(transitionType)
    BaseTransition.super.constructor(self)

    ---
    --- The transition type, used to determine whether or not
    --- we are fading from the current state or fading to the new state.
    ---
    --- @type "in"|"out"
    ---
    self.transitionType = transitionType

    ---
    --- The signal that gets emitted right before
    --- this transition completes.
    ---
    --- @type flora.utils.Signal
    ---
    self.onComplete = Signal:new():type("string")

    ---
    --- The signal that gets emitted right after
    --- this transition completes.
    ---
    --- @type flora.utils.Signal
    ---
    self.onPostComplete = Signal:new():type("string")
end

function BaseTransition:ready()
    BaseTransition.super.ready(self)

    if self.transitionType == "in" then
        local state = Flora.state
        if state:is(MusicBeatState) then
            if not state.skipTransIn then
                self:startIn()
                self:postStartIn()
            else
                self:finish()
            end
        else
            self:startIn()
            self:postStartIn()
        end

    elseif self.transitionType == "out" then
        self:startOut()
        self:postStartOut()
    end

    ---
    --- @type flora.display.Camera
    ---
    self.transitionCam = Camera:new()
    self.transitionCam.bgColor = Color.TRANSPARENT
    Flora.cameras:add(self.transitionCam)

    self.cameras = {self.transitionCam}
end

function BaseTransition:startIn()
    for i = 1, TweenManager.global.list.length do
        ---
        --- @type flora.tweens.Tween
        ---
        local tween = TweenManager.global.list.members[i]
        tween.paused = true
    end
    for i = 1, TimerManager.global.list.length do
        ---
        --- @type flora.utils.Timer
        ---
        local timer = TimerManager.global.list.members[i]
        timer.paused = true
    end
    for i = 1, Flora.cameras.list.length do
        ---
        --- @type flora.utils.Timer
        ---
        local camera = Flora.cameras.list.members[i]
        camera.active = false
    end
    Flora.state.persistentUpdate = false
    return true
end

function BaseTransition:postStartIn()
end

function BaseTransition:startOut()
    return true
end

function BaseTransition:postStartOut()
end

function BaseTransition:finish()
    self.onComplete:emit(self.transitionType)
    if self.transitionType == "in" then
        Flora.signals.postStateSwitch:connect(function()
            if Flora.state:is(MusicBeatState) then
                local state = Flora.state
                if state.skipTransOut then
                    return
                end
                state:openSubState(require(self.__path):new("out"))
            end
        end, nil, true)
        
    elseif self.transitionType == "out" then
        self:close()
    end
    self.onPostComplete:emit(self.transitionType)
end

function BaseTransition:dispose()
    Flora.cameras:remove(self.transitionCam)
    BaseTransition.super.dispose(self)
end

return BaseTransition