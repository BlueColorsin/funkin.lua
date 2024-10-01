---
--- @class funkin.states.MainMenuState : funkin.states.MusicBeatState
---
local MainMenuState = MusicBeatState:extend("MainMenuState", ...)

function MainMenuState:ready()
    MainMenuState.super.ready(self)

    ---
    --- @type flora.display.Sprite
    ---
    self.bg = Sprite:new():loadTexture(Paths.image("yellow", "images/menus"))
    self.bg.scale:set(1.2, 1.2)
    self.bg:screenCenter(Axes.XY)
    self.bg.scrollFactor:set(0, 0.17)
    self:add(self.bg)
end

function MainMenuState:update(dt)
    MainMenuState.super.update(self, dt)

    if Flora.sound.music.volume < 1 then
        Flora.sound.music.volume = Flora.sound.music.volume + (dt * 0.5)
    end
end

return MainMenuState