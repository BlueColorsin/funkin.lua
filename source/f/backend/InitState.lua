---
--- @class funkin.states.InitState : flora.display.State
---
local InitState = State:extend("InitState", ...)

InitState._lastState = ""

function InitState:ready()
    InitState.super.ready(self)

    ---
    --- @type funkin.assets.Paths
    ---
    Paths = flora.import("funkin.assets.Paths")

    ---
    --- @type funkin.states.MusicBeatState
    ---
    MusicBeatState = flora.import("funkin.states.MusicBeatState")

    ---
    --- @type funkin.plugins.Conductor
    ---
    Conductor = flora.import("funkin.plugins.Conductor")

    ---
    --- @type funkin.data.Settings
    ---
    Settings = flora.import("funkin.data.Settings")
    Settings.init()

    ---
    --- @type funkin.ui.alphabet.Alphabet
    ---
    Alphabet = flora.import("funkin.ui.alphabet.Alphabet")

    if flora.soundTray then
        flora.soundTray:dispose()
    end
    flora.soundTray = flora.import("funkin.ui.SoundTray"):new()

    flora.signals.preStateSwitch:connect(function()
        if flora.state.__class ~= InitState._lastState then
            Paths.clearCache()
        end
    end)
    flora.signals.postStateSwitch:connect(function()
        InitState._lastState = flora.state.__class
    end)

    Conductor.instance = Conductor:new()
    flora.plugins:add(Conductor.instance)

    -- local Preloader = flora.import("funkin.Preloader")
    -- flora.switchState(Preloader:new())

    local TitleScreen = flora.import("funkin.states.TitleScreen")
    flora.switchState(TitleScreen:new())
end

return InitState