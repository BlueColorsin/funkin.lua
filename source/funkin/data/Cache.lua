---
--- @class funkin.data.Cache
---
local Cache = Class:extend()

---
--- A table containing a bunch of atlases (sparrow, packer, etc),
--- stored for later use.
---
Cache.atlasCache = {}

---
--- A table containing a bunch of character data, stored for later use.
---
Cache.characterDataCache = {}

---
--- @param  key   string
--- @param  type  funkin.data.enums.CacheType
--- 
--- @return any
---
function Cache.get(key, type)
    if type == "sparrow" then
        if not Cache.atlasCache[key] then
            Flora.log:warn("Item not found in atlas cache: " .. key)
            return nil
        end
        return Cache.atlasCache[key]

    elseif type == "character_data" then
        if not Cache.characterDataCache[key] then
            Flora.log:warn("Item not found in character data cache: " .. key)
            return nil
        end
        return Cache.characterDataCache[key]
    end
    Flora.log:warn("Cannot get " .. type .. " item from cache")
    return nil
end

---
--- @param  key   string
--- @param  item  any
--- @param  type  funkin.data.enums.CacheType
---
function Cache.add(key, item, type)
    if Settings.data.verboseLogging then
        Flora.log:verbose("Adding " .. type .. " item to cache: " .. key)
    end
    if type == "sparrow" then
        Cache.atlasCache[key] = item
    
    elseif type == "character_data" then
        Cache.characterDataCache[key] = item
    end
end

---
--- Clears all data in the cache immediately.
---
function Cache.clear()
    for _, value in pairs(Cache.atlasCache) do
        value:unreference()
    end
    Cache.atlasCache = {}
    Cache.characterDataCache = {}
end

return Cache