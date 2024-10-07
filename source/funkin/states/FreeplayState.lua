---
--- @type funkin.objects.game.HealthIcon
---
local HealthIcon = Flora.import("funkin.objects.game.HealthIcon")

---
--- @class funkin.states.FreeplayState : funkin.states.MusicBeatState
---
local FreeplayState = MusicBeatState:extend("FreeplayState", ...)

---
--- @type integer
---
FreeplayState.lastSelected = 1

function FreeplayState:ready()
    FreeplayState.super.ready(self)

    -- yes keep updating actually
    self.persistentUpdate = true

    if not Flora.sound.music.playing then
        Tools.playMusic(Paths.music("freakyMenu"))
    end

    Discord.changePresence({
        state = "In the Freeplay Menu",
        details = "Selecting nothing"
    })

    ---
    --- @type integer
    ---
    self.curSelected = FreeplayState.lastSelected

    ---
    --- @type table<string>
    ---
    self.songList = {}

    ---
    --- @type flora.display.Sprite
    ---
    self.bg = Sprite:new():loadTexture(Paths.image("desat", "images/menus"))
    self.bg:screenCenter(Axes.XY)
    self:add(self.bg)

    ---
    --- @type flora.display.Group
    ---
    self.grpSongs = Group:new()
    self:add(self.grpSongs)

    ---
    --- @type flora.display.Group
    ---
    self.grpIcons = Group:new()
    self:add(self.grpIcons)

    local j = 0
    for i = 1, #SongDatabase.songList do
        ---
        --- @type string
        ---
        local songID = SongDatabase.songList[i]
        Flora.log:verbose("Adding song to list: " .. songID)
        
        local songMetadata = SongDatabase.getSongMetadata(songID)
        if songMetadata then
            Flora.log:verbose("Obtained metadata for " .. songID)
    
            ---
            --- @type funkin.objects.ui.alphabet.Alphabet
            ---
            local text = Alphabet:new(0, 30 + (70 * i), songMetadata.title or songID)
            text.isMenuItem = true
            text.targetY = j
            self.grpSongs:add(text)

            ---
            --- @type funkin.objects.game.HealthIcon
            ---
            local icon = HealthIcon:new(songMetadata.icon or "face", false)
            icon.tracked = text
            self.grpIcons:add(icon)

            j = j + 1
            table.insert(self.songList, songID)
        end
    end
    self:changeSelection(0, true)
end

function FreeplayState:update(dt)
    FreeplayState.super.update(self, dt)

    local songMetadata = SongDatabase.getSongMetadata(self.songList[self.curSelected])
    self.bg.tint = self.bg.tint:interpolate(songMetadata.color, dt * 3.75)

    if Controls.justPressed.UI_UP then
        self:changeSelection(-1)
    end
    if Controls.justPressed.UI_DOWN then
        self:changeSelection(1)
    end
    if Controls.justPressed.BACK then
        Flora.sound:play(Paths.sound("cancel", "sounds/menus"))
        
        local MainMenuState = Flora.import("funkin.states.MainMenuState")
        Flora.switchState(MainMenuState:new())
    end
end

function FreeplayState:changeSelection(by, force)
    force = force or false
    if by == 0 and not force then
        return
    end
    self.curSelected = math.wrap(self.curSelected + by, 1, self.grpSongs.length)

    for i = 1, self.grpSongs.length do
        ---
        --- @type funkin.objects.ui.alphabet.Alphabet
        ---
        local songText = self.grpSongs.members[i]
        songText.targetY = i - self.curSelected
        songText.alpha = (i == self.curSelected) and 1.0 or 0.6
    end
    Flora.sound:play(Paths.sound("scroll", "sounds/menus"))
end

function FreeplayState:dispose()
    FreeplayState.super.dispose(self)
    FreeplayState.lastSelected = self.curSelected
end

return FreeplayState