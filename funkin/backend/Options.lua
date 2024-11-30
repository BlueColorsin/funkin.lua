--[[
    Copyright 2024 swordcube

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

local _default_ = "_default_"

---
--- @class funkin.backend.Options
--- 
--- A class for managing options.
---
local Options = {
    ---
    --- @protected
    --- @type chip.utils.Save
    ---
    _save = Save:new(),

    ---
    --- Controls whether or not notes vertically
    --- scroll downwards instead of upwards during gameplay.
    ---
    --- @type boolean
    ---
    downscroll = nil,
    _default_downscroll = false, --- @protected
}

function Options.init()
    local save = Options._save
    save:bind("options", "swordcube/funkin.lua")

    local doFlush = false
    for key, value in pairs(Options) do
        local skey = key:sub(#_default_ + 1)
        if type(value) ~= "function" and key:startsWith(_default_) and save.data[skey] == nil then
            doFlush = true
            save.data[skey] = rawget(Options, key)
        end
    end
    if doFlush then
        Options.save()
    end
end

function Options.save()
    local save = Options._save
    save:flush()
end

setmetatable(Options, {
    __index = function(t, k)
        if k:charAt(0) == "_" then
            return rawget(t, k)
        end
        return Options._save.data[k]
    end,
    __newindex = function(t, k, v)
        if k:charAt(0) == "_" then
            rawset(t, k, v)
            return
        end
        Options._save.data[k] = v
    end
})
return Options