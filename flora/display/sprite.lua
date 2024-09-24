local axes = require("flora.utils.axes")
local color = require("flora.utils.color")

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

    -- These have to be nil for the getters to work
    self.width = nil
    self.height = nil

    ---
    --- The texture used to render this sprite.
    ---
    --- @type flora.assets.texture?
    ---
    self.texture = flora.assets:get_texture(texture)

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
    --- The rotation of this sprite. (in degrees)
    ---
    self.angle = 0.0

    ---
    --- The tint of this sprite.
    --- 
    --- @type flora.utils.color
    ---
    self.tint = nil

    ---
    --- Whether or not antialiasing is enabled on this sprite.
    --- If you have pixel-art loaded onto it, turn this off!
    ---
    self.antialiasing = sprite.default_antialiasing

    ---
    --- @protected
    --- @type flora.utils.color 
    ---
    self._tint = color:new():copy_from(color.white)
end

---
--- Loads a given texture onto this sprite.
--- 
--- @param  texture  flora.assets.texture  The texture to load onto this sprite.
---
function sprite:load_texture(texture)
    self.texture = flora.assets:get_texture(texture)
end

---
--- Centers this sprite to the middle of the screen.
---
--- @param  center_axes  integer  The axes to center this sprite on. (`X`, `Y`, or `XY`)
---
function sprite:screen_center(center_axes)
    if axes.has_x(center_axes) then
        self.x = math.floor((flora.config.game_size.x - self.width) * 0.5)
    end
    if axes.has_y(center_axes) then
        self.y = math.floor((flora.config.game_size.y - self.height) * 0.5)
    end
end

function sprite:draw()
    if not self.texture then
        return
    end
    local filter = self.antialiasing and "linear" or "nearest"
    self.texture.image:setFilter(filter, filter)

    local otx = self.origin.x * self.texture.width
    local oty = self.origin.y * self.texture.height

    local ox = self.origin.x * self.width
    local oy = self.origin.y * self.height

    for i = 1, #self.cameras do
        ---
        --- @type flora.display.camera
        ---
        local cam = self.cameras[i]
        cam:draw_pixels(
            self.texture, self.x + ox, self.y + oy,
            self.width, self.height, self.angle, otx, oty, self.tint
        )
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function sprite:__get(var)
    if var == "width" then
        if self.texture then
            return self.texture.width * math.abs(self.scale.x)
        end
        return 0
    
    elseif var == "height" then
        if self.texture then
            return self.texture.height * math.abs(self.scale.y)
        end
        return 0

    elseif var == "tint" then
        return self._tint
    end
    return sprite.super.__get(self, var)
end

---
--- @protected
---
function sprite:__set(var, val)
    if var == "texture" then
        if self.texture then
            self.texture:unreference()
        end
        if val then
            val:reference()
        end

    elseif var == "tint" then
        self._tint = color:new():copy_from(val)
        return false
    end
    return true
end

return sprite