local color = require("flora.utils.color")
local camera = require("flora.display.camera")

---
--- Accessed via `flora.cameras`.
---
--- @class flora.frontends.camera_front_end : flora.base.basic
---
local camera_front_end = basic:extend("camera_front_end", ...)

---
--- @type table
---
camera_front_end.default_cameras = {}

function camera_front_end:constructor()
    camera_front_end.super.constructor(self)

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
    self._bg_color = color:new(color.blue)
end

function camera_front_end:update(dt)
    self.list:update(dt)
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
    camera_front_end.default_cameras = {cam}

    self.list:add(cam)
end

function camera_front_end:add(cam, default)
    if table.contains(self.list.members, cam) then
        flora.log:warn("Camera was already added!")
        return
    end
    if default then
        table.insert(camera_front_end.default_cameras, cam)
    end
    self.list:add(cam)
end

function camera_front_end:insert(pos, cam, default)
    if table.contains(self.list.members, cam) then
        flora.log:warn("Camera was already added!")
        return
    end
    if default then
        table.insert(camera_front_end.default_cameras, cam)
    end
    self.list:insert(pos, cam)
end

function camera_front_end:remove(cam)
    if not table.contains(self.list.members, cam) then
        flora.log:warn("Cannot remove camera that was not yet added!")
        return
    end
    local default_idx = table.index_of(camera_front_end.default_cameras, cam)
    if default_idx ~= 1 then
        table.remove(camera_front_end.default_cameras, default_idx)
    end
    self.list:remove(cam)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function camera_front_end:get_bg_color()
    return self._bg_color
end

---
--- @protected
---
function camera_front_end:set_bg_color(var, val)
    self._bg_color = color:new(val)
    return self._bg_color
end

return camera_front_end