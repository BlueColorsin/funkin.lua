local AnimationController = require("flora.display.animation.AnimationController")

--- 
--- A basic 2D object that can render a texture.
--- 
--- @class flora.display.Sprite : flora.display.Object2D
--- 
local Sprite = Object2D:extend("Sprite", ...)
Sprite.default_antialiasing = false

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
    --- @type flora.display.animation.FrameCollection?
    ---
    self.frames = nil

    ---
    --- The texture attached to this sprite's frame collection.
    ---
    --- @type flora.assets.Texture?
    ---
    self.texture = nil

    ---
    --- The current frame to used to render this sprite.
    ---
    --- @type flora.display.animation.FrameData?
    ---
    self.frame = nil

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
    --- The rotation of this sprite. (in degrees)
    --- 
    --- @type number
    ---
    self.angle = nil

    ---
    --- The tint of this sprite.
    --- 
    --- @type flora.utils.Color
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
    self.antialiasing = Sprite.default_antialiasing

    ---
    --- The object responsible for controlling this sprite's animation.
    --- 
    --- @type flora.display.animation.AnimationController
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
    --- @type flora.display.animation.FrameCollection?
    ---
    self._frames = texture and FrameCollection.fromTexture(flora.assets:loadTexture(texture)) or nil

    ---
    --- @protected
    --- @type flora.display.animation.FrameData?
    ---
    self._frame = nil
end

---
--- Loads a given texture onto this sprite.
--- 
--- @param  texture  flora.assets.Texture  The texture to load onto this sprite.
--- 
--- @return flora.display.Sprite
---
function Sprite:loadTexture(texture)
    self.frames = FrameCollection.fromTexture(flora.assets:loadTexture(texture))
    return self
end

---
--- Centers this sprite to the middle of the screen.
---
--- @param  axes  integer  The axes to center this sprite on. (`X`, `Y`, or `XY`)
---
function Sprite:screenCenter(axes)
    if Axes.hasX(axes) then
        self.x = math.floor((flora.gameWidth - self.width) * 0.5)
    end
    if Axes.hasY(axes) then
        self.y = math.floor((flora.gameHeight - self.height) * 0.5)
    end
end

function Sprite:setGraphicSize(width, height)
    self.scale:set(
        width / self.frameWidth,
        height / self.frameHeight
    )
end

function Sprite:update(dt)
    self.animation:update(dt)
end

function Sprite:draw()
    if not self.frames or not self.frame or self.alpha <= 0 then
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

        local rx = self.x + ox
        local ry = self.y + oy

        local offx = curAnim and curAnim.offset.x or 0.0
        local offy = curAnim and curAnim.offset.y or 0.0

        offx = offx - (self.frame.offset.x * (self.scale.x < 0 and -1 or 1))
        offy = offy - (self.frame.offset.y * (self.scale.y < 0 and -1 or 1))

        offx = offx - (cam.scroll.x * self.scrollFactor.x)
        offy = offy - (cam.scroll.y * self.scrollFactor.y)

        rx = rx + (offx * math.abs(self.scale.x)) * self._cosAngle + (offy * math.abs(self.scale.y)) * -self._sinAngle
	    ry = ry + (offx * math.abs(self.scale.x)) * self._sinAngle + (offy * math.abs(self.scale.y)) * self._cosAngle

        cam:drawFrame(
            self.texture, self.frame, rx, ry,
            self.frame.width * self.scale.x, self.frame.height * self.scale.y,
            self.angle, otx, oty, self.tint
        )
    end
end

function Sprite:dispose()
    Sprite.super.dispose(self)

    if flora.config.debugMode then
        flora.log:verbose("Unreferencing texture on sprite " .. tostring(self))
    end
    self.frames = nil

    if flora.config.debugMode then
        flora.log:verbose("Removing extra vars on sprite " .. tostring(self))
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
function Sprite:set_frame(val)
    self._frame = val
    return self._frame
end

---
--- @protected
---
function Sprite:set_frames(val)
    if self._frames then
        self._frames:unreference()
    end
    if val then
        val:reference()
        self.frame = val.frames[1]
    end
    self._frames = val
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