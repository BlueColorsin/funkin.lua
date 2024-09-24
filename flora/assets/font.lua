---@diagnostic disable: invisible
---
--- A basic font class, used for storing fonts to
--- render onto text.
---
--- @class flora.assets.font : flora.base.ref_counted
---
local font = ref_counted:extend()
font.oversampling = 2

function font:constructor(path)
    font.super.constructor(self)

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
function font:get_data_for_size(size)
    if not self.data[size] then
        local fnt = love.graphics.newFont(self.path, size * font.oversampling)
        fnt:setFilter("linear", "linear", 4)
        self.data[size] = fnt
    end
    return self.data[size]
end

---
--- Removes this font from memory.
---
function font:dispose()
    for _, fnt in pairs(self.data) do
        fnt:release()
    end
    self.data = nil
    flora.assets._font_cache[self.path] = nil
end

function font:__tostring()
    return "font (" .. #self.data .. " cached size" .. (#self.data ~= 1 and "s" or "") .. ")"
end

return font