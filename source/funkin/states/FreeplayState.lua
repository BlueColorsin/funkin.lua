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
            --- @type funkin.ui.alphabet.Alphabet
            ---
            local text = Alphabet:new(0, 30 + (60 * i), songMetadata.title or songID)
            text.isMenuItem = true
            text.targetY = i - 1
            self.grpSongs:add(text)
        end
    end
end

function FreeplayState:update(dt)
    FreeplayState.super.update(self, dt)

    local songMetadata = SongDatabase.getSongMetadata(SongDatabase.songList[self.curSelected])
    self.bg.tint = self.bg.tint:interpolate(songMetadata.color, dt * 3.75)

    if Controls.justPressed.BACK then
        local MainMenuState = Flora.import("funkin.states.MainMenuState")
        Flora.switchState(MainMenuState:new())
    end
end

function FreeplayState:dispose()
    FreeplayState.super.dispose(self)
    FreeplayState.lastSelected = self.curSelected
end

return FreeplayState