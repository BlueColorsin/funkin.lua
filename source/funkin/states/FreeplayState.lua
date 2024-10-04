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
end

function FreeplayState:update(dt)
    FreeplayState.super.update(self, dt)

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