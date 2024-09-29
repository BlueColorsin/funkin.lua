---
--- @class funkin.states.title_screen : funkin.states.music_beat_state
---
local title_screen = music_beat_state:extend("title_screen", ...)
local alphabet = flora.import("funkin.ui.alphabet")

function title_screen:ready()
    title_screen.super.ready(self)

    if not flora.sound.music.playing then
        flora.sound:play_music(paths.music("freakyMenu"), true, 0.0)
        flora.sound.music:fade_in(4)

        self.attached_conductor:reset(102)
        self.attached_conductor.music = flora.sound.music
    end

    self.danced = false

    ---
    --- @type flora.display.group
    ---
    self.title_group = group:new()
    -- self.title_group.visible = false
    self:add(self.title_group)

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
    self.title_group:add(self.logo)

    ---
    --- @type flora.display.sprite
    --- 
    self.gf = sprite:new(flora.game_width * 0.4, flora.game_height * 0.07)
    self.gf.frames = atlas_frames.from_sparrow(
        "assets/images/menus/title/gf.png",
        "assets/images/menus/title/gf.xml"
    )
    self.gf.animation:add_by_indices("danceLeft", "gfDance", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15}, 24, false)
    self.gf.animation:add_by_indices("danceRight", "gfDance", {16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30}, 24, false)
    self.gf.animation:play("danceRight")
    self.title_group:add(self.gf)

    self.test = alphabet:new(32.0, 720.0 - 32.0 + 4.0, "hey little swordcube\nhey big 80085")
    self.test.y = self.test.y - self.test.height
    self:add(self.test)
end

function title_screen:update(dt)
    title_screen.super.update(self, dt)
end

function title_screen:beat_hit(beat)
    self.danced = not self.danced
    if not self.danced then
        self.gf.animation:play("danceLeft", true)
    else
        self.gf.animation:play("danceRight", true)
    end
    self.logo.animation:play("idle", true)
end

return title_screen