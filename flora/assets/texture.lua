---@diagnostic disable: invisible
---
--- A basic texture class, used for caching and rendering
--- textures to sprites.
---
--- @class flora.assets.texture : flora.base.ref_counted
---
local texture = ref_counted:extend()

function texture:constructor(key, image)
    texture.super.constructor(self)

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
function texture:update_image(image)
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
function texture:dispose()
    self.image:release()
    flora.assets._texture_cache[self.key] = nil
end

function texture:__tostring()
    return "texture (size: " .. self.width .. "x" .. self.height .. ", persist: " .. self.persist .. ")"
end

return texture