---
--- @class funkin.states.music_beat_state : flora.display.state
---
local music_beat_state = state:extend("music_beat_state", ...)

function music_beat_state:constructor()
    music_beat_state.super.constructor(self)

    ---
    --- @type funkin.plugins.conductor
    ---
    self.attached_conductor = conductor.instance
end

function music_beat_state:update(dt)
    music_beat_state.super.update(self, dt)

    self.attached_conductor.raw_time = self.attached_conductor.raw_time + dt
end

---
--- @param  step  integer
---
function music_beat_state:step_hit(step)
end

---
--- @param  beat  integer
---
function music_beat_state:beat_hit(beat)
end

---
--- @param  measure  integer
---
function music_beat_state:measure_hit(measure)
end

return music_beat_state