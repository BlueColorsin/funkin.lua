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
        width and width or flora.config.game_width,
        height and height or flora.config.game_height
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
    self._bg_color = color:new(flora.cameras.bg_color) 

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

    ---
    --- @protected
    --- @type flora.utils.color
    ---
    self._flash_fx_color = color:new(color.white)

    ---
    --- @protected
    --- @type number
    ---
    self._flash_fx_duration = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._flash_fx_alpha = 0.0

    ---
    --- @protected
    --- @type function
    ---
    self._flash_fade_complete = nil

    ---
    --- @protected
    --- @type boolean
    ---
    self._fade_fx_in = false

    ---
    --- @protected
    --- @type flora.utils.color
    ---
    self._fade_fx_color = color:new(color.white)

    ---
    --- @protected
    --- @type number
    ---
    self._fade_fx_duration = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._fade_fx_alpha = 0.0

    ---
    --- @protected
    --- @type function
    ---
    self._fade_fx_complete = nil
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

function camera:attach(do_push)
    if do_push == nil or do_push then
        love.graphics.push()
    end
	
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
--- Resizes this camera to the given width and height.
---
--- @param  width   number  The new width of this camera.
--- @param  height  number  The new height of this camera.
---
function camera:resize(width, height)
    if self._canvas then
        self._canvas:release()
    end
    self.width = width
    self.height = height
    self._canvas = love.graphics.newCanvas(self.width, self.height)
end

---
--- Draws a texture to this camera with some other given parameters applied.
--- 
--- @param  texture   flora.assets.texture  The texture to draw to the camera.
--- @param  x         number                The X coordinate to draw the given texture at. (in pixels)
--- @param  y         number                The Y coordinate to draw the given texture at. (in pixels)
--- @param  width     number                The width to draw the given texture at. (in pixels)
--- @param  height    number                The height to draw the given texture at. (in pixels)
--- @param  angle     number                The rotation to draw the given texture at. (in degrees)
--- @param  origin_x  number                The rotation origin to draw the given texture at. (x axis, in pixels)
--- @param  origin_y  number                The rotation origin to draw the given texture at. (y axis, in pixels)
--- @param  tint      flora.utils.color     The tint applied to the given texture when drawing it.
---
function camera:draw_texture(texture, x, y, width, height, angle, origin_x, origin_y, tint)
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
--- Draws a rectangle to this camera with some other given parameters applied.
--- 
--- @param  x         number                The X coordinate to draw the rectangle at. (in pixels)
--- @param  y         number                The Y coordinate to draw the given texture at. (in pixels)
--- @param  width     number                The width to draw the rectangle at. (in pixels)
--- @param  height    number                The height to draw the rectangle at. (in pixels)
--- @param  angle     number                The rotation to draw the rectangle at. (in degrees)
--- @param  origin_x  number                The rotation origin to draw the rectangle at. (x axis, in pixels)
--- @param  origin_y  number                The rotation origin to draw the rectangle at. (y axis, in pixels)
--- @param  tint      flora.utils.color     The color applied to the rectangle when drawing it.
---
function camera:draw_rect(x, y, width, height, angle, origin_x, origin_y, color)
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(color.r, color.g, color.b, color.a)

    love.graphics.push()
    love.graphics.rotate(math.rad(angle))
    love.graphics.translate(-origin_x, -origin_y)

    self:attach(false)
    love.graphics.rectangle("fill", x, y, width, height)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)

    self:detach()
end

function camera:flash(flash_color, flash_duration, on_complete, force)
    if not force and self._flash_fx_alpha > 0.0 then
        return
    end
    self._flash_fx_color = color:new(flash_color)
    self._flash_fx_duration = flash_duration
    self._flash_fx_alpha = 0.99999
    self._flash_fade_complete = on_complete
end

function camera:fade(fade_color, fade_duration, fade_in, on_complete, force)
    if not force and self._fade_fx_alpha > 0.0 then
        return
    end
    self._fade_fx_color = color:new(fade_color)
    self._fade_fx_duration = fade_duration
    self._fade_fx_in = fade_in
    self._fade_fx_alpha = fade_in and 0.99999 or 0.00001
    self._fade_fx_complete = on_complete
end

function camera:update_flash(dt)
    if self._flash_fx_duration > 0.0 then
        self._flash_fx_alpha = self._flash_fx_alpha - (dt / self._flash_fx_duration)
        
        if self._flash_fx_alpha <= 0.0 then
            self._flash_fx_alpha = 0.0
            self._flash_fx_duration = 0.0
            
            if self._flash_fade_complete then
                self._flash_fade_complete()
            end
        end
    end
end

function camera:update_fade(dt)
    if self._fade_fx_duration > 0.0 then
        if self._fade_fx_in then
            self._fade_fx_alpha = self._fade_fx_alpha - (dt / self._fade_fx_duration)
            
            if self._fade_fx_alpha <= 0.0 then
                self._fade_fx_alpha = 0.0
                self._fade_fx_duration = 0.0
                
                if self._fade_fx_complete then
                    self._fade_fx_complete()
                end
            end
    
        else
            self._fade_fx_alpha = self._fade_fx_alpha + (dt / self._fade_fx_duration)
            
            if self._fade_fx_alpha >= 1.0 then
                self._fade_fx_alpha = 1.0
                self._fade_fx_duration = 0.0
    
                if self._fade_fx_complete then
                    self._fade_fx_complete()
                end
            end
        end
    end
end

---
--- Updates this cameras's properties and fields.
---
function camera:update(dt)
    self:update_flash(dt)
    self:update_fade(dt)
end

function camera:draw_fx()
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)

    if self._flash_fx_alpha > 0.0 then
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(self._flash_fx_color.r, self._flash_fx_color.g, self._flash_fx_color.b, self._flash_fx_color.a * self._flash_fx_alpha)

        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        love.graphics.setColor(pr, pg, pb, pa)
    end

    if self._fade_fx_alpha > 0.0 then
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(self._fade_fx_color.r, self._fade_fx_color.g, self._fade_fx_color.b, self._fade_fx_color.a * self._fade_fx_alpha)

        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        love.graphics.setColor(pr, pg, pb, pa)
    end

    love.graphics.setCanvas(prev_canvas)
end

---
--- Draws this camera to the screen.
---
function camera:draw()
    self:draw_fx()
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
        self._bg_color = color:new(val)
        return false
        
    elseif var == "zoom" then
        self._zoom = val
        return false
    end
    return true
end

return camera