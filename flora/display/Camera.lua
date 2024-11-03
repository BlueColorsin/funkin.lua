local Color = require("flora.utils.Color")
local Object2D = require("flora.display.Object2D")
local Rect2    = require("flora.math.Rect2")

--- 
--- An object that all objects must render to.
--- 
--- @class flora.display.Camera : flora.display.Object2D
--- 
local Camera = Object2D:extend("Camera", ...)

Camera.defaultAntialiasing = false

-- TODO: shake effect

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
    --- @type flora.utils.Color|integer
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
    --- Whether or not antialiasing is enabled on this camera.
    --- If you have a bunch of pixel-art displayed onto it, leave this off!
    ---
    self.antialiasing = Camera.defaultAntialiasing

    ---
    --- The scroll offset of this camera.
    --- 
    --- @type flora.math.Vector2
    ---
    self.scroll = Vector2:new()

    ---
    --- The object that this camera is following.
    --- 
    --- @type flora.display.Object2D
    ---
    self.target = nil

    ---
    --- The offset used when following the target.
    --- 
    --- @type flora.math.Vector2
    ---
    self.targetOffset = Vector2:new()

    ---
    --- The follow style of this camera
    ---
    --- @type "lockon"|"platformer"|"topdown"|"topdown_tight"|"screen_by_screen"|"no_dead_zone"
    ---
    self.style = "lockon"

    ---
    --- Determines the speed of this camera when following.
    ---
    --- @type number
    ---
    self.followLerp = 1

    ---
    --- Used to force the camera to look ahead of the target.
    ---
    --- @type flora.math.Vector2
    ---
    self.followLead = Vector2:new()

    ---
    --- A rectangle to keep the currently targetted object
    --- within when following it.
    ---
    --- @type flora.math.Rect2
    ---
    self.deadzone = nil

    ---
    --- Lower bound of the camera's `scroll` on the x axis.
    --- 
    --- @type number
    ---
    self.minScrollX = nil
    
    ---
    --- Upper bound of the camera's `scroll` on the x axis.
    ---
    --- @type number
    ---
    self.maxScrollX = nil
    
    ---
    --- Lower bound of the camera's `scroll` on the x axis.
    ---
    --- @type number
    ---
    self.minScrollY = nil

    ---
    --- Upper bound of the camera's `scroll` on the y axis.
    ---
    --- @type number
    ---
    self.maxScrollY = nil

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

    ---
    --- @protected
    --- @type flora.math.Vector2
    ---
    self._lastTargetPosition = nil

    ---
    --- @protected
    --- @type flora.math.Vector2
    ---
    self._scrollTarget = Vector2:new()

    ---
    --- @protected
    --- @type flora.math.Vector2
    ---
    self._point = Vector2:new()

    ---
    --- @protected
    --- @type table<table>
    ---
    self._drawQueue = {}
end

---
--- Clears what was drawn to this camera and
--- resets it back to just it's background color.
---
function Camera:clear()
    -- TODO: make this do something..maybe?
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(self.bgColor.r, self.bgColor.g, self.bgColor.b, self.bgColor.a)

    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(pr, pg, pb, pa)
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
--- @param  target  flora.display.Object2D                                                              The object to follow.
--- @param  style   "lockon"|"platformer"|"topdown"|"topdown_tight"|"screen_by_screen"|"no_dead_zone"?  The follow style to use.
--- @param  lerp    number?                                                                             How much lag the camera should have (can help smooth out the camera movement).                                                                 
---
function Camera:follow(target, style, lerp)
    if style == nil then
        style = "lockon"
    end
    if lerp == nil then
        lerp = 1
    end
    self.style = style
    self.target = target
    self.followLerp = lerp

    self._lastTargetPosition = nil
    self.deadzone = nil

    if style == "lockon" then
        local w = 0.0
        local h = 0.0
        if self.target then
            w = self.target.width
            h = self.target.height
        end
        self.deadzone = Rect2:new((self.width - w) / 2, (self.height - h) / 2 - h * 0.25, w, h)

    elseif style == "platformer" then
        local w = self.width / 8
        local h = self.height / 3
        self.deadzone = Rect2:new((self.width - w) / 2, (self.height - h) / 2 - h * 0.25, w, h)

    elseif style == "topdown" then
        local helper = math.max(self.width, self.height) / 4
        self.deadzone = Rect2:new((self.width - helper) / 2, (self.height - helper) / 2, helper, helper)

    elseif style == "topdown_tight" then
        local helper = math.max(self.width, self.height) / 8
        self.deadzone = Rect2:new((self.width - helper) / 2, (self.height - helper) / 2, helper, helper)

    elseif style == "screen_by_screen" then
        self.deadzone = Rect2:new(0, 0, self.width, self.height)

    elseif style == "no_dead_zone" then
        self.deadzone = nil
    end
end

function Camera:updateFollow()
    if not self.deadzone then
        self.target:getMidpoint(self._point)
        self._point:add(self.targetOffset.x, self.targetOffset.y)
        self:focusOn(self._point)
    else
        local edge = 0.0
        local targetX = self.target.x + self.targetOffset.x
        local targetY = self.target.y + self.targetOffset.y

        if self.style == "screen_by_screen" then
            if targetX >= self.scroll.x + self.width then
                self._scrollTarget.x = self._scrollTarget.x + self.width
            
            elseif targetX < self.scroll.x then
                self._scrollTarget.x = self._scrollTarget.x - self.width
            end
            if targetY >= self.scroll.y + self.height then
                self._scrollTarget.y = self._scrollTarget.y + self.height
            
            elseif targetY < self.scroll.y then
                self._scrollTarget.y = self._scrollTarget.y - self.height
            end
        else
            edge = targetX - self.deadzone.x
            if self._scrollTarget.x > edge then
                self._scrollTarget.x = edge
            end
            edge = targetX + self.target.width - self.deadzone.x - self.deadzone.width
            if self._scrollTarget.x < edge then
                self._scrollTarget.x = edge
            end
            edge = targetY - self.deadzone.y
            if self._scrollTarget.y > edge then
                self._scrollTarget.y = edge
            end
            edge = targetY + self.target.height - self.deadzone.y - self.deadzone.height
            if self._scrollTarget.y < edge then
                self._scrollTarget.y = edge
            end
        end

        if self.target:is(Sprite) then
            if not self._lastTargetPosition then
                self._lastTargetPosition = Vector2:new(self.target.x, self.target.y)
            end
            self._scrollTarget.x = self._scrollTarget.x + (self.target.x - self._lastTargetPosition.x) * self.followLead.x
            self._scrollTarget.y = self._scrollTarget.y + (self.target.y - self._lastTargetPosition.y) * self.followLead.y

            self._lastTargetPosition.x = self.target.x
            self._lastTargetPosition.y = self.target.y
        end

        local adjustedLerp = self.followLerp * Flora.deltaTime * 60.0
        if self.followLerp >= 1 or adjustedLerp >= 1 then
            self.scroll:copyFrom(self._scrollTarget)
        else
            self.scroll.x = math.lerp(self.scroll.x, self._scrollTarget.x, adjustedLerp)
			self.scroll.y = math.lerp(self.scroll.y, self._scrollTarget.y, adjustedLerp)
        end
    end
end

function Camera:updateScroll()
    self:bindScrollPos(self.scroll)
end

function Camera:bindScrollPos(scrollPos)
    local minX = self.minScrollX and self.minScrollX - (self.zoom - 1) * self.width / (2 * self.zoom) or nil
    local maxX = self.maxScrollX and self.maxScrollX + (self.zoom - 1) * self.width / (2 * self.zoom) or nil
    local minY = self.minScrollY and self.minScrollY - (self.zoom - 1) * self.height / (2 * self.zoom) or nil
    local maxY = self.maxScrollY and self.maxScrollY + (self.zoom - 1) * self.height / (2 * self.zoom) or nil

    scrollPos.x = math.clamp(scrollPos.x, minX, maxX and maxX - self.width or nil)
    scrollPos.y = math.clamp(scrollPos.y, minY, maxY and maxY - self.height or nil)
    return scrollPos
end

function Camera:snapToTarget()
    self:updateFollow()
    self.scroll:copyFrom(self._scrollTarget)
end

function Camera:focusOn(vec)
    self.scroll:set(vec.x - self.width * 0.5, vec.y - self.height * 0.5)
end

---
--- Resizes this camera to the given width and height.
---
--- @param  width   number  The new width of this camera.
--- @param  height  number  The new height of this camera.
---
function Camera:resize(width, height)
    self.width = width
    self.height = height
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
--- @param  originX   number                The rotation origin to draw the given texture at. (x axis, in pixels)
--- @param  originY   number                The rotation origin to draw the given texture at. (y axis, in pixels)
--- @param  tint      flora.utils.Color     The tint applied to the given texture when drawing it.
---
function Camera:drawTexture(texture, x, y, width, height, angle, originX, originY, tint)
    table.insert(self._drawQueue, {
        drawType = "texture",
        texture = texture,
        x = x,
        y = y,
        width = width,
        height = height,
        angle = angle,
        originX = originX,
        originY = originY,
        tint = tint
    })
end

---
--- Draws an animation frame to this camera with some other given parameters applied.
--- 
--- @param  texture   flora.assets.Texture               The texture to draw to the camera.
--- @param  frame     flora.animation.FrameData  The frame data used for clipping the texture when drawing it.
--- @param  x         number                             The X coordinate to draw the given texture at. (in pixels)
--- @param  y         number                             The Y coordinate to draw the given texture at. (in pixels)
--- @param  width     number                             The width to draw the given texture at. (in pixels)
--- @param  height    number                             The height to draw the given texture at. (in pixels)
--- @param  angle     number                             The rotation to draw the given texture at. (in degrees)
--- @param  originX   number                             The rotation origin to draw the given texture at. (x axis, in pixels)
--- @param  originY   number                             The rotation origin to draw the given texture at. (y axis, in pixels)
--- @param  tint      flora.utils.Color                  The tint applied to the given texture when drawing it.
---
function Camera:drawFrame(texture, frame, x, y, width, height, angle, originX, originY, tint)    
    table.insert(self._drawQueue, {
        drawType = "frame",
        image = texture.image,
        frame = frame,
        x = x,
        y = y,
        width = width,
        height = height,
        angle = angle,
        originX = originX,
        originY = originY,
        tint = tint
    })
end

---
--- Draws a rectangle to this camera with some other given parameters applied.
--- 
--- @param  x         number                The X coordinate to draw the rectangle at. (in pixels)
--- @param  y         number                The Y coordinate to draw the given texture at. (in pixels)
--- @param  width     number                The width to draw the rectangle at. (in pixels)
--- @param  height    number                The height to draw the rectangle at. (in pixels)
--- @param  angle     number                The rotation to draw the rectangle at. (in degrees)
--- @param  originX   number                The rotation origin to draw the rectangle at. (x axis, in pixels)
--- @param  originY   number                The rotation origin to draw the rectangle at. (y axis, in pixels)
--- @param  tint      flora.utils.Color     The color applied to the rectangle when drawing it.
---
function Camera:drawRect(x, y, width, height, angle, originX, originY, color)
    table.insert(self._drawQueue, {
        drawType = "rect",
        x = x,
        y = y,
        width = width,
        height = height,
        angle = angle,
        originX = originX,
        originY = originY,
        color = color
    })
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
    if self.target then
        self:updateFollow()
    end
    self:updateScroll()
    self:updateFlash(dt)
    self:updateFade(dt)
end

function Camera:drawFX()
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
end

---
--- Draws this camera to the screen.
---
function Camera:draw()
    self:attach()
    love.graphics.setScissor(
        Flora.scaleMode.offset.x, Flora.scaleMode.offset.y,
        Flora.scaleMode.gameSize.x, Flora.scaleMode.gameSize.y
    )
    love.graphics.translate(Flora.scaleMode.offset.x, Flora.scaleMode.offset.y)
    love.graphics.scale(Flora.scaleMode.scale.x, Flora.scaleMode.scale.y)
    
    for i = 1, #self._drawQueue do
        local drawItem = self._drawQueue[i] --- @type table
        if drawItem.drawType == "frame" then
            local tint = drawItem.tint
            local pr, pg, pb, pa = love.graphics.getColor()
            love.graphics.setColor(tint.r, tint.g, tint.b, tint.a)
            
            love.graphics.draw(
                drawItem.image, drawItem.frame.quad, drawItem.x, drawItem.y, math.rad(drawItem.angle),
                drawItem.width / drawItem.frame.width, drawItem.height / drawItem.frame.height,
                drawItem.originX, drawItem.originY
            )
            love.graphics.setColor(pr, pg, pb, pa)

        elseif drawItem.drawType == "texture" then
            local tint = drawItem.tint
            local pr, pg, pb, pa = love.graphics.getColor()
            love.graphics.setColor(tint.r, tint.g, tint.b, tint.a)
            
            love.graphics.draw(
                drawItem.image, drawItem.x, drawItem.y, math.rad(drawItem.angle),
                drawItem.width / drawItem.frame.width, drawItem.height / drawItem.frame.height,
                drawItem.originX, drawItem.originY
            )
            love.graphics.setColor(pr, pg, pb, pa)

        elseif drawItem.drawType == "rect" then
            local color = drawItem.color
            local pr, pg, pb, pa = love.graphics.getColor()
            love.graphics.setColor(color.r, color.g, color.b, color.a)
            
            local w2 = drawItem.width * drawItem.originX
            local h2 = drawItem.height * drawItem.originY

            love.graphics.translate(w2, h2)
            love.graphics.rotate(math.rad(drawItem.angle))
            love.graphics.translate(-w2, -h2)

            love.graphics.rectangle(
                "fill",
                drawItem.x - drawItem.originX, drawItem.y - drawItem.originY,
                drawItem.width, drawItem.height
            )
            love.graphics.setColor(pr, pg, pb, pa)
        end
    end
    self._drawQueue = {}
    self:drawFX()
    
    love.graphics.setScissor()
    self:detach()
end

---
--- Removes this object and it's properties from memory.
---
function Camera:dispose()
    Camera.super.dispose(self)

    self._bgColor = nil

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