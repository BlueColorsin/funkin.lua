---
--- @type funkin.api.Discord
---
Discord = Flora.import("funkin.api.Discord")

---
--- @type funkin.assets.Paths
---
Paths = Flora.import("funkin.assets.Paths")

---
--- @type funkin.states.MusicBeatState
---
MusicBeatState = Flora.import("funkin.states.MusicBeatState")

---
--- @type funkin.plugins.Conductor
---
Conductor = Flora.import("funkin.plugins.Conductor")

---
--- @type funkin.data.Settings
---
Settings = Flora.import("funkin.data.Settings")

---
--- @type funkin.input.Controls
---
Controls = Flora.import("funkin.input.Controls")

---
--- @type funkin.ui.alphabet.Alphabet
---
Alphabet = Flora.import("funkin.ui.alphabet.Alphabet")

---
--- @type funkin.Preloader
---
local Preloader = Flora.import("funkin.Preloader")

---
--- @type funkin.states.TitleState
---
local TitleState = Flora.import("funkin.states.TitleState")

---
--- @class funkin.states.InitState : flora.display.State
---
local InitState = State:extend("InitState", ...)

InitState._lastState = ""

function InitState:ready()
    InitState.super.ready(self)

    if Flora.soundTray then
        Flora.soundTray:dispose()
    end
    Flora.soundTray = Flora.import("funkin.ui.SoundTray"):new()

    Flora.signals.preStateCreate:connect(function()
        if Flora.state.__class ~= InitState._lastState then
            Paths.clearCache()
        end
    end)
    Flora.signals.postStateSwitch:connect(function()
        InitState._lastState = Flora.state.__class
    end)

    Discord.init()
    
    Settings.init()
    Controls.init()

    Conductor.instance = Conductor:new()
    Flora.plugins:add(Conductor.instance)

    -- Flora.switchState(Preloader:new())
    Flora.switchState(TitleState:new())
end

return InitState