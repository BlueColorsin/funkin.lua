---
--- A class for saving data to a file, useful for
--- saving player data, highscores, etc.
---
--- @class flora.utils.save
---
local save = class:extend("save", ...)
save.dir = love.filesystem.getSaveDirectory()

function save:constructor()
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
end

function save:bind(name)
    self._path = path.normalize(name) .. ".fsav"

    local data = love.filesystem.read(self._path)
    if data then
        self.data = json.decode(love.data.decode("string", "hex", data))
    else
        self:flush()
    end
end

function save:flush()
    if not self._path then
        return
    end
    love.filesystem.write(self._path, love.data.encode("string", "hex", json.encode(self.data)))
end

return save