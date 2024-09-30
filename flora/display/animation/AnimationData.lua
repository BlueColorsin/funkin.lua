---
--- @class flora.display.animation.AnimationData
---
local AnimationData = Class:extend("AnimationData", ...)

---
---@param  name    string
---@param  frames  table<flora.display.animation.FrameData>
---@param  fps     number
---@param  loop    boolean
---
function AnimationData:constructor(name, frames, fps, loop)
    self.name = name
    self.fps = fps ~= nil and fps or 30.0
    self.loop = loop
    self.curFrame = 0
    self.frames = frames
    self.numFrames = #frames
    self.frameCount = self.numFrames
    self.offset = Vector2:new(0, 0)
end

return AnimationData