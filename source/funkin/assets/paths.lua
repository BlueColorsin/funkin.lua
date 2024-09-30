---
--- @class funkin.assets.Paths
---
local Paths = Class:extend()

function Paths.asset(name)
    return "assets/" .. name
end

---
--- @param  type  string
--- 
--- @return table
---
function Paths.getExtsForType(type)
    if type == "image" then
        return {".png", ".tga", ".exr"}

    elseif type == "sound" or type == "audio" then
        return {".ogg", ".oga", ".ogv", ".wav", ".mp3"}
    end
    return {}
end

---
--- @param  type  string
--- @param  path  string
--- 
--- @return string
---
function Paths.suffixExtFromType(type, path)
    local exts = Paths.getExtsForType(type)
    for i = 1, #exts do
        local ppath = path .. exts[i]
        if love.filesystem.getInfo(ppath, "file") then
            return ppath
        end
    end
    return path
end

---
--- @param  name  string
--- @param  dir   string?
--- 
--- @return string
---
function Paths.image(name, dir)
    return Paths.suffixExtFromType("image", Paths.asset(Path.join({dir and dir or "images", name})))
end

---
--- @param  name  string
--- @param  dir   string?
--- 
--- @return string
---
function Paths.music(name, dir)
    return Paths.suffixExtFromType("sound", Paths.asset(Path.join({dir and dir or "music", name, "music"})))
end

---
--- @param  name  string
--- @param  dir   string?
--- 
--- @return string
---
function Paths.sound(name, dir)
    return Paths.suffixExtFromType("sound", Paths.asset(Path.join({dir and dir or "sounds", name})))
end

---
--- @param  name  string
--- @param  dir   string?
--- 
--- @return flora.display.animation.AtlasFrames
---
function Paths.getSparrowAtlas(name, dir)
    local img = Paths.image(name, dir)
    local xml = Path.withoutExtension(img) .. ".xml"
    
    -- TODO: cache that shit
    return AtlasFrames.fromSparrow(img, xml)
end

return Paths