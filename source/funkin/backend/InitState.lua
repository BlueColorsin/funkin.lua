---
--- @type funkin.data.Cache
---
Cache = Flora.import("funkin.data.Cache")

---
--- @type funkin.data.Constants
---
Constants = Flora.import("funkin.data.Constants")

---
--- @type funkin.api.Discord
---
Discord = Flora.import("funkin.api.Discord")

---
--- @type funkin.assets.Paths
---
Paths = Flora.import("funkin.assets.Paths")

---
--- @type funkin.utils.Tools
---
Tools = Flora.import("funkin.utils.Tools")

---
--- @type funkin.substates.MusicBeatSubstate
---
MusicBeatSubstate = Flora.import("funkin.substates.MusicBeatSubstate")

---
--- @type funkin.objects.ui.transition.BaseTransition
---
BaseTransition = Flora.import("funkin.objects.ui.transition.BaseTransition")

---
--- @type funkin.objects.ui.transition.InstantTransition
---
InstantTransition = Flora.import("funkin.objects.ui.transition.InstantTransition")

---
--- @type funkin.objects.ui.transition.SwipeTransition
---
SwipeTransition = Flora.import("funkin.objects.ui.transition.SwipeTransition")

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
--- @type funkin.data.SongDatabase
---
SongDatabase = Flora.import("funkin.data.SongDatabase")

---
--- @type funkin.input.Controls
---
Controls = Flora.import("funkin.input.Controls")

---
--- @type funkin.plugins.KeybindManager
---
KeybindManager = Flora.import("funkin.plugins.KeybindManager")

---
--- @type funkin.objects.ui.alphabet.Alphabet
---
Alphabet = Flora.import("funkin.objects.ui.alphabet.Alphabet")

---
--- @type funkin.Preloader
---
local Preloader = Flora.import("funkin.Preloader")

---
--- @type funkin.states.TitleState
---
local TitleState = Flora.import("funkin.states.TitleState")

---
--- @type funkin.states.MainMenuState
---
local MainMenuState = Flora.import("funkin.states.MainMenuState")

---
--- @class funkin.states.InitState : flora.display.State
---
local InitState = State:extend("InitState", ...)

InitState._lastState = ""

function InitState:ready()
    InitState.super.ready(self)

    Discord.init()

    Sprite.defaultAntialiasing = true
    Camera.defaultAntialiasing = true
    
    Settings.init()
    Controls.init()

    SongDatabase.updateLevelList()
    SongDatabase.updateSongList()

    if Flora.soundTray then
        Flora.soundTray:dispose()
    end
    Flora.soundTray = Flora.import("funkin.objects.ui.SoundTray"):new()

    Flora.signals.preStateCreate:connect(function()
        if Flora.state.__class ~= InitState._lastState then
            Cache.clear()
        end
    end)
    Flora.signals.postStateSwitch:connect(function()
        InitState._lastState = Flora.state.__class
    end)

    Conductor.instance = Conductor:new()
    Flora.plugins:add(Conductor.instance)

    KeybindManager.instance = KeybindManager:new()
    Flora.plugins:add(KeybindManager.instance)

    -- Flora.switchState(Preloader:new())
    Flora.switchState(MainMenuState:new())
end

return InitState