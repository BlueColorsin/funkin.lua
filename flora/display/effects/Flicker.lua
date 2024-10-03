---
--- @class flora.display.effects.Flicker
---
local Flicker = Class:extend("Flicker", ...)

---
--- @protected
--- @type flora.utils.Pool?
---
Flicker._pool = Pool:new(Flicker)

---
--- @protected
--- @type table<flora.display.Object2D, flora.display.effects.Flicker>
---
Flicker._boundObjects = {}

---
--- @param  object              flora.display.Object2D
--- @param  duration            number
--- @param  interval            number?
--- @param  endVisibility       boolean?
--- @param  forceRestart        boolean?
--- @param  completionCallback  function?
--- @param  progressCallback    function?
---
function Flicker.flicker(object, duration, interval, endVisibility, forceRestart, completionCallback, progressCallback)
    if endVisibility == nil then
        endVisibility = true
    end
    if forceRestart == nil then
        forceRestart = true
    end
    if Flicker.isFlickering(object) then
        if forceRestart then
            Flicker.stopFlickering(object)
        else
            return Flicker._boundObjects[object]
        end
    end
    if interval <= 0 then
        interval = Flora.deltaTime
    end
    local flicker = Flicker._pool:get()
    flicker:start(object, duration, interval, endVisibility, completionCallback, progressCallback)

    Flicker._boundObjects[object] = flicker
    return flicker
end

function Flicker.isFlickering(object)
    return Flicker._boundObjects[object] ~= nil
end

function Flicker.stopFlickering(object)
    local boundFlicker = Flicker._boundObjects[object]
    if boundFlicker then
        boundFlicker:stop()
    end
end

function Flicker:constructor()
    ---
    --- @type flora.display.Object2D
    ---
    self.object = nil

    ---
    --- @type number
    ---
    self.duration = nil

    ---
    --- @type number
    ---
    self.interval = nil

    ---
    --- @type boolean
    ---
    self.endVisibility = nil

    ---
    --- @type boolean
    ---
    self.forceRestart = nil

    ---
    --- @type function?
    ---
    self.completionCallback = nil

    ---
    --- @type function?
    ---
    self.progressCallback = nil

    ---
    --- @type flora.utils.Timer
    ---
    self.timer = nil
end

---
--- @param  object              flora.display.Object2D
--- @param  duration            number
--- @param  interval            number?
--- @param  endVisibility       boolean?
--- @param  completionCallback  function?
--- @param  progressCallback    function?
---
function Flicker:start(object, duration, interval, endVisibility, completionCallback, progressCallback)
    if endVisibility == nil then
        endVisibility = true
    end
    if not interval then
        interval = Flora.deltaTime
    end

    self.object = object
    self.duration = duration
    self.interval = interval
    self.endVisibility = endVisibility
    self.completionCallback = completionCallback
    self.progressCallback = progressCallback

    local function progFunc(tmr)
        self:_flickerProgress(tmr)
    end
    self.timer = Timer:new():start(self.interval, progFunc, math.round(self.duration / self.interval))
end

function Flicker:stop()
    self.timer:stop()
    self.object.visible = true
    self:_release()
end

---
--- @protected
---
function Flicker:_release()
    Flicker._boundObjects[self.object] = nil
    Flicker._pool:put(self)
end

---
--- @protected
--- @param  tmr  flora.utils.Timer
---
function Flicker:_flickerProgress(tmr)
    self.object.visible = not self.object.visible
    if self.progressCallback then
        self.progressCallback(self)
    end
    if tmr.loops > 0 and tmr.loopsLeft == 0 then
        self.object.visible = self.endVisibility
        if self.completionCallback then
            self.completionCallback(self)
        end
        if self.timer == tmr then
            self:_release()
        end
    end
end

return Flicker