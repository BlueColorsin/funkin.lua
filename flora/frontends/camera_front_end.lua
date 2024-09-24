local color = require("flora.utils.color")
local camera = require("flora.display.camera")

---
--- Accessed via `flora.cameras`.
---
--- @class flora.frontends.camera_front_end
---
local camera_front_end = class:extend()

function camera_front_end:constructor()
    ---
    --- The list of all available cameras.
    --- 
    --- @type flora.display.group
    ---
    self.list = group:new()

    ---
    --- The background color of any new camera.
    ---
    self.bg_color = nil

    ---
    --- @protected
    --- @type flora.utils.color
    ---
    self._bg_color = color:new():copy_from(color.black)
end

function camera_front_end:reset(cam)
    for _, existing_cam in ipairs(self.list) do
        if existing_cam ~= nil then
            existing_cam:dispose()
            self.list:remove(existing_cam)
        end
    end
    if not cam then
        cam = camera:new()
    end
    flora.camera = cam
    self.list:add(cam)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function camera_front_end:__get(var)
    if var == "bg_color" then
        return self._bg_color
    end
    return nil
end

---
--- @protected
---
function camera_front_end:__set(var, val)
    if var == "bg_color" then
        self._bg_color = color:new():copy_from(val)
        return false
    end
    return true
end

return camera_front_end