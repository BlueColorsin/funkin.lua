---
--- @class flora.display.animation.animation_data
---
local animation_data = class:extend()

---
---@param  name    string
---@param  frames  table<flora.display.animation.frame_data>
---@param  fps     number
---@param  loop    boolean
---
function animation_data:constructor(name, frames, fps, loop)
    self.name = name
    self.fps = fps ~= nil and fps or 30.0
    self.loop = loop
    self.cur_frame = 0
    self.frames = frames
    self.num_frames = #frames
    self.frame_count = self.num_frames
    self.offset = vector2:new(0, 0)
end

return animation_data