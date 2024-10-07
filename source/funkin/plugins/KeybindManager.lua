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
        Cache.clear()
        
        SongDatabase.updateLevelList()
        SongDatabase.updateSongList()

        Flora.forceResetState()
        Flora._switchState() -- immediately switch states to prevent crashes
    end
    if Controls.justPressed.FULLSCREEN then
        Flora.fullscreen = not Flora.fullscreen
    end
end

return KeybindManager