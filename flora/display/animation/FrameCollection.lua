local FrameData = require("flora.display.animation.FrameData")

---
--- @class flora.display.animation.FrameCollection : flora.base.RefCounted
---
local FrameCollection = RefCounted:extend("FrameCollection", ...)

---
--- @param  frames  table<flora.display.animation.FrameData>?
---
function FrameCollection:constructor(texture, frames)
    FrameCollection.super.constructor(self)

    ---
    --- @type flora.assets.Texture?
    ---
    self.texture = flora.assets:loadTexture(texture)

    ---
    --- @type table<flora.display.animation.FrameData>
    ---
	self.frames = frames and frames or {}
end

function FrameCollection.fromTexture(texture)
    ---
    --- @type flora.assets.Texture?
    ---
	local tex = flora.assets:loadTexture(texture)

    ---
    --- @type flora.display.animation.FrameCollection
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
        --- @type flora.display.animation.FrameData
        ---
        local frame = self.frames[i]
        frame:dispose()
    end
	self.frames = nil
end

return FrameCollection