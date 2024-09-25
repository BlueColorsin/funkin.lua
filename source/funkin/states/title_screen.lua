---
--- @class funkin.states.title_screen : flora.display.state
---
local title_screen = state:extend()

function title_screen:ready()
    title_screen.super.ready(self)

    ---
    --- @type flora.display.sprite
    ---
    self.placeholder = sprite:new()
    self.placeholder:load_texture("hai.png")
    self.placeholder:screen_center(axes.xy)
    self:add(self.placeholder)
end

return title_screen