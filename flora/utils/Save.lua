---
--- A class for saving data to a file, useful for
--- saving player data, highscores, etc.
---
--- @class flora.utils.Save
---
local Save = Class:extend("Save", ...)
Save.dir = love.filesystem.getSaveDirectory()



function Save:constructor()
    ---
    --- The data belonging to this save data object.
    ---
    --- @type table
    ---
    self.data = {}

    ---
    --- @protected
    --- @type string
    ---
    self._path = nil

    ---5
    --- @protected
    --- @type function?
    ---
    self._quitCallback = function()
        self:flush()
    end
    Flora.signals.preQuit:connect(self._quitCallback)
end

function Save:bind(name)
    self._path = Path.normalize(name) .. ".fsav"

    local data = love.filesystem.read(self._path)
    if data then
        self.data = Json.decode(love.data.decode("string", "hex", data))
    else
        self:flush()
    end
end

function Save:flush()
    if not self._path then
        return
    end
    love.filesystem.write(self._path, love.data.encode("string", "hex", Json.encode(self.data)))
end

function Save:close()
    self.data = nil
    self._path = nil
    self._quitCallback = nil
end

function Save:dispose()
    Flora.signals.preQuit:disconnect(self._quitCallback)
    self:close()
end

return Save