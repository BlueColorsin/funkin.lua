local color = require("flora.utils.Color")
local camera = require("flora.display.camera")

---
--- Accessed via `flora.cameras`.
---
--- @class flora.frontends.CameraFrontEnd : flora.base.Basic
---
local CameraFrontEnd = Basic:extend("CameraFrontEnd", ...)

function CameraFrontEnd:constructor()
    CameraFrontEnd.super.constructor(self)

    ---
    --- The list of all available cameras.
    --- 
    --- @type flora.display.Group
    ---
    self.list = Group:new()

    ---
    --- The background color of any new camera.
    ---
    self.bgColor = nil

    ---
    --- @type table
    ---
    self.defaultCameras = {}

    ---
    --- @protected
    --- @type flora.utils.Color
    ---
    self._bgColor = Color:new(Color.BLACK)
end

function CameraFrontEnd:update(dt)
    self.list:update(dt)
end

function CameraFrontEnd:reset(cam)
    for i = 1, self.list.length do
        ---
        --- @type flora.display.Camera
        ---
        local existingCam = self.list.members[i]
        if existingCam then
            existingCam:dispose()
        end
    end
    self.list.members = {}
    self.list.length = 0

    if not cam then
        cam = camera:new()
    end
    Flora.camera = cam
    self.defaultCameras = {cam}
    
    self.list:add(cam)
end

function CameraFrontEnd:add(cam, default)
    if table.contains(self.list.members, cam) then
        Flora.log:warn("Camera was already added!")
        return
    end
    if default then
        table.insert(self.defaultCameras, cam)
    end
    self.list:add(cam)
end

function CameraFrontEnd:insert(pos, cam, default)
    if table.contains(self.list.members, cam) then
        Flora.log:warn("Camera was already added!")
        return
    end
    if default then
        table.insert(self.defaultCameras, cam)
    end
    self.list:insert(pos, cam)
end

function CameraFrontEnd:remove(cam)
    if not table.contains(self.list.members, cam) then
        Flora.log:warn("Cannot remove camera that was not yet added!")
        return
    end
    local defaultIdx = table.index_of(self.defaultCameras, cam)
    if defaultIdx ~= 1 then
        table.remove(self.defaultCameras, defaultIdx)
    end
    self.list:remove(cam)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function CameraFrontEnd:get_bgColor()
    return self._bgColor
end

---
--- @protected
---
function CameraFrontEnd:set_bgColor(val)
    self._bgColor = Color:new(val)
    return self._bgColor
end

return CameraFrontEnd