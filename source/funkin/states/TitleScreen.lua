---
--- @class funkin.states.TitleScreen : funkin.states.MusicBeatState
---
local TitleScreen = MusicBeatState:extend("TitleScreen", ...)

function TitleScreen:ready()
    TitleScreen.super.ready(self)

    if not flora.sound.music.playing then
        flora.sound:playMusic(Paths.music("freakyMenu"), true, 0.0)
        flora.sound.music:fadeIn(4)

        self.attachedConductor:reset(102)
        self.attachedConductor.music = flora.sound.music
    end

    self.danced = false

    ---
    --- @type flora.display.Group
    ---
    self.title_group = Group:new()
    -- self.title_group.visible = false
    self:add(self.title_group)

    ---
    --- @type flora.display.Sprite
    --- 
    self.logo = Sprite:new(-150, -100)
    self.logo.frames = Paths.getSparrowAtlas("logo", "images/menus/title")
    self.logo.animation:addByPrefix("idle", "logo bumpin", 24, false)
    self.logo.animation:play("idle")
    self.title_group:add(self.logo)

    ---
    --- @type flora.display.Sprite
    --- 
    self.gf = Sprite:new(flora.gameWidth * 0.4, flora.gameHeight * 0.07)
    self.gf.frames = Paths.getSparrowAtlas("gf", "images/menus/title")
    self.gf.animation:addByIndices("danceLeft", "gfDance", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15}, 24, false)
    self.gf.animation:addByIndices("danceRight", "gfDance", {16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30}, 24, false)
    self.gf.animation:play("danceRight")
    self.title_group:add(self.gf)

    ---
    --- @type funkin.ui.alphabet.Alphabet
    ---
    self.test = Alphabet:new(0, 200, "did you know?\ncheenis", "bold", "center", 1)
    self.test:screenCenter(Axes.X)
    self:add(self.test)
end

function TitleScreen:update(dt)
    TitleScreen.super.update(self, dt)
end

function TitleScreen:beatHit(beat)
    self.danced = not self.danced
    if not self.danced then
        self.gf.animation:play("danceLeft", true)
    else
        self.gf.animation:play("danceRight", true)
    end
    self.logo.animation:play("idle", true)
end

return TitleScreen