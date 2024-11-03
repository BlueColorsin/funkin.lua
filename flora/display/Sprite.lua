---@diagnostic disable: invisible

local SpriteUtil = require("flora.utils.SpriteUtil")
local AnimationController = require("flora.animation.AnimationController")

--- 
--- A basic 2D object that can render a texture.
--- 
--- @class flora.display.Sprite : flora.display.Object2D
--- 
local Sprite = Object2D:extend("Sprite", ...)
Sprite.defaultAntialiasing = false

---
--- Constructs a new sprite.
--- 
--- @param  x        number                The X coordinate of this sprite on-screen.
--- @param  y        number                The Y coordinate of this sprite on-screen.
--- @param  texture  flora.assets.Texture  The texture used to render this sprite.
---
function Sprite:constructor(x, y, texture)
    Sprite.super.constructor(self, x, y)

    -- These four have to be nil for the getters to work
    self.frameWidth = nil
    self.frameHeight = nil

    self.width = nil
    self.height = nil

    ---
    --- The frame collection to used to render this sprite.
    ---
    --- @type flora.animation.FrameCollection?
    ---
    self.frames = nil

    ---
    --- The texture attached to this sprite's frame collection.
    ---
    --- @type flora.assets.Texture?
    ---
    self.texture = nil

    ---
    --- The total number of frames in the parent
    --- sprite's texture.
    --- 
    --- @type integer
    ---
    self.numFrames = nil

    ---
    --- The current frame to used to render this sprite.
    ---
    --- @type flora.animation.FrameData?
    ---
    self.frame = nil

    ---
    --- The X and Y offset of this sprite. (not accounting for rotation)
    ---
    --- @type flora.math.Vector2
    ---
    self.offset = Vector2:new(0, 0)

    ---
    --- The X and Y offset of this sprite. (accounting for rotation)
    ---
    --- @type flora.math.Vector2
    ---
    self.frameOffset = Vector2:new(0, 0)

    ---
    --- The X and Y scale factor of this sprite.
    ---
    --- @type flora.math.Vector2
    ---
    self.scale = Vector2:new(1, 1)

    ---
    --- The X and Y rotation origin of this sprite. (from 0 to 1)
    ---
    --- @type flora.math.Vector2
    ---
    self.origin = Vector2:new(0.5, 0.5)

    ---
    --- Controls how much this sprite can scroll on a camera.
    ---
    --- @type flora.math.Vector2
    ---
    self.scrollFactor = Vector2:new(1, 1)

    ---
    --- Controls whether or not this sprite is
    --- flipped on the X axis.
    ---
    --- @type boolean
    ---
    self.flipX = false

    ---
    --- Controls whether or not this sprite is
    --- flipped on the Y axis.
    ---
    --- @type boolean
    ---
    self.flipY = false

    ---
    --- The rotation of this sprite. (in degrees)
    --- 
    --- @type number
    ---
    self.angle = nil

    ---
    --- The tint of this sprite.
    --- 
    --- @type flora.utils.Color|integer
    ---
    self.tint = nil

    ---
    --- The alpha multiplier of this sprite.
    --- 
    --- @type number
    ---
    self.alpha = 1.0

    ---
    --- Whether or not antialiasing is enabled on this sprite.
    --- If you have pixel-art loaded onto it, turn this off!
    ---
    self.antialiasing = Sprite.defaultAntialiasing

    ---
    --- The object responsible for controlling this sprite's animation.
    --- 
    --- @type flora.animation.AnimationController
    ---
    self.animation = AnimationController:new(self)

    ---
    --- @protected
    --- @type flora.utils.Color 
    ---
    self._tint = Color:new(Color.WHITE)

    ---
    --- @protected
    --- @type number
    ---
    self._angle = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._cosAngle = 1.0

    ---
    --- @protected
    --- @type number
    ---
    self._sinAngle = 0.0

    ---
    --- @protected
    --- @type flora.animation.FrameCollection?
    ---
    self._frames = nil

    ---
    --- @protected
    --- @type flora.animation.FrameData?
    ---
    self._frame = nil

    self:loadTexture(texture)
end

---
--- Loads a given texture onto this sprite.
--- 
--- @param  texture      flora.assets.Texture?|string  The texture to load onto this sprite.
--- @param  animated     boolean?                      Whether or not the texture is animated.
--- @param  frameWidth   number?                       The width of each frame in the texture.
--- @param  frameHeight  number?                       The height of each frame in the texture.
--- 
--- @return flora.display.Sprite
---
function Sprite:loadTexture(texture, animated, frameWidth, frameHeight)
    animated = animated ~= nil and animated or false
    texture = Flora.assets:loadTexture(texture)

    if not texture then
        return self
    end
    frameWidth = frameWidth and frameWidth or 0
    frameHeight = frameHeight and frameHeight or 0

    if frameWidth == 0 then
        frameWidth = animated and texture.height or texture.width
        frameWidth = (frameWidth > texture.width) and texture.width or frameWidth
   
    elseif frameWidth > texture.width then
        Flora.log:warn('frameWidth:' .. frameWidth .. ' is larger than the graphic\'s width:' .. texture.width)
    end

    if frameHeight == 0 then
        frameHeight = animated and frameWidth or texture.height
        frameHeight = (frameHeight > texture.height) and texture.height or frameHeight
    
    elseif frameHeight > texture.height then
        Flora.log:warn('frameHeight:' ..frameHeight .. ' is larger than the graphic\'s height:' .. texture.height)
    end

    if animated then
        self.frames = TileFrames.fromTexture(texture, Vector2:new(frameWidth, frameHeight))
    else
        self.frames = FrameCollection.fromTexture(texture)
    end
    return self
end

---
--- Generates a texture of a given width and height
--- and fills it's pixels with a given color.
---
--- @param  width   integer                    The width of the generated texture. (in pixels)
--- @param  height  integer                    The height of the generated texture. (in pixels)
--- @param  color   flora.utils.Color|integer  The color of the pixels in the generated texture.
---
--- @return flora.display.Sprite
---
function Sprite:makeTexture(width, height, color)
    self.antialiasing = false
    self:loadTexture(SpriteUtil.makeRectangle(width, height, color))
    return self
end

---
--- Acts similarily to `makeTexture()`, but instead generating
--- a 1x1 texture with the given color, then setting this
--- sprite's scale to the given width and height.
--- 
--- This is preferred over `makeTexture()`, however it is still
--- available if you absolutely need to use it.
---
--- @param  width   integer                    The width of the sprite. (in pixels)
--- @param  height  integer                    The height of the sprite. (in pixels)
--- @param  color   flora.utils.Color|integer  The color of the generated texture.
---
--- @return flora.display.Sprite
---
function Sprite:makeSolid(width, height, color)
    self:makeTexture(1, 1, color)
    self.scale:set(width, height)
    return self
end

---
--- @param  width?   number
--- @param  height?  number
---
function Sprite:setGraphicSize(width, height)
    width = width or 0.0
    height = height or 0.0

    if width <= 0 and height <= 0 then
        return
    end
    local newScaleX = width / self.frameWidth
    local newScaleY = height / self.frameHeight
    self.scale:set(newScaleX, newScaleY)

    if width <= 0 then
        self.scale.x = newScaleY
    elseif height <= 0 then
        self.scale.y = newScaleX
    end
end

function Sprite:update(dt)
    self.animation:update(dt)
end

function Sprite:draw()
    if not self.frames or not self.frame or not self.frame.quad or self.alpha <= 0 then
        return
    end
    local filter = self.antialiasing and "linear" or "nearest"
    self.texture.image:setFilter(filter, filter)

    local otx = self.origin.x * self.frameWidth
    local oty = self.origin.y * self.frameHeight

    local ox = self.origin.x * self.width
    local oy = self.origin.y * self.height

    self.tint.a = self.alpha

    for i = 1, #self.cameras do
        ---
        --- @type flora.display.Camera
        ---
        local cam = self.cameras[i]

        local curAnim = self.animation.curAnim

        local rx = (self.x - self.offset.x) + ox
        local ry = (self.y - self.offset.y) + oy

        local offx = ((curAnim and curAnim.offset.x or 0.0) - self.frameOffset.x) * (self.scale.x < 0 and -1 or 1)
        local offy = ((curAnim and curAnim.offset.y or 0.0) - self.frameOffset.y) * (self.scale.x < 0 and -1 or 1)

        offx = offx - (self.frame.offset.x * (self.scale.x < 0 and -1 or 1))
        offy = offy - (self.frame.offset.y * (self.scale.y < 0 and -1 or 1))

        offx = offx - (cam.scroll.x * self.scrollFactor.x)
        offy = offy - (cam.scroll.y * self.scrollFactor.y)

        rx = rx + ((offx * math.abs(self.scale.x)) * self._cosAngle + (offy * math.abs(self.scale.y)) * -self._sinAngle)
	    ry = ry + ((offx * math.abs(self.scale.x)) * self._sinAngle + (offy * math.abs(self.scale.y)) * self._cosAngle)

        local sx = self.scale.x * (self.flipX and -1.0 or 1.0)
        local sy = self.scale.y * (self.flipY and -1.0 or 1.0)

        cam:drawFrame(
            self.texture, self.frame, rx, ry,
            self.frame.width * sx, self.frame.height * sy,
            self.angle, otx, oty, self.tint
        )
    end
end

function Sprite:dispose()
    Sprite.super.dispose(self)

    if Flora.config.debugMode then
        Flora.log:verbose("Unreferencing texture on sprite " .. tostring(self))
    end
    self.frames = nil

    if Flora.config.debugMode then
        Flora.log:verbose("Removing extra vars on sprite " .. tostring(self))
    end
    self.scale = nil
    self.origin = nil

    self._tint = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Sprite:get_frames()
    return self._frames
end

---
--- @protected
---
function Sprite:get_texture()
    if self.frames then
        return self.frames.texture
    end
    return nil
end

---
--- @protected
---
function Sprite:get_angle()
    return self._angle
end

---
--- @protected
---
function Sprite:get_frameWidth()
    if self.animation.curAnim then
        local firstFrame = self.animation.curAnim.frames[1]
        return firstFrame.width
    end
    return self.frame and self.frame.width or 0.0
end
    
---
--- @protected
---
function Sprite:get_width()
    return self.frameWidth * math.abs(self.scale.x)
end

---
--- @protected
---
function Sprite:get_frameHeight()
    if self.animation.curAnim then
        local firstFrame = self.animation.curAnim.frames[1]
        return firstFrame.height
    end
    return self.frame and self.frame.height or 0.0
end
    
---
--- @protected
---
function Sprite:get_height()
    return self.frameHeight * math.abs(self.scale.y)
end

---
--- @protected
---
function Sprite:get_tint()
    return self._tint
end

---
--- @protected
---
function Sprite:get_frame()
    return self._frame
end

---
--- @protected
---
function Sprite:get_numFrames()
    if self.frames then
        return self.frames.numFrames
    end
    return 0
end

---
--- @protected
---
function Sprite:set_frame(val)
    self._frame = val
    return self._frame
end

---
--- @protected
---
function Sprite:set_frames(val)
    if val then
        if self._frames then
            self._frames:unreference()
        end
        self._frames = val
        self._frames:reference()
        
        self.frame = self._frames.frames[1]
        
        self.animation.animations = {}
        self.animation.curAnim = nil
    end
    return self._frames
end

---
--- @protected
---
function Sprite:set_angle(val)
    self._angle = val

    local radianAngle = math.rad(val)
    self._cosAngle = math.cos(radianAngle)
    self._sinAngle = math.sin(radianAngle)

    return self._angle
end

---
--- @protected
---
function Sprite:set_tint(val)
    self._tint = Color:new(val)
    return self._tint
end

return Sprite