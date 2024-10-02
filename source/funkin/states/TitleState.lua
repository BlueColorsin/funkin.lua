---
--- @class funkin.states.TitleState : funkin.states.MusicBeatState
---
local TitleState = MusicBeatState:extend("TitleState", ...)

function TitleState:ready()
    TitleState.super.ready(self)

    Discord.changePresence({
        state = "In the Title Screen"
    })

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
            self.ngSpr:revive()
        end,
        [8] = function()
            self:deleteCoolText()

            self:remove(self.ngSpr, true)
            self.ngSpr:dispose()
            self.ngSpr = nil
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
    self.accepted = false

    ---
    --- @type flora.display.Sprite
    --- 
    self.ngSpr = Sprite:new(0, Flora.gameHeight * 0.52)
    
    if Flora.random:bool(1) then
        self.ngSpr:loadTexture(Paths.image('newgrounds_classic', "images/menus/title"))
        
    elseif Flora.random:bool(30) then
        self.ngSpr:loadTexture(Paths.image('newgrounds_animated', "images/menus/title"), true, 600)
        self.ngSpr.animation:add('idle', {1, 2}, 8)
        self.ngSpr.animation:play('idle')
        self.ngSpr.scale:set(0.55, 0.55)
        self.ngSpr.y = self.ngSpr.y + 15
    else
        self.ngSpr:loadTexture(Paths.image('newgrounds', "images/menus/title"))
        self.ngSpr.scale:set(0.8, 0.8)
    end
    self.ngSpr:screenCenter(Axes.X)
    self.ngSpr:kill()
    self:add(self.ngSpr)

    ---
    --- @type funkin.ui.alphabet.Alphabet
    ---
    self.introText = Alphabet:new(0, 200, "", "bold", "center", 1)
    self.introText:screenCenter(Axes.X)
    self:add(self.introText)

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
    self.gf = Sprite:new(Flora.gameWidth * 0.4, Flora.gameHeight * 0.07)
    self.gf.frames = Paths.getSparrowAtlas("gf", "images/menus/title")
    self.gf.animation:addByIndices("danceLeft", "gfDance", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15}, 24, false)
    self.gf.animation:addByIndices("danceRight", "gfDance", {16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30}, 24, false)
    self.gf.animation:play("danceRight")
    self.titleGroup:add(self.gf)

    ---
    --- @type flora.display.Sprite
    --- 
    self.titleText = Sprite:new(100, Flora.gameHeight * 0.8)
    self.titleText.frames = Paths.getSparrowAtlas("enter", "images/menus/title")
    self.titleText.animation:addByPrefix("idle", "Press Enter to Begin", 24)
    self.titleText.animation:addByPrefix("press", "ENTER PRESSED", 24)
    self.titleText.animation:play("idle")
    self.titleGroup:add(self.titleText)

    if not Flora.sound.music.playing then
        Flora.sound:playMusic(Paths.music("freakyMenu"), true, 0.0)
        Flora.sound.music:fadeIn(4)

        self.attachedConductor:reset(102)
        self.attachedConductor.music = Flora.sound.music
    end

    ---
    --- @protected
    --- @type flora.utils.Timer?
    ---
    self._acceptTimer = nil
end

function TitleState:update(dt)
    TitleState.super.update(self, dt)

    if Controls.justPressed.ACCEPT then
        if not self.skippedIntro then
            self:skipIntro()
        else
            if not self.accepted then
                self.accepted = true
                Flora.camera:flash(Color.WHITE, 2)

                self._acceptTimer = Timer:new():start(2, function(_)
                    local MainMenuState = Flora.import("funkin.states.MainMenuState")
                    Flora.switchState(MainMenuState:new())
                end)
                self.titleText.animation:play("press")
                Flora.sound:play(Paths.sound("select", "sounds/menus"))
            else
                if self._acceptTimer then
                    self._acceptTimer:dispose()
                    self._acceptTimer = nil
                end
                local MainMenuState = Flora.import("funkin.states.MainMenuState")
                Flora.switchState(MainMenuState:new())
            end
        end
    end
end

function TitleState:deleteCoolText()
    self.introText.text = ""
end

function TitleState:createCoolText(lines)
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

function TitleState:skipIntro()
    if self.skippedIntro then
        return
    end
    if self.ngSpr then
        self:remove(self.ngSpr, true)
        self.ngSpr:dispose()
        self.ngSpr = nil
    end
    self.skippedIntro = true
    self.titleGroup.visible = true

    self:deleteCoolText()
    Flora.camera:flash(Color.WHITE, 4)
end

function TitleState:beatHit(beat)
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

return TitleState