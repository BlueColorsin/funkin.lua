---
--- @class funkin.data.Settings
---
local Settings = Class:extend()

---
--- @protected
--- @type flora.utils.Save
---
Settings._save = nil

Settings.data = {
    ---
    --- @type number
    ---
    hitWindow = 180.0,

    ---
    --- @type number
    ---
    songOffset = 50.0
}

function Settings.init()
    Settings._save = Save:new()
    Settings._save:bind("settings")

    local do_flush = false
    for key, value in pairs(Settings.data) do
        if not Settings._save.data[key] then
            Settings._save.data[key] = value
            do_flush = true
        else
            Settings.data[key] = Settings._save.data[key]
        end
    end
    if do_flush then
        Settings._save:flush()
    end
end

function Settings.save()
    for key, value in pairs(Settings.data) do
        Settings._save.data[key] = value
    end
    Settings._save:flush()
end

return Settings