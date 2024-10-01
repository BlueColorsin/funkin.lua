local FrameData = require("flora.display.animation.FrameData")
local FrameCollection = require("flora.display.animation.FrameCollection")

---
--- @class flora.display.animation.TileFrames : flora.display.animation.FrameCollection
---
local TileFrames = FrameCollection:extend("TileFrames", ...)

function TileFrames.fromTexture(texture, tileSize)
    ---
    --- @type flora.assets.Texture?
    ---
	local tex = Flora.assets:loadTexture(texture)

    ---
    --- @type flora.display.animation.TileFrames
    ---
	local atlas = TileFrames:new(tex)

	local numRows = tileSize.y == 0 and 1 or math.round((texture.height) / tileSize.x)
	local numCols = tileSize.x == 0 and 1 or math.round((texture.width) / tileSize.y)

	for j = 1, numRows do
		for i = 1, numCols do
			table.insert(atlas.frames, FrameData:new(
				"frame",
				(i - 1) * tileSize.x, (j - 1) * tileSize.y,
				0, 0, tileSize.x, tileSize.y,
				atlas.texture
			))
		end
	end

	return atlas
end

function TileFrames:dispose()
	TileFrames.super.dispose(self)
end

return TileFrames