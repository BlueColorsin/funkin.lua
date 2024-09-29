---
--- @class funkin.assets.paths
---
local paths = class:extend()

function paths.asset(name)
    return "assets/" .. name
end

---
--- @param  type  string
--- 
--- @return table
---
function paths.get_exts_for_type(type)
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
function paths.suffix_ext_from_type(type, path)
    local exts = paths.get_exts_for_type(type)
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
function paths.image(name, dir)
    return paths.suffix_ext_from_type("image", paths.asset(path.join({dir and dir or "images", name})))
end

---
--- @param  name  string
--- @param  dir   string?
--- 
--- @return string
---
function paths.music(name, dir)
    return paths.suffix_ext_from_type("sound", paths.asset(path.join({dir and dir or "music", name, "music"})))
end

---
--- @param  name  string
--- @param  dir   string?
--- 
--- @return string
---
function paths.sound(name, dir)
    return paths.suffix_ext_from_type("sound", paths.asset(path.join({dir and dir or "sounds", name})))
end

---
--- @param  name  string
--- @param  dir   string?
--- 
--- @return flora.display.animation.atlas_frames
---
function paths.get_sparrow_atlas(name, dir)
    local img = paths.image(name, dir)
    local xml = path.without_extension(img) .. ".xml"
    
    -- TODO: cache that shit
    return atlas_frames.from_sparrow(img, xml)
end

return paths