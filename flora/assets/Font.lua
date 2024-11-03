---@diagnostic disable: invisible
---
--- A basic font class, used for storing fonts to
--- render onto text.
---
--- @class flora.assets.Font : flora.RefCounted
---
local Font = RefCounted:extend("Font", ...)
Font.oversampling = 2

function Font:constructor(path)
    Font.super.constructor(self)

    ---
    --- The file path used for this font internally.
    ---
    self.path = path

    ---
    --- The internal data used for this font.
    ---
    --- @type table<integer, love.Font>
    ---
    self.data = {}
end

---
--- @param  size  integer
--- @return love.Font
---
function Font:getDataForSize(size)
    if not self.data[size] then
        local fnt = love.graphics.newFont(self.path, size * Font.oversampling)
        fnt:setFilter("linear", "linear", 4)
        self.data[size] = fnt
    end
    return self.data[size]
end

---
--- Removes this font from memory.
---
function Font:dispose()
    for _, fnt in pairs(self.data) do
        fnt:release()
    end
    self.data = nil
    Flora.assets._fontCache[self.path] = nil
end

function Font:__tostring()
    return "font (" .. #self.data .. " cached size" .. (#self.data ~= 1 and "s" or "") .. ")"
end

return Font