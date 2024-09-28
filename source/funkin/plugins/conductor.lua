---
--- @class funkin.plugins.conductor : flora.base.basic
---
local conductor = basic:extend("conductor", ...)

---
--- The main global instance of the conductor.
---
--- @type funkin.plugins.conductor
---
conductor.instance = nil

conductor.judge_scales = {
    j1 = 1.5,
    j2 = 1.33,
    j3 = 1.16,
    j4 = 1.0,
    j5 = 0.84,
    j6 = 0.66,
    j7 = 0.5,
    j8 = 0.33,
    justice = 0.2,
}

function conductor.time_signature_from_string(str)
    local split = string.split(str, "/")
    return {tonumber(split[1]), tonumber(split[2])}
end

function conductor:constructor()
    conductor.super.constructor(self)

    self.visible = false

    ---
    --- @type flora.utils.signal
    ---
    self.step_hit = signal:new():type("number", "void")

    ---
    --- @type flora.utils.signal
    ---
    self.beat_hit = signal:new():type("number", "void")

    ---
    --- @type flora.utils.signal
    ---
    self.measure_hit = signal:new():type("number", "void")

    ---
    --- @type boolean
    ---
    self.has_metronome = false

    ---
    --- @type flora.sound?
    ---
    self.music = nil

    ---
    --- @type number
    ---
    self.bpm = 100.0

    ---
    --- @type table
    ---
    self.bpm_changes = {
        {
            step = 0,
            time = 0.0,
            bpm = 100.0
        }
    }

    ---
    --- @type table<number>
    ---
    self.time_signature = {4, 4}
    -- ^^ - 1st num is beats per measure, 2nd num is steps per beat

    ---
    --- @type number
    ---
    self.crotchet = nil

    ---
    --- @type number
    ---
    self.step_crotchet = nil

    ---
    --- @type number
    ---
    self.safe_zone_offset = settings.data.hit_window / 1000.0

    ---
    --- @type boolean
    ---
    self.allow_song_offset = true

    ---
    --- @type number
    ---
    self.raw_time = 0.0

    ---
    --- @type number
    ---
    self.time = nil

    ---
    --- @type integer
    ---
    self.last_step = 0

    ---
    --- @type integer
    ---
    self.last_beat = 0

    ---
    --- @type integer
    ---
    self.last_measure = 0

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
    self._last_bpm_change = self.bpm_changes[1]
end

function conductor:reset(bpm)
    self.time = 0.0

    self.measuref = 0.0
    self.measure = 0

    self.beatf = 0.0
    self.beat = 0

    self.stepf = 0.0
    self.step = 0

    self.time_signature = {4, 4}
    self.bpm_changes = {
        {
            step = 0,
            time = 0.0,
            bpm = bpm
        }
    }
    self.bpm = bpm
end

function conductor:setup_from_map(map)
    self:reset()
    self.time_signature = conductor.time_signature_from_string(map.meta.timeSignature)

    self.bpm = map.meta.bpm
    self:setup_bpm_changes(map)
end

function conductor:setup_bpm_changes(map)
    self.bpm_changes = {
        {
            time = 0.0,
            step = 0,
            bpm = map.meta.bpm
        }
    }
    if not map.events or #map.events == 0 then
        return
    end
    local time_sig = conductor.time_signature_from_string(map.meta.timeSignature)

    local cur_bpm = 0.0
    local time = 0.0
    local last_step = 0.0

    for i = 1, #map.events do
        local event = map.events[i]
        if event.type == "BPM Change" and event.params and type(event.params.bpm) == "number" then
            local event_bpm = event.params.bpm
            if event_bpm ~= cur_bpm then
                time = time + (event.step - last_step) * ((60 / cur_bpm) / time_sig[2])
                cur_bpm = event_bpm

                table.insert(self.bpm_changes, {
                    time = time,
                    step = event.step,
                    bpm = cur_bpm
                })
                last_step = event.step
            end
        end
    end
end

function conductor:step_to_time(step)
    local last_change = self.bpm_changes[1]

    for i = 2, #self.bpm_changes do
        local change = self.bpm_changes[i]

        if self.raw_time >= change.time then
            last_change = change
        end
    end

    return last_change.time + ((step - last_change.time) * ((60 / last_change.bpm) * self.time_signature[2]))
end

function conductor:beat_to_time(beat)
    return self:step_to_time(beat * self.time_signature[2])
end

function conductor:measure_to_time(measure)
    return self:beat_to_time(measure * self.time_signature[1])
end

function conductor:time_to_step(time)
    local last_change = self.bpm_changes[1]

    for i = 2, #self.bpm_changes do
        local change = self.bpm_changes[i]

        if time >= change.time then
            last_change = change
        end
    end

    return last_change.step + ((time - last_change.time) / ((60 / last_change.bpm) * self.time_signature[2]))
end

function conductor:time_to_beat(time)
    return self:time_to_step(time) / self.time_signature[2]
end

function conductor:time_to_measure(time)
    return self:time_to_beat(time) / self.time_signature[1]
end

function conductor:update(dt)
    if self.music and self.music.playing then
        if math.abs(self.raw_time - self.music.time) > 0.02 then
            self.raw_time = self.music.time 
        end
    end
    self._last_bpm_change = self.bpm_changes[1]
    for i = 2, #self.bpm_changes do
        local change = self.bpm_changes[i]

        if self.time >= change.time then
            last_change = change
        end
    end
    if self._last_bpm_change.bpm > 0 and self.bpm ~= self._last_bpm_change.bpm then
        self.bpm = self._last_bpm_change.bpm
    end

    local run_step = self:_update_step(((self.time - self._last_bpm_change.time) / self.step_crotchet) + self._last_bpm_change.step)
    if run_step then
        if math.abs(self.last_step - self.step) > 1 then
            for i = self.last_step, self.step do
                self.step_hit:emit(i + 1)
            end
        else
            self.step_hit:emit(self.step)
        end
    end
    local run_beat = self:_update_beat(self.stepf / self.time_signature[2])
    if run_beat then
        if math.abs(self.last_beat - self.beat) > 1 then
            for i = self.last_beat, self.beat do
                self.beat_hit:emit(i + 1)
            end
        else
            self.beat_hit:emit(self.beat)
        end
        if self.has_metronome then
            flora.sound:play(paths.sound("metronome"))
        end
    end
    local run_measure = self:_update_measure(self.beatf / self.time_signature[1])
    if run_measure then
        if math.abs(self.last_measure - self.measure) > 1 then
            for i = self.last_measure, self.measure do
                self.measure_hit:emit(i + 1)
            end
        else
            self.measure_hit:emit(self.measure)
        end
    end
    local state = flora.state
    while state do
        if not state.sub_state or state.persistent_update then
            if run_step and state.step_hit then
                if math.abs(self.last_step - self.step) > 1 then
                    for i = self.last_step, self.step do
                        state:step_hit(i + 1)
                    end
                else
                    state:step_hit(self.step)
                end
            end
            if run_beat and state.beat_hit then
                if math.abs(self.last_beat - self.beat) > 1 then
                    for i = self.last_beat, self.beat do
                        state:beat_hit(i + 1)
                    end
                else
                    state:beat_hit(self.beat)
                end
            end
            if run_measure and state.measure_hit then
                if math.abs(self.last_measure - self.measure) > 1 then
                    for i = self.last_measure, self.measure do
                        state:measure_hit(i + 1)
                    end
                else
                    state:measure_hit(self.measure)
                end
            end
        end
        state = state.sub_state
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function conductor:_update_step(new_step)
    local updated = false
    local new_step_floored = math.floor(new_step)

    if self.step ~= new_step_floored then
        self.last_step = self.step
        self.step = new_step_floored
        updated = not (new_step_floored < self.last_step and self.last_step - new_step_floored < 2)
    end

    self.stepf = new_step
    return updated
end

---
--- @protected
---
function conductor:_update_beat(new_beat)
    local updated = false
    local new_beat_floored = math.floor(new_beat)

    if self.beat ~= new_beat_floored then
        self.last_beat = self.beat
        self.beat = new_beat_floored
        updated = true
    end
    
    self.beatf = new_beat
    return updated
end

---
--- @protected
---
function conductor:_update_measure(new_measure)
    local updated = false
    local new_measure_floored = math.floor(new_measure)

    if self.measure ~= new_measure_floored then
        self.last_measure = self.measure
        self.measure = new_measure_floored
        updated = true
    end
    
    self.measuref = new_measure
    return updated
end

---
--- @protected
---
function conductor:get_time()
    return self.raw_time
end

---
--- @protected
---
function conductor:get_crotchet()
    return 60.0 / self.bpm
end

---
--- @protected
---
function conductor:get_step_crotchet()
    return (60.0 / self.bpm) / self.time_signature[2]
end

---
--- @protected
---
function conductor:set_time(val)
    self.raw_time = val
    return self.raw_time
end

return conductor