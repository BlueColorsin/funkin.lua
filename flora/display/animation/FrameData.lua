---
--- @class flora.display.animation.FrameData
---
local FrameData = Class:extend("FrameData", ...)

---
--- @param  name      string                The name of this frame.
--- @param  x         number                The X coordinate of this frame. (in pixels)
--- @param  y         number                The Y coordinate of this frame. (in pixels)
--- @param  offset_x  number                The offset of this frame. (x axis, in pixels)
--- @param  offset_y  number                The offset of this frame. (y axis, in pixels)
--- @param  width     number                The width of this frame. (in pixels)
--- @param  height    number                The height of this frame. (in pixels)
--- @param  texture   flora.assets.Texture  The texture to use for this frame.
---
function FrameData:constructor(name, x, y, offset_x, offset_y, width, height, texture)
	self.name = name
	self.x = x and x or 0.0
	self.y = y and y or 0.0

    ---
    --- @type flora.math.Vector2
    ---
    self.offset = Vector2:new(offset_x and offset_x or 0.0, offset_y and offset_y or 0.0)
	
    self.width = width and width or 0.0
	self.height = height and height or 0.0

    ---
    --- @type flora.assets.Texture
    ---
    self.texture = texture
    
    ---
    --- @type love.Quad
    ---
	self.quad = love.graphics.newQuad(self.x, self.y, self.width, self.height, self.texture.image)
end

function FrameData:dispose()
	self.quad:release()
    self.texture:unreference()
end

return FrameData