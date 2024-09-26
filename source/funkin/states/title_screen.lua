---
--- @class funkin.states.title_screen : flora.display.state
---
local title_screen = state:extend()

function title_screen:ready()
    title_screen.super.ready(self)

    if not flora.sound.music.playing then
        flora.sound:play_music(paths.music("freakyMenu"), true, 0.0)
        flora.sound.music:fade_in(4)
    end

    ---
    --- @type flora.display.sprite
    --- 
    self.placeholder = sprite:new()
    self.placeholder:load_texture("hai.png")
    self.placeholder:screen_center(axes.xy)
    self:add(self.placeholder)
end

return title_screen