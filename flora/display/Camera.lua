local Color = require("flora.utils.Color")
local Object2D = require("flora.display.Object2D")

--- 
--- An object that all objects must render to.
--- 
--- @class flora.display.Camera : flora.display.Object2D
--- 
local Camera = Object2D:extend("Camera", ...)

---
--- Constructs a new camera.
---
function Camera:constructor(x, y, width, height)
    Camera.super.constructor(
        self, x, y,
        width and width or Flora.gameWidth,
        height and height or Flora.gameHeight
    )

    ---
    --- The background color of this camera.
    ---
    --- @type flora.utils.Color
    ---
    self.bgColor = nil

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
    --- The scroll offset of this camera.
    --- 
    --- @type flora.math.Vector2
    ---
    self.scroll = Vector2:new()

    ---
    --- @protected
    --- @type flora.utils.Color
    ---
    self._bgColor = Color:new(Flora.cameras.bgColor) 

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
    --- @type flora.utils.Color
    ---
    self._flashFxColor = Color:new(Color.WHITE)

    ---
    --- @protected
    --- @type number
    ---
    self._flashFxDuration = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._flashFxAlpha = 0.0

    ---
    --- @protected
    --- @type function
    ---
    self._flashFadeComplete = nil

    ---
    --- @protected
    --- @type boolean
    ---
    self._fadeFxIn = false

    ---
    --- @protected
    --- @type flora.utils.Color
    ---
    self._fadeFxColor = Color:new(Color.WHITE)

    ---
    --- @protected
    --- @type number
    ---
    self._fadeFxDuration = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._fadeFxAlpha = 0.0

    ---
    --- @protected
    --- @type function
    ---
    self._fadeFxComplete = nil
end

---
--- Clears what was drawn to this camera and
--- resets it back to just it's background color.
---
function Camera:clear()
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(self.bgColor.r, self.bgColor.g, self.bgColor.b, self.bgColor.a)
    
    love.graphics.clear()
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)
end

function Camera:attach(do_push)
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

function Camera:detach()
	love.graphics.pop()
end

---
--- Resizes this camera to the given width and height.
---
--- @param  width   number  The new width of this camera.
--- @param  height  number  The new height of this camera.
---
function Camera:resize(width, height)
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
--- @param  texture   flora.assets.Texture  The texture to draw to the camera.
--- @param  x         number                The X coordinate to draw the given texture at. (in pixels)
--- @param  y         number                The Y coordinate to draw the given texture at. (in pixels)
--- @param  width     number                The width to draw the given texture at. (in pixels)
--- @param  height    number                The height to draw the given texture at. (in pixels)
--- @param  angle     number                The rotation to draw the given texture at. (in degrees)
--- @param  origin_x  number                The rotation origin to draw the given texture at. (x axis, in pixels)
--- @param  origin_y  number                The rotation origin to draw the given texture at. (y axis, in pixels)
--- @param  tint      flora.utils.Color     The tint applied to the given texture when drawing it.
---
function Camera:draw_texture(texture, x, y, width, height, angle, origin_x, origin_y, tint)
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
--- Draws an animation frame to this camera with some other given parameters applied.
--- 
--- @param  texture   flora.assets.Texture               The texture to draw to the camera.
--- @param  frame     flora.display.animation.FrameData  The frame data used for clipping the texture when drawing it.
--- @param  x         number                             The X coordinate to draw the given texture at. (in pixels)
--- @param  y         number                             The Y coordinate to draw the given texture at. (in pixels)
--- @param  width     number                             The width to draw the given texture at. (in pixels)
--- @param  height    number                             The height to draw the given texture at. (in pixels)
--- @param  angle     number                             The rotation to draw the given texture at. (in degrees)
--- @param  origin_x  number                             The rotation origin to draw the given texture at. (x axis, in pixels)
--- @param  origin_y  number                             The rotation origin to draw the given texture at. (y axis, in pixels)
--- @param  tint      flora.utils.Color                  The tint applied to the given texture when drawing it.
---
function Camera:drawFrame(texture, frame, x, y, width, height, angle, origin_x, origin_y, tint)
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(tint.r, tint.g, tint.b, tint.a)

    self:attach()
    
    love.graphics.draw(
        texture.image, frame.quad, x, y, math.rad(angle),
        width / frame.width, height / frame.height,
        origin_x, origin_y
    )
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)

    self:detach()
end

---
--- Draws a sprite batch to this camera with some other given parameters applied.
--- 
--- @param  batch     love.SpriteBatch                   The sprite batch to draw to the camera.
--- @param  x         number                             The X coordinate to draw the given texture at. (in pixels)
--- @param  y         number                             The Y coordinate to draw the given texture at. (in pixels)
--- @param  width     number                             The width to draw the given texture at. (in pixels)
--- @param  height    number                             The height to draw the given texture at. (in pixels)
--- @param  angle     number                             The rotation to draw the given texture at. (in degrees)
--- @param  origin_x  number                             The rotation origin to draw the given texture at. (x axis, in pixels)
--- @param  origin_y  number                             The rotation origin to draw the given texture at. (y axis, in pixels)
--- @param  tint      flora.utils.Color                  The tint applied to the given texture when drawing it.
---
function Camera:drawSpriteBatch(batch, x, y, width, height, angle, origin_x, origin_y, tint)
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(tint.r, tint.g, tint.b, tint.a)

    self:attach()
    
    local texture = batch:getTexture()
    love.graphics.draw(
        batch, x, y, math.rad(angle),
        width / texture:getWidth(), height / texture:getHeight(),
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
--- @param  tint      flora.utils.Color     The color applied to the rectangle when drawing it.
---
function Camera:drawRect(x, y, width, height, angle, origin_x, origin_y, color)
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(color.r, color.g, color.b, color.a)

    love.graphics.push()
    love.graphics.translate(-origin_x, -origin_y)
    love.graphics.rotate(math.rad(angle))

    self:attach(false)
    love.graphics.rectangle("fill", x, y, width, height)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)

    self:detach()
end

function Camera:flash(flashColor, flashDuration, onComplete, force)
    if not force and self._flashFxAlpha > 0.0 then
        return
    end
    self._flashFxColor = Color:new(flashColor)
    self._flashFxDuration = flashDuration
    self._flashFxAlpha = 0.99999
    self._flashFadeComplete = onComplete
end

function Camera:fade(fadeColor, fadeDuration, fadeIn, onComplete, force)
    if not force and self._fadeFxAlpha > 0.0 then
        return
    end
    self._fadeFxColor = Color:new(fadeColor)
    self._fadeFxDuration = fadeDuration
    self._fadeFxIn = fadeIn
    self._fadeFxAlpha = fadeIn and 0.99999 or 0.00001
    self._fadeFxComplete = onComplete
end

function Camera:updateFlash(dt)
    if self._flashFxDuration > 0.0 then
        self._flashFxAlpha = self._flashFxAlpha - (dt / self._flashFxDuration)
        
        if self._flashFxAlpha <= 0.0 then
            self._flashFxAlpha = 0.0
            self._flashFxDuration = 0.0
            
            if self._flashFadeComplete then
                self._flashFadeComplete()
            end
        end
    end
end

function Camera:updateFade(dt)
    if self._fadeFxDuration > 0.0 then
        if self._fadeFxIn then
            self._fadeFxAlpha = self._fadeFxAlpha - (dt / self._fadeFxDuration)
            
            if self._fadeFxAlpha <= 0.0 then
                self._fadeFxAlpha = 0.0
                self._fadeFxDuration = 0.0
                
                if self._fadeFxComplete then
                    self._fadeFxComplete()
                end
            end
    
        else
            self._fadeFxAlpha = self._fadeFxAlpha + (dt / self._fadeFxDuration)
            
            if self._fadeFxAlpha >= 1.0 then
                self._fadeFxAlpha = 1.0
                self._fadeFxDuration = 0.0
    
                if self._fadeFxComplete then
                    self._fadeFxComplete()
                end
            end
        end
    end
end

---
--- Updates this cameras's properties and fields.
---
function Camera:update(dt)
    self:updateFlash(dt)
    self:updateFade(dt)
end

function Camera:draw_fx()
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)

    if self._flashFxAlpha > 0.0 then
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(self._flashFxColor.r, self._flashFxColor.g, self._flashFxColor.b, self._flashFxColor.a * self._flashFxAlpha)

        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        love.graphics.setColor(pr, pg, pb, pa)
    end

    if self._fadeFxAlpha > 0.0 then
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(self._fadeFxColor.r, self._fadeFxColor.g, self._fadeFxColor.b, self._fadeFxColor.a * self._fadeFxAlpha)

        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        love.graphics.setColor(pr, pg, pb, pa)
    end

    love.graphics.setCanvas(prev_canvas)
end

---
--- Draws this camera to the screen.
---
function Camera:draw()
    self:draw_fx()
    love.graphics.draw(self._canvas, self.x, self.y)
end

---
--- Removes this object and it's properties from memory.
---
function Camera:dispose()
    Camera.super.dispose(self)

    self._bgColor = nil

    self._canvas:release()
    self._canvas = nil

    self._fadeFxColor = nil
    self._fadeFxComplete = nil

    self._flashFxColor = nil
    self._flash_fx_complete = nil
end

---
--- Returns a string representation of this object.
---
function Camera:__tostring()
    return "camera"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Camera:get_bgColor()
    return self._bgColor
end

---
--- @protected
---
function Camera:get_zoom()
    return self._zoom
end

---
--- @protected
---
function Camera:set_bgColor(val)
    self._bgColor = Color:new(val)
    return self._bgColor
end

---
--- @protected
---
function Camera:set_zoom(val)
    self._zoom = val
    return self._zoom
end

return Camera