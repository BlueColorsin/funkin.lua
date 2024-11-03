local lily = require("flora.libs.lily")
local Font = require("flora.assets.Font")
local Texture = require("flora.assets.Texture")

---
--- Accessed via `flora.assets`.
---
--- @class flora.frontends.AssetFrontEnd : flora.Basic
---
local AssetFrontEnd = Basic:extend("AssetFrontEnd", ...)

function AssetFrontEnd:constructor()
    AssetFrontEnd.super.constructor(self)

    ---
    --- @protected
    ---
    self._textureCache = {}

    ---
    --- @protected
    ---
    self._fontCache = {}

    ---
    --- @protected
    ---
    self._soundCache = {}
end

---
--- @param  key      string
--- @param  texture  flora.assets.Texture?
--- 
--- @return flora.assets.Texture?
---
function AssetFrontEnd:cacheTexture(key, texture)
    self._textureCache[key] = texture
    return texture
end

---
--- @param  path  string
---
function AssetFrontEnd:loadTextureASync(path, compressed, onComplete)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._textureCache[path] then
        lily.newImage(path):onComplete(function(_, image)
            local tex = Texture:new(path, image)
            self:cacheTexture(path, tex)

            if onComplete then
                onComplete(tex)
            end
        end)
    end
end

---
--- @param  path  string
--- 
--- @return flora.assets.Texture?
---
function AssetFrontEnd:loadTexture(path, compressed)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._textureCache[path] then
        local tex = Texture:new(path, love.graphics.newImage(compressed and love.image.newCompressedData(path) or love.image.newImageData(path)))
        self:cacheTexture(path, tex)
    end
    return self._textureCache[path]
end

---
--- @param  key   string
--- @param  font  flora.assets.Font?
--- 
--- @return flora.assets.Font?
---
function AssetFrontEnd:cacheFont(key, font)
    self._fontCache[key] = font
    return font
end

---
--- @param  path  string
--- 
--- @return flora.assets.Font?
---
function AssetFrontEnd:loadFont(path)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._fontCache[path] then
        local fnt = Font:new(path)
        self:cacheFont(path, fnt)
    end
    return self._fontCache[path]
end

---
--- @param  key    string
--- @param  sound  love.SoundData?
--- 
--- @return love.SoundData?
---
function AssetFrontEnd:cacheSound(key, sound)
    self._soundCache[key] = sound
    return sound
end

---
--- @param  path  string
--- 
--- @return love.SoundData?
---
function AssetFrontEnd:loadSound(path)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._soundCache[path] then
        local snd = love.sound.newSoundData(path)
        self:cacheSound(path, snd)
    end
    return self._soundCache[path]
end

---
--- @param  path  string
---
function AssetFrontEnd:loadSoundASync(path, onComplete)
    if not path then
        return nil
    end
    if type(path) ~= "string" then
        return path
    end
    if not self._textureCache[path] then
        ---
        --- @param  snd  love.SoundData
        ---
        lily.newSoundData(path):onComplete(function(_, snd)
            self:cacheSound(path, snd)

            if onComplete then
                onComplete(snd)
            end
        end)
    end
end

return AssetFrontEnd