local FrameData = require("flora.display.animation.FrameData")
local FrameCollection = require("flora.display.animation.FrameCollection")

---
--- @class flora.display.animation.AtlasFrames : flora.display.animation.FrameCollection
---
local AtlasFrames = FrameCollection:extend("AtlasFrames", ...)

---
--- Returns a frame collection from a sparrow atlas.
---
--- @param  texture  flora.assets.Texture|string
--- @param  xml      string
---
--- @return flora.display.animation.AtlasFrames
---
function AtlasFrames.fromSparrow(texture, xmlFile)
    ---
    --- @type flora.assets.Texture?
    ---
    local tex = Flora.assets:loadTexture(texture)

    ---
    --- @type flora.display.animation.AtlasFrames
    ---
	local atlas = AtlasFrames:new(tex)
	local xml_content = File.exists(xmlFile) and File.read(xmlFile) or xmlFile

	local data = Xml.parse(xml_content)
	for _, node in ipairs(data.TextureAtlas.children) do
        if node.name == "SubTexture" then
			table.insert(atlas.frames, FrameData:new(
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

return AtlasFrames