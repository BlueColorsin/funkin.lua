---
--- @class funkin.states.MusicBeatSubstate : flora.display.SubState
---
local MusicBeatSubstate = SubState:extend("MusicBeatSubstate", ...)

function MusicBeatSubstate:constructor()
    MusicBeatSubstate.super.constructor(self)

    self.increaseConductorTime = false

    ---
    --- @type funkin.plugins.Conductor
    ---
    self.attachedConductor = Conductor.instance
end

function MusicBeatSubstate:update(dt)
    MusicBeatSubstate.super.update(self, dt)
    if self.increaseConductorTime then
        self.attachedConductor.rawTime = self.attachedConductor.rawTime + dt
    end
end

---
--- @param  step  integer
---
function MusicBeatSubstate:stepHit(step)
end

---
--- @param  beat  integer
---
function MusicBeatSubstate:beatHit(beat)
end

---
--- @param  measure  integer
---
function MusicBeatSubstate:measureHit(measure)
end

return MusicBeatSubstate