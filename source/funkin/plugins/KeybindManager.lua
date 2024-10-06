---
--- @class funkin.plugins.KeybindManager : flora.base.Basic
---
local KeybindManager = Basic:extend("KeybindManager", ...)

---
--- @type funkin.plugins.KeybindManager
---
KeybindManager.instance = nil

function KeybindManager:constructor()
    KeybindManager.super.constructor(self)

    self.visible = false
end

function KeybindManager:update(dt)
    if Flora.keys.justPressed.F5 then
        SongDatabase.updateLevelList()
        SongDatabase.updateSongList()
        Flora.forceResetState()
    end
    if Controls.justPressed.FULLSCREEN then
        Flora.fullscreen = not Flora.fullscreen
    end
end

return KeybindManager