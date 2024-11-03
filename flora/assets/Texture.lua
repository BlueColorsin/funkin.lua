---@diagnostic disable: invisible
---
--- A basic texture class, used for caching and rendering
--- textures to sprites.
---
--- @class flora.assets.Texture : flora.RefCounted
---
local Texture = RefCounted:extend("Texture", ...)

function Texture:constructor(key, image)
    Texture.super.constructor(self)

    ---
    --- The key used for this texture internally for caching.
    --- 
    --- @type string
    ---
    self.key = key

    ---
    --- The internal image used for this texture.
    ---
    --- @type love.Image
    ---
    self.image = image

    ---
    --- The width of this texture. (in pixels)
    ---
    self.width = self.image and self.image:getWidth() or 0.0

    ---
    --- The width of this texture. (in pixels)
    ---
    self.height = self.image and self.image:getHeight() or 0.0
end

---
--- @param  image  love.Image
---
function Texture:updateImage(image)
    if self.image then
        self.image:release()
    end
    self.image = image
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

---
--- Removes this texture from memory.
---
function Texture:dispose()
    if not self.image then
        return
    end
    self.image:release()
    self.image = nil
    Flora.assets._textureCache[self.key] = nil
end

function Texture:__tostring()
    return "Texture (size: " .. self.width .. "x" .. self.height .. ", references: " .. self.references .. ")"
end

return Texture