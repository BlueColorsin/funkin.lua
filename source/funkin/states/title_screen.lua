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
    self.gf = sprite:new(flora.game_width * 0.4, flora.game_height * 0.07)
    self.gf.frames = atlas_frames.from_sparrow(
        "assets/images/menus/title/gf.png",
        "assets/images/menus/title/gf.xml"
    )
    self.gf.animation:add_by_indices("danceLeft", "gfDance", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13}, 24, false)
    self.gf.animation:play("danceLeft")
    self:add(self.gf)

    ---
    --- @type flora.display.sprite
    --- 
    self.logo = sprite:new(-150, -100)
    self.logo.frames = atlas_frames.from_sparrow(
        "assets/images/menus/title/logo.png",
        "assets/images/menus/title/logo.xml"
    )
    self.logo.animation:add_by_prefix("idle", "logo bumpin", 24, false)
    self.logo.animation:play("idle")
    self:add(self.logo)
end

function title_screen:update(dt)
    title_screen.super.update(self, dt)
end

return title_screen