local axes = require("flora.utils.axes")
local color = require("flora.utils.color")
local animation_controller = require("flora.display.animation.animation_controller")

--- 
--- A basic 2D object that can render a texture.
--- 
--- @class flora.display.sprite : flora.display.object2d
--- 
local sprite = object2d:extend()
sprite.default_antialiasing = false

---
--- Constructs a new sprite.
--- 
--- @param  x        number                The X coordinate of this sprite on-screen.
--- @param  y        number                The Y coordinate of this sprite on-screen.
--- @param  texture  flora.assets.texture  The texture used to render this sprite.
---
function sprite:constructor(x, y, texture)
    sprite.super.constructor(self, x, y)

    self._type = "sprite"

    -- These four have to be nil for the getters to work
    self.frame_width = nil
    self.frame_height = nil

    self.width = nil
    self.height = nil

    ---
    --- The frame collection to used to render this sprite.
    ---
    --- @type flora.display.animation.frame_collection?
    ---
    self.frames = nil

    ---
    --- The texture attached to this sprite's frame collection.
    ---
    --- @type flora.assets.texture?
    ---
    self.texture = nil

    ---
    --- The current frame to used to render this sprite.
    ---
    --- @type flora.display.animation.frame_data?
    ---
    self.frame = nil

    ---
    --- The X and Y scale factor of this sprite.
    ---
    --- @type flora.math.vector2
    ---
    self.scale = vector2:new(1, 1)

    ---
    --- The X and Y rotation origin of this sprite. (from 0 to 1)
    ---
    --- @type flora.math.vector2
    ---
    self.origin = vector2:new(0.5, 0.5)

    ---
    --- Controls how much this sprite can scroll on a camera.
    ---
    --- @type flora.math.vector2
    ---
    self.scroll_factor = vector2:new(1, 1)

    ---
    --- The rotation of this sprite. (in degrees)
    --- 
    --- @type number
    ---
    self.angle = nil

    ---
    --- The tint of this sprite.
    --- 
    --- @type flora.utils.color
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
    self.antialiasing = sprite.default_antialiasing

    ---
    --- The object responsible for controlling this sprite's animation.
    --- 
    --- @type flora.display.animation.animation_controller
    ---
    self.animation = animation_controller:new(self)

    ---
    --- @protected
    --- @type flora.utils.color 
    ---
    self._tint = color:new(color.white)

    ---
    --- @protected
    --- @type number
    ---
    self._angle = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._cos_angle = 1.0

    ---
    --- @protected
    --- @type number
    ---
    self._sin_angle = 0.0

    ---
    --- @protected
    --- @type flora.display.animation.frame_collection?
    ---
    self._frames = texture and frame_collection.from_texture(flora.assets:load_texture(texture)) or nil
end

---
--- Loads a given texture onto this sprite.
--- 
--- @param  texture  flora.assets.texture  The texture to load onto this sprite.
--- 
--- @return flora.display.sprite
---
function sprite:load_texture(texture)
    self.frames = frame_collection.from_texture(flora.assets:load_texture(texture))
    return self
end

---
--- Centers this sprite to the middle of the screen.
---
--- @param  center_axes  integer  The axes to center this sprite on. (`X`, `Y`, or `XY`)
---
function sprite:screen_center(center_axes)
    if axes.has_x(center_axes) then
        self.x = math.floor((flora.game_width - self.width) * 0.5)
    end
    if axes.has_y(center_axes) then
        self.y = math.floor((flora.game_height - self.height) * 0.5)
    end
end

function sprite:set_graphic_size(width, height)
    self.scale:set(
        width / self.frame_width,
        height / self.frame_height
    )
end

function sprite:update(dt)
    self.animation:update(dt)
end

function sprite:draw()
    if not self.frames or not self.frame or self.alpha <= 0 then
        return
    end
    local filter = self.antialiasing and "linear" or "nearest"
    self.texture.image:setFilter(filter, filter)

    local otx = self.origin.x * self.frame_width
    local oty = self.origin.y * self.frame_height

    local ox = self.origin.x * self.width
    local oy = self.origin.y * self.height

    self.tint.a = self.alpha

    for i = 1, #self.cameras do
        ---
        --- @type flora.display.camera
        ---
        local cam = self.cameras[i]

        local cur_anim = self.animation.cur_anim

        local rx = self.x + ox
        local ry = self.y + oy

        local offx = cur_anim and cur_anim.offset.x or 0.0
        local offy = cur_anim and cur_anim.offset.y or 0.0

        offx = offx - (self.frame.offset.x * (self.scale.x < 0 and -1 or 1))
        offy = offy - (self.frame.offset.y * (self.scale.y < 0 and -1 or 1))

        offx = offx - (cam.scroll.x * self.scroll_factor.x)
        offy = offy - (cam.scroll.y * self.scroll_factor.y)

        rx = rx + (offx * math.abs(self.scale.x)) * self._cos_angle + (offy * math.abs(self.scale.y)) * -self._sin_angle
	    ry = ry + (offx * math.abs(self.scale.x)) * self._sin_angle + (offy * math.abs(self.scale.y)) * self._cos_angle

        cam:draw_frame(
            self.texture, self.frame, rx, ry,
            self.frame.width * self.scale.x, self.frame.height * self.scale.y,
            self.angle, otx, oty, self.tint
        )
    end
end

function sprite:dispose()
    sprite.super.dispose(self)

    if flora.config.debug_mode then
        flora.log:verbose("Unreferencing texture on sprite " .. tostring(self))
    end
    self.frames = nil

    if flora.config.debug_mode then
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
function sprite:__get(var)
    if var == "frames" then
        return self._frames
    
    elseif var == "texture" then
        if self._frames then
            return self._frames.texture
        end
        return nil

    elseif var == "angle" then
        return self._angle

    elseif var == "frame_width" then
        if self.animation.cur_anim then
            local first_frame = self.animation.cur_anim.frames[1]
            return first_frame.width
        end
        return self.frame and self.frame.width or 0.0
    
    elseif var == "width" then
        return self.frame_width * math.abs(self.scale.x)

    elseif var == "frame_height" then
        if self.animation.cur_anim then
            local first_frame = self.animation.cur_anim.frames[1]
            return first_frame.height
        end
        return self.frame and self.frame.height or 0.0
    
    elseif var == "height" then
        return self.frame_height * math.abs(self.scale.y)

    elseif var == "tint" then
        return self._tint
    end
    return sprite.super.__get(self, var)
end

---
--- @protected
---
function sprite:__set(var, val)
    if var == "frames" then
        if self._frames then
            self._frames:unreference()
        end
        self._frames = val
        if self._frames then
            self._frames:reference()
            self.frame = self._frames.frames[1]
        end
        return false

    elseif var == "angle" then
        self._angle = val

        local radian_angle = math.rad(val)
        self._cos_angle = math.cos(radian_angle)
        self._sin_angle = math.sin(radian_angle)

        return false

    elseif var == "tint" then
        self._tint = color:new(val)
        return false
    end
    return true
end

return sprite