---
--- @class funkin.states.TitleScreen : funkin.states.MusicBeatState
---
local TitleScreen = MusicBeatState:extend("TitleScreen", ...)

-- TODO: newgrounds logo
-- TODO: press enter to begin text shit

function TitleScreen:ready()
    TitleScreen.super.ready(self)

    self.beatCallbacks = {
        [1] = function()
            self:createCoolText({"The", "Funkin Crew Inc"})
        end,
        [3] = function()
            self:createCoolText({"The", "Funkin Crew Inc", "Presents"})
        end,
        [4] = function()
            self:deleteCoolText()
        end,
        [5] = function()
            self:createCoolText({"In association", "with"})
        end,
        [7] = function()
            self:createCoolText({"In association", "with", "Newgrounds"})
        end,
        [8] = function()
            self:deleteCoolText()
        end,
        [9] = function()
            self:createCoolText({"quote 1 :]"})
        end,
        [11] = function()
            self:createCoolText({"quote 1 :]", "quote 2 :]"})
        end,
        [12] = function()
            self:deleteCoolText()
        end,
        [13] = function()
            self:createCoolText({"Friday"})
        end,
        [14] = function()
            self:createCoolText({"Friday", "Night"})
        end,
        [15] = function()
            self:createCoolText({"Friday", "Night", "Funkin"})
        end,
        [16] = function()
            self:skipIntro()
        end,
    }
    self.danced = false
    self.skippedIntro = false

    ---
    --- @type flora.display.Group
    ---
    self.titleGroup = Group:new()
    self.titleGroup.visible = false
    self:add(self.titleGroup)

    ---
    --- @type flora.display.Sprite
    --- 
    self.logo = Sprite:new(-150, -100)
    self.logo.frames = Paths.getSparrowAtlas("logo", "images/menus/title")
    self.logo.animation:addByPrefix("idle", "logo bumpin", 24, false)
    self.logo.animation:play("idle")
    self.titleGroup:add(self.logo)

    ---
    --- @type flora.display.Sprite
    --- 
    self.gf = Sprite:new(flora.gameWidth * 0.4, flora.gameHeight * 0.07)
    self.gf.frames = Paths.getSparrowAtlas("gf", "images/menus/title")
    self.gf.animation:addByIndices("danceLeft", "gfDance", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15}, 24, false)
    self.gf.animation:addByIndices("danceRight", "gfDance", {16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30}, 24, false)
    self.gf.animation:play("danceRight")
    self.titleGroup:add(self.gf)

    ---
    --- @type funkin.ui.alphabet.Alphabet
    ---
    self.introText = Alphabet:new(0, 200, "", "bold", "center", 1)
    self.introText:screenCenter(Axes.X)
    self:add(self.introText)

    if not flora.sound.music.playing then
        flora.sound:playMusic(Paths.music("freakyMenu"), true, 0.0)
        flora.sound.music:fadeIn(4)

        self.attachedConductor:reset(102)
        self.attachedConductor.music = flora.sound.music
    end
end

function TitleScreen:update(dt)
    TitleScreen.super.update(self, dt)

    if flora.keys.justPressed[KeyCode.ENTER] then
        if not self.skippedIntro then
            self:skipIntro()
        end
    end
end

function TitleScreen:deleteCoolText()
    self.introText.text = ""
end

function TitleScreen:createCoolText(lines)
    if #lines == 0 then
        self.introText.text = ""
        return
    end
    local text = lines[1]
    for i = 2, #lines do
        local line = lines[i]
        text = text .. "\n" .. line
    end
    self.introText.text = text:trim()
    self.introText:screenCenter(Axes.X)
end

function TitleScreen:skipIntro()
    if self.skippedIntro then
        return
    end
    self.skippedIntro = true
    self.titleGroup.visible = true

    self:deleteCoolText()
    flora.camera:flash(Color.WHITE, 4)
end

function TitleScreen:beatHit(beat)
    if not self.skippedIntro and self.beatCallbacks[beat] then
        self.beatCallbacks[beat]()
    end
    self.danced = not self.danced
    if not self.danced then
        self.gf.animation:play("danceLeft", true)
    else
        self.gf.animation:play("danceRight", true)
    end
    self.logo.animation:play("idle", true)
end

return TitleScreen