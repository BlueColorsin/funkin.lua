local frame_collection = require("flora.display.animation.frame_collection")
local frame_data       = require("flora.display.animation.frame_data")

---
--- @class flora.display.animation.atlas_frames : flora.display.animation.frame_collection
---
local atlas_frames = frame_collection:extend()

function atlas_frames:constructor(texture, frames)
	atlas_frames.super.constructor(self, texture, frames)
	
	self._type = "atlas_frames"
end

---
--- Returns a frame collection from a sparrow atlas.
---
--- @param  texture  flora.assets.texture|string
--- @param  xml      string
---
--- @return flora.display.animation.atlas_frames
---
function atlas_frames.from_sparrow(texture, xml_file)
    ---
    --- @type flora.assets.texture?
    ---
    local tex = flora.assets:load_texture(texture)

    ---
    --- @type flora.display.animation.atlas_frames
    ---
	local atlas = atlas_frames:new(tex)
	local xml_content = file.exists(xml_file) and file.read(xml_file) or xml_file

	local data = xml.parse(xml_content)
	for _, node in ipairs(data.TextureAtlas.children) do
        if node.name == "SubTexture" then
			table.insert(atlas.frames, frame_data:new(
				node.att.name,
				tonumber(node.att.x), tonumber(node.att.y),
				node.att.frameX and tonumber(node.att.frameX) or 0,
				node.att.frameY and tonumber(node.att.frameY) or 0,
				tonumber(node.att.width), tonumber(node.att.height),
				atlas.texture
			))
        end
    end
	return atlas
end

function atlas_frames:dispose()
	atlas_frames.super.dispose(self)
	self.texture:unreference()
end

return atlas_frames