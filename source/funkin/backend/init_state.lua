---
--- @class funkin.states.init_state : flora.display.state
---
local init_state = state:extend("init_state", ...)

function init_state:ready()
    init_state.super.ready(self)

    ---
    --- @type funkin.assets.paths
    ---
    paths = flora.import("funkin.assets.paths")

    ---
    --- @type funkin.states.music_beat_state
    ---
    music_beat_state = flora.import("funkin.states.music_beat_state")

    ---
    --- @type funkin.plugins.conductor
    ---
    conductor = flora.import("funkin.plugins.conductor")

    ---
    --- @type funkin.data.settings
    ---
    settings = flora.import("funkin.data.settings")
    settings.init()

    if flora.sound_tray then
        flora.sound_tray:dispose()
    end
    flora.sound_tray = flora.import("funkin.ui.sound_tray"):new()

    conductor.instance = conductor:new()
    flora.plugins:add(conductor.instance)

    local preloader = flora.import("funkin.preloader")
    flora.switch_state(preloader:new())

    -- local title_screen = flora.import("funkin.states.title_screen")
    -- flora.switch_state(title_screen:new())
end

return init_state