---
--- @class funkin.ui.mainmenu.MainMenuButton : flora.display.Sprite
---
local MainMenuButton = Sprite:extend("MainMenuButton", ...)

---
--- @param  name             string    The name of this button. (`storymode`, `freeplay`, etc)
--- @param  rpcName          string    The name of this button displayed in Discord RPC. (`Story Mode`, `Freeplay`, etc)
--- @param  callback         function  The function that runs when this button is accepted.
--- @param  fireImmediately  boolean?  If set to `false`, a special effect will play before firing `callback`. Otherwise, `callback` will be fired immediately.
---
function MainMenuButton:constructor(name, rpcName, callback, fireImmediately)
    MainMenuButton.super.constructor(self)

    ---
    --- @type string
    ---
    self.name = name

    ---
    --- @type string
    ---
    self.rpcName = rpcName

    ---
    --- @type function
    ---
    self.callback = callback

    ---
    --- @type boolean
    ---
    self.fireImmediately = fireImmediately and fireImmediately or false

    self.frames = Paths.getSparrowAtlas(self.name, "images/menus/main")
    self.animation:addByPrefix("idle", string.format("%s idle", self.name), 24)
    self.animation:addByPrefix("selected", string.format("%s selected", self.name), 24)
    self:playAnim("idle")
end

function MainMenuButton:playAnim(name)
    self.animation:play(name)
    self.offset:set(self.origin.x * self.width, self.origin.y * self.height)
end

return MainMenuButton