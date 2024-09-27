local frame_data = require("flora.display.animation.frame_data")

---
--- @class flora.display.animation.frame_collection : flora.base.ref_counted
---
local frame_collection = ref_counted:extend()

---
--- @param  frames  table<flora.display.animation.frame_data>?
---
function frame_collection:constructor(texture, frames)
    frame_collection.super.constructor(self)

    ---
    --- @type flora.assets.texture?
    ---
    self.texture = flora.assets:load_texture(texture)

    ---
    --- @type table<flora.display.animation.frame_data>
    ---
	self.frames = frames and frames or {}
end

function frame_collection.from_texture(texture)
    ---
    --- @type flora.assets.texture?
    ---
	local tex = flora.assets:load_texture(texture)

    ---
    --- @type flora.display.animation.frame_collection
    ---
	local atlas = frame_collection:new(tex)
	table.insert(atlas.frames, frame_data:new(
		tex.key,
		0, 0, 0, 0,
		tex.width, tex.height,
		tex
	))
	return atlas
end

function frame_collection:dispose()
    for i = 1, #self.frames do
        ---
        --- @type flora.display.animation.frame_data
        ---
        local frame = self.frames[i]
        frame:dispose()
    end
	self.frames = nil
end

return frame_collection