---
--- @class funkin.states.MusicBeatState : flora.display.State
---
local MusicBeatState = State:extend("MusicBeatState", ...)

function MusicBeatState:constructor()
    MusicBeatState.super.constructor(self)

    ---
    --- @type funkin.plugins.Conductor
    ---
    self.attachedConductor = Conductor.instance
end

function MusicBeatState:update(dt)
    MusicBeatState.super.update(self, dt)

    self.attachedConductor.rawTime = self.attachedConductor.rawTime + dt
end

---
--- @param  step  integer
---
function MusicBeatState:stepHit(step)
end

---
--- @param  beat  integer
---
function MusicBeatState:beatHit(beat)
end

---
--- @param  measure  integer
---
function MusicBeatState:measureHit(measure)
end

return MusicBeatState