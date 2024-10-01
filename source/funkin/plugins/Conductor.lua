---
--- @class funkin.plugins.Conductor : flora.base.Basic
---
local Conductor = Basic:extend("Conductor", ...)

---
--- The main global instance of the Conductor.
---
--- @type funkin.plugins.Conductor
---
Conductor.instance = nil

Conductor.judgeScales = {
    J1 = 1.5,
    J2 = 1.33,
    J3 = 1.16,
    J4 = 1.0,
    J5 = 0.84,
    J6 = 0.66,
    J7 = 0.5,
    J8 = 0.33,
    JUSTICE = 0.2,
}

function Conductor.timeSignatureFromString(str)
    local split = string.split(str, "/")
    return {tonumber(split[1]), tonumber(split[2])}
end

function Conductor:constructor()
    Conductor.super.constructor(self)

    self.visible = false

    ---
    --- @type flora.utils.Signal
    ---
    self.stepHit = Signal:new():type("number", "void")

    ---
    --- @type flora.utils.Signal
    ---
    self.beatHit = Signal:new():type("number", "void")

    ---
    --- @type flora.utils.Signal
    ---
    self.measureHit = Signal:new():type("number", "void")

    ---
    --- @type boolean
    ---
    self.hasMetronome = false

    ---
    --- @type flora.Sound?
    ---
    self.music = nil

    ---
    --- @type number
    ---
    self.bpm = 100.0

    ---
    --- @type table
    ---
    self.bpmChanges = {
        {
            step = 0,
            time = 0.0,
            bpm = 100.0
        }
    }

    ---
    --- @type table<number>
    ---
    self.timeSignature = {4, 4}
    -- ^^ - 1st num is beats per measure, 2nd num is steps per beat

    ---
    --- @type number
    ---
    self.crotchet = nil

    ---
    --- @type number
    ---
    self.stepCrotchet = nil

    ---
    --- @type number
    ---
    self.safeZoneOffset = Settings.data.hitWindow / 1000.0

    ---
    --- @type boolean
    ---
    self.allowSongOffset = true

    ---
    --- @type number
    ---
    self.rawTime = 0.0

    ---
    --- @type number
    ---
    self.time = nil

    ---
    --- @type integer
    ---
    self.lastStep = 0

    ---
    --- @type integer
    ---
    self.lastBeat = 0

    ---
    --- @type integer
    ---
    self.lastMeasure = 0

    ---
    --- @type number
    ---
    self.stepf = 0.0

    ---
    --- @type integer
    ---
    self.step = 0

    ---
    --- @type number
    ---
    self.beatf = 0.0

    ---
    --- @type integer
    ---
    self.beat = 0

    ---
    --- @type number
    ---
    self.measuref = 0.0

    ---
    --- @type integer
    ---
    self.measure = 0

    ---
    --- @protected
    --- @type table
    ---
    self._lastBPMChange = self.bpmChanges[1]
end

function Conductor:reset(bpm)
    self.time = 0.0

    self.measuref = 0.0
    self.measure = 0

    self.beatf = 0.0
    self.beat = 0

    self.stepf = 0.0
    self.step = 0

    self.timeSignature = {4, 4}
    self.bpmChanges = {
        {
            step = 0,
            time = 0.0,
            bpm = bpm
        }
    }
    self.bpm = bpm
end

function Conductor:setupFromMap(map)
    self:reset()
    self.timeSignature = Conductor.timeSignatureFromString(map.meta.timeSignature)

    self.bpm = map.meta.bpm
    self:setupBPMChanges(map)
end

function Conductor:setupBPMChanges(map)
    self.bpmChanges = {
        {
            time = 0.0,
            step = 0,
            bpm = map.meta.bpm
        }
    }
    if not map.events or #map.events == 0 then
        return
    end
    local timeSig = Conductor.timeSignatureFromString(map.meta.timeSignature)

    local curBPM = 0.0
    local time = 0.0
    local lastStep = 0.0

    for i = 1, #map.events do
        local event = map.events[i]
        if event.type == "BPM Change" and event.params and type(event.params.bpm) == "number" then
            local eventBPM = event.params.bpm
            if eventBPM ~= curBPM then
                time = time + (event.step - lastStep) * ((60 / curBPM) / timeSig[2])
                curBPM = eventBPM

                table.insert(self.bpmChanges, {
                    time = time,
                    step = event.step,
                    bpm = curBPM
                })
                lastStep = event.step
            end
        end
    end
end

function Conductor:stepToTime(step)
    local lastChange = self.bpmChanges[1]

    for i = 2, #self.bpmChanges do
        local change = self.bpmChanges[i]

        if self.rawTime >= change.time then
            lastChange = change
        end
    end

    return lastChange.time + ((step - lastChange.time) * ((60 / lastChange.bpm) * self.timeSignature[2]))
end

function Conductor:beatToTime(beat)
    return self:stepToTime(beat * self.timeSignature[2])
end

function Conductor:measureToTime(measure)
    return self:beatToTime(measure * self.timeSignature[1])
end

function Conductor:timeToStep(time)
    local lastChange = self.bpmChanges[1]

    for i = 2, #self.bpmChanges do
        local change = self.bpmChanges[i]

        if time >= change.time then
            lastChange = change
        end
    end

    return lastChange.step + ((time - lastChange.time) / ((60 / lastChange.bpm) * self.timeSignature[2]))
end

function Conductor:timeToBeat(time)
    return self:timeToStep(time) / self.timeSignature[2]
end

function Conductor:timeToMeasure(time)
    return self:timeToBeat(time) / self.timeSignature[1]
end

function Conductor:update(dt)
    if self.music and self.music.playing then
        if math.abs(self.rawTime - self.music.time) > 0.02 then
            self.rawTime = self.music.time 
        end
    end
    self._lastBPMChange = self.bpmChanges[1]
    for i = 2, #self.bpmChanges do
        local change = self.bpmChanges[i]

        if self.time >= change.time then
            lastChange = change
        end
    end
    if self._lastBPMChange.bpm > 0 and self.bpm ~= self._lastBPMChange.bpm then
        self.bpm = self._lastBPMChange.bpm
    end

    local runStep = self:_updateStep(((self.time - self._lastBPMChange.time) / self.stepCrotchet) + self._lastBPMChange.step)
    if runStep then
        if math.abs(self.lastStep - self.step) > 1 then
            for i = self.lastStep, self.step do
                self.stepHit:emit(i)
            end
        else
            self.stepHit:emit(self.step)
        end
    end
    local runBeat = self:_updateBeat(self.stepf / self.timeSignature[2])
    if runStep and runBeat then
        if math.abs(self.lastBeat - self.beat) > 1 then
            for i = self.lastBeat, self.beat do
                self.beatHit:emit(i)
            end
        else
            self.beatHit:emit(self.beat)
        end
        if self.hasMetronome then
            Flora.sound:play(Paths.sound("metronome"))
        end
    end
    local runMeasure = self:_updateMeasure(self.beatf / self.timeSignature[1])
    if runStep and runMeasure then
        if math.abs(self.lastMeasure - self.measure) > 1 then
            for i = self.lastMeasure, self.measure do
                self.measureHit:emit(i)
            end
        else
            self.measureHit:emit(self.measure)
        end
    end
    local state = Flora.state
    while state do
        if not state.subState or state.persistentUpdate then
            if runStep and state.stepHit then
                if math.abs(self.lastStep - self.step) > 1 then
                    for i = self.lastStep, self.step do
                        state:stepHit(i)
                    end
                else
                    state:stepHit(self.step)
                end
            end
            if runStep and runBeat and state.beatHit then
                if math.abs(self.lastBeat - self.beat) > 1 then
                    for i = self.lastBeat, self.beat do
                        state:beatHit(i)
                    end
                else
                    state:beatHit(self.beat)
                end
            end
            if runStep and runMeasure and state.measureHit then
                if math.abs(self.lastMeasure - self.measure) > 1 then
                    for i = self.lastMeasure, self.measure do
                        state:measureHit(i)
                    end
                else
                    state:measureHit(self.measure)
                end
            end
        end
        state = state.subState
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Conductor:_updateStep(newStep)
    local updated = false
    local newStepFloored = math.floor(newStep)

    if self.step ~= newStepFloored then
        self.lastStep = self.step
        self.step = newStepFloored
        updated = not (newStepFloored < self.lastStep and self.lastStep - newStepFloored < 2)
    end

    self.stepf = newStep
    return updated
end

---
--- @protected
---
function Conductor:_updateBeat(newBeat)
    local updated = false
    local newBeatFloored = math.floor(newBeat)

    if self.beat ~= newBeatFloored then
        self.lastBeat = self.beat
        self.beat = newBeatFloored
        updated = true
    end
    
    self.beatf = newBeat
    return updated
end

---
--- @protected
---
function Conductor:_updateMeasure(newMeasure)
    local updated = false
    local newMeasureFloored = math.floor(newMeasure)

    if self.measure ~= newMeasureFloored then
        self.lastMeasure = self.measure
        self.measure = newMeasureFloored
        updated = true
    end
    
    self.measuref = newMeasure
    return updated
end

---
--- @protected
---
function Conductor:get_time()
    return self.rawTime - (self.allowSongOffset and Settings.data.songOffset * 0.001 or 0.0)
end

---
--- @protected
---
function Conductor:get_crotchet()
    return 60.0 / self.bpm
end

---
--- @protected
---
function Conductor:get_stepCrotchet()
    return (60.0 / self.bpm) / self.timeSignature[2]
end

---
--- @protected
---
function Conductor:set_time(val)
    self.rawTime = val
    return self.rawTime
end

return Conductor