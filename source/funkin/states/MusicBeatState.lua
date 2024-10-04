---
--- @class funkin.states.MusicBeatState : flora.display.State
---
local MusicBeatState = State:extend("MusicBeatState", ...)

MusicBeatState.defaultTransition = SwipeTransition

function MusicBeatState:constructor()
    MusicBeatState.super.constructor(self)

    self.skipTransIn = false

    self.skipTransOut = false

    self.increaseConductorTime = true

    ---
    --- @type funkin.plugins.Conductor
    ---
    self.attachedConductor = Conductor.instance
end

function MusicBeatState:update(dt)
    MusicBeatState.super.update(self, dt)
    if self.increaseConductorTime then
        self.attachedConductor.rawTime = self.attachedConductor.rawTime + (dt * 1000.0)
    end
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

function MusicBeatState:startOutro(onOutroComplete)
    local trans = MusicBeatState.defaultTransition:new("in")
    trans.onPostComplete:connect(function(type)
        if type == "in" then
            MusicBeatState.super.startOutro(self, onOutroComplete)
        end
    end)
    self:openSubState(trans)
end

return MusicBeatState