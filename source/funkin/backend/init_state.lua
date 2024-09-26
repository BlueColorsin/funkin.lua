---
--- @class funkin.states.init_state : flora.display.state
---
local init_state = state:extend()

function init_state:ready()
    init_state.super.ready(self)

    ---
    --- @type funkin.assets.paths
    ---
    paths = flora.import("funkin.assets.paths")

    if flora.sound_tray then
        flora.sound_tray:dispose()
    end
    flora.sound_tray = flora.import("funkin.ui.sound_tray"):new()

    local preloader = flora.import("funkin.preloader")
    flora.switch_state(preloader:new())
end

return init_state