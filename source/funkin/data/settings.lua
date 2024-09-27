---
--- @class funkin.data.settings
---
local settings = class:extend()

---
--- @protected
--- @type flora.utils.save
---
settings._save = nil

settings.data = {
    ---
    --- @type number
    ---
    hit_window = 180.0,

    ---
    --- @type number
    ---
    song_offset = 50.0
}

function settings.init()
    settings._save = save:new()
    settings._save:bind("settings")

    local do_flush = false
    for key, value in pairs(settings.data) do
        if not settings._save.data[key] then
            settings._save.data[key] = value
            do_flush = true
        else
            settings.data[key] = settings._save.data[key]
        end
    end
    if do_flush then
        settings._save:flush()
    end
end

function settings.save()
    for key, value in pairs(settings.data) do
        settings._save.data[key] = value
    end
    settings._save:flush()
end

return settings