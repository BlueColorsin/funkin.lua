local color = require("flora.utils.color")
local object2d = require("flora.display.object2d")

--- 
--- An object that all objects must render to.
--- 
--- @class flora.display.camera : flora.display.object2d
--- 
local camera = object2d:extend()

---
--- Constructs a new camera.
---
function camera:constructor(x, y, width, height)
    camera.super.constructor(
        self, x, y,
        width and width or flora.config.game_size.x,
        height and height or flora.config.game_size.y
    )

    ---
    --- The background color of this camera.
    ---
    --- @type flora.utils.color
    ---
    self.bg_color = nil

    ---
    --- The zoom multiplier of this camera.
    ---
    --- @type number
    ---
    self.zoom = nil

    --- 
    --- The rotation of this camera. (in degrees)
    --- 
    self.angle = 0.0

    ---
    --- @protected
    --- @type flora.utils.color
    ---
    self._bg_color = color:new():copy_from(flora.cameras.bg_color) 

    ---
    --- @protected
    --- @type number
    ---
    self._zoom = 1.0

    ---
    --- @protected
    --- @type love.Canvas
    ---
    self._canvas = love.graphics.newCanvas(self.width, self.height)
end

---
--- Clears what was drawn to this camera and
--- resets it back to just it's background color.
---
function camera:clear()
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(self.bg_color.r, self.bg_color.g, self.bg_color.b, self.bg_color.a)
    
    love.graphics.clear()
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)
end

function camera:attach()
    love.graphics.push()
	
	local w2 = self.width * 0.5
	local h2 = self.height * 0.5
	love.graphics.scale(self.zoom)

	love.graphics.translate((w2 / self.zoom) - w2, (h2 / self.zoom) - h2)
	love.graphics.translate(w2, h2)

	love.graphics.rotate(math.rad(self.angle))
	love.graphics.translate(-w2, -h2)
end

function camera:detach()
	love.graphics.pop()
end

---
--- Draws a texture to this camera with some
--- other given parameters applied.
--- 
--- @param  texture  flora.assets.texture  The texture to draw to the camera.
---
function camera:draw_pixels(texture, x, y, width, height, angle, origin_x, origin_y, tint)
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(tint.r, tint.g, tint.b, tint.a)

    self:attach()
    
    love.graphics.draw(
        texture.image, x, y, math.rad(angle),
        width / texture.width, height / texture.height,
        origin_x, origin_y
    )
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)

    self:detach()
end

---
--- Draws this camera to the screen.
---
function camera:draw()
    love.graphics.draw(self._canvas, self.x, self.y)
end

---
--- Removes this object and it's properties from memory.
---
function camera:dispose()
    self.bg_color = nil

    self._canvas:release()
    self._canvas = nil
end

---
--- Returns a string representation of this object.
---
function camera:__tostring()
    return "camera"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function camera:__get(var)
    if var == "bg_color" then
        return self._bg_color

    elseif var == "zoom" then
        return self._zoom
    end
    return camera.super.__get(self, var)
end

---
--- @protected
---
function camera:__set(var, val)
    if var == "bg_color" then
        self._bg_color = color:new():copy_from(val)
        return false
        
    elseif var == "zoom" then
        self._zoom = val
        return false
    end
    return true
end

return camera