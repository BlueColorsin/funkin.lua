local lily = require("flora.libs.lily")
local font = require("flora.assets.font")
local texture = require("flora.assets.texture")

---
--- Accessed via `flora.assets`.
---
--- @class flora.frontends.asset_front_end : flora.base.basic
---
local asset_front_end = basic:extend()

function asset_front_end:constructor()
    asset_front_end.super.constructor(self)

    ---
    --- @protected
    ---
    self._texture_cache = {}

    ---
    --- @protected
    ---
    self._font_cache = {}

    ---
    --- @protected
    ---
    self._sound_cache = {}
end

---
--- @param  key      string
--- @param  texture  flora.assets.texture?
--- 
--- @return flora.assets.texture?
---
function asset_front_end:cache_texture(key, texture)
    self._texture_cache[key] = texture
    return texture
end

---
--- @param  path  string
---
function asset_front_end:load_texture_async(path, compressed, on_complete)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._texture_cache[path] then
        lily.newImage(path):onComplete(function(_, image)
            local tex = texture:new(path, image)
            self:cache_texture(path, tex)

            if on_complete then
                on_complete()
            end
        end)
    end
end

---
--- @param  path  string
--- 
--- @return flora.assets.texture?
---
function asset_front_end:load_texture(path, compressed)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._texture_cache[path] then
        local tex = texture:new(path, love.graphics.newImage(compressed and love.image.newCompressedData(path) or love.image.newImageData(path)))
        self:cache_texture(path, tex)
    end
    return self._texture_cache[path]
end

---
--- @param  key   string
--- @param  font  flora.assets.font?
--- 
--- @return flora.assets.font?
---
function asset_front_end:cache_font(key, font)
    self._font_cache[key] = font
    return font
end

---
--- @param  path  string
--- 
--- @return flora.assets.font?
---
function asset_front_end:load_font(path)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._font_cache[path] then
        local fnt = font:new(path)
        self:cache_font(path, fnt)
    end
    return self._font_cache[path]
end

---
--- @param  key    string
--- @param  sound  love.SoundData?
--- 
--- @return love.SoundData?
---
function asset_front_end:cache_sound(key, sound)
    self._sound_cache[key] = sound
    return sound
end

---
--- @param  path  string
--- 
--- @return love.SoundData?
---
function asset_front_end:load_sound(path)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._sound_cache[path] then
        local snd = love.sound.newSoundData(path)
        self:cache_sound(path, snd)
    end
    return self._sound_cache[path]
end

---
--- @param  path  string
---
function asset_front_end:load_sound_async(path, on_complete)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._texture_cache[path] then
        ---
        --- @param  snd  love.SoundData
        ---
        lily.newSoundData(path):onComplete(function(_, snd)
            self:cache_sound(path, snd)

            if on_complete then
                on_complete()
            end
        end)
    end
end

return asset_front_end