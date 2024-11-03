local FrameData = require("flora.animation.FrameData")

---
--- @class flora.animation.FrameCollection : flora.RefCounted
---
local FrameCollection = RefCounted:extend("FrameCollection", ...)

---
--- @param  frames  table<flora.animation.FrameData>?
---
function FrameCollection:constructor(texture, frames)
    FrameCollection.super.constructor(self)

    ---
    --- @type flora.assets.Texture?
    ---
    self.texture = Flora.assets:loadTexture(texture)

    ---
    --- @type table<flora.animation.FrameData>
    ---
	self.frames = frames and frames or {}

    ---
    --- The amount of frames in this frame collection.
    ---
    --- @type integer
    ---
    self.numFrames = nil
end

function FrameCollection.fromTexture(texture)
    ---
    --- @type flora.assets.Texture?
    ---
	local tex = Flora.assets:loadTexture(texture)

    ---
    --- @type flora.animation.FrameCollection
    ---
	local atlas = FrameCollection:new(tex)
	table.insert(atlas.frames, FrameData:new(
		tex.key,
		0, 0, 0, 0,
		tex.width, tex.height,
		tex
	))
	return atlas
end

function FrameCollection:dispose()
    for i = 1, #self.frames do
        ---
        --- @type flora.animation.FrameData
        ---
        local frame = self.frames[i]
        frame:dispose()
    end
	self.frames = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function FrameCollection:get_numFrames()
    return #self.frames
end

return FrameCollection