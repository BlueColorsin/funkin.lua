local font = require("flora.assets.font")

---
--- A sprite that can render text to the screen.
---
--- @class flora.display.text : flora.display.sprite
---
local text = sprite:extend()

---
--- @param  x            number   The X coordinate of this text object on-screen.
--- @param  y            number   The Y coordinate of this text object on-screen.
--- @param  field_width  number   The maximum width of this text object before it wraps to the next line. (in pixels, default: `0`)
--- @param  txt          string   The text to render onto this text object.
--- @param  size         integer  The size of the text to render onto this text object.
---
function text:constructor(x, y, field_width, txt, size)
    text.super.constructor(self, x, y)

    ---
    --- The font used to render this text object. (default is `assets/fonts/vcr.ttf`)
    ---
    self.font = nil

    ---
    --- The size of the font used to render this text object. (default: `16`)
    ---
    self.size = nil

    ---
    --- The text displayed onto this text object. (default: `""`)
    ---
    self.text = nil

    ---
    --- The maximum width of this text object before
    --- it wraps to the next line. (in pixels, default: `0`)
    ---
    self.field_width = nil

    ---
    --- The alignment of this text displayed on
    --- this text object. (default: `left`)
    ---
    self.alignment = nil

    ---
    --- The size of the border applied to this text. (default: `0`)
    --- 
    --- @type number
    ---
    self.border_size = nil

    ---
    --- The color of the border applied to this text. (default: `color.black`)
    --- 
    --- @type flora.utils.color
    ---
    self.border_color = nil

    ---
    --- Controls how many iterations to use when drawing text border. (default: `1`)
    --- 
    --- @type number
    ---
    self.border_quality = nil

    ---
    --- @protected
    --- @type flora.assets.font?
    ---
    self._font = flora.assets:get_font("assets/fonts/vcr.ttf")

    ---
    --- @protected
    --- @type love.Font
    ---
    self._font_data = self._font:get_data_for_size(size and size or 16)

    ---
    --- @protected
    --- @type integer
    ---
    self._size = size and size or 16

    ---
    --- @protected
    --- @type number
    ---
    self._border_size = 0

    ---
    --- @protected
    --- @type flora.utils.color
    ---
    self._border_color = color:new():copy_from(color.black)

    ---
    --- @protected
    --- @type number
    ---
    self._border_quality = 1

    ---
    --- @protected
    --- @type integer
    ---
    self._field_width = field_width and field_width or 0

    ---
    --- @protected
    --- @type string
    ---
    self._text = txt and txt or ""

    ---
    --- @protected
    --- @type love.Text?
    ---
    self._text_obj = love.graphics.newTextBatch(self._font_data)

    ---
    --- @protected
    --- @type string
    ---
    self._alignment = "left"

    ---
    --- @protected
    --- @type love.Canvas
    ---
    self._canvas = love.graphics.newCanvas(1, 1)

    ---
    --- @protected
    --- @type boolean
    ---
    self._dirty = true

    local key = tostring(self)
    local tex = texture:new(key, love.graphics.newImage(love.image.newImageData(1, 1)))
    flora.assets:cache_texture(key, tex)

    self.texture = tex
    self:_regen_texture()
end

---
--- Draws this text to the screen.
---
function text:draw()
    self:_regen_texture()
    text.super.draw(self)
end

function text:dispose()
    if self._font then
        self._font:unreference()
    end
    self._font = nil

    self._canvas:release()
    self._canvas = nil

    if self._text_obj then
        self._text_obj:release()
    end
    text.super.dispose(self)
end

-----------------------
--- [ Private API ] ---
-----------------------

function text:_regen_texture()
    if not self._dirty then
        return
    end
    self._dirty = false

    -- TODO: colored text
    if self.field_width > 0 then        
        self._text_obj:setf(self.text, self.field_width, self.alignment)
    else
        self._text_obj:setf(self.text, math.huge, self.alignment)
    end

    local padding = math.floor(self.border_size) + 8
    if self._canvas then
        self._canvas:release()
    end
    self._canvas = love.graphics.newCanvas(
        (self._text_obj:getWidth() / font.oversampling) + padding,
        (self._text_obj:getHeight() / font.oversampling) + padding
    )
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)

    local tx = padding * 0.5
    local ty = padding * 0.5

    local tsx = 1 / font.oversampling
    local tsy = 1 / font.oversampling

    local iterations = math.round(self.border_size * self.border_quality)
    if iterations < 1 then
        iterations = 1
    end
    
    local delta = self.border_size / iterations
    local cur_delta = delta

    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(self.border_color.r, self.border_color.g, self.border_color.b, self.border_color.a)

    for _ = 1, iterations do
        -- upper-left
        love.graphics.draw(self._text_obj, tx - cur_delta, ty - cur_delta, 0, tsx, tsy)
        
        -- upper-middle
        love.graphics.draw(self._text_obj, tx, ty - cur_delta, 0, tsx, tsy)

        -- upper-right
        love.graphics.draw(self._text_obj, tx + cur_delta, ty - cur_delta, 0, tsx, tsy)

        -- middle-right
        love.graphics.draw(self._text_obj, tx + cur_delta, ty, 0, tsx, tsy)

        -- lower-right
        love.graphics.draw(self._text_obj, tx + cur_delta, ty + cur_delta, 0, tsx, tsy)

        -- lower-middle
        love.graphics.draw(self._text_obj, tx, ty + cur_delta, 0, tsx, tsy)

        -- lower-left
        love.graphics.draw(self._text_obj, tx - cur_delta, ty + cur_delta, 0, tsx, tsy)

        cur_delta = cur_delta + delta
    end

    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.draw(self._text_obj, tx, ty, 0, tsx, tsy)
    
    love.graphics.setCanvas(prev_canvas)

    ---
    --- @type flora.assets.texture
    ---
    local tex = self.texture

    local img = love.graphics.newImage(love.graphics.readbackTexture(self._canvas))
    tex:update_image(img)
end

function text:__get(var)
    if var == "font" then
        return self._font.path
    
    elseif var == "size" then
        return self._size
    
    elseif var == "field_width" then
        return self._field_width
    
    elseif var == "alignment" then
        return self._alignment
    
    elseif var == "text" then
        return self._text

    elseif var == "border_size" then
        return self._border_size
    
    elseif var == "border_color" then
        return self._border_color

    elseif var == "border_quality" then
        return self._border_quality

    elseif var == "width" then
        self:_regen_texture()
        return text.super.__get(self, var)

    elseif var == "height" then
        self:_regen_texture()
        return text.super.__get(self, var)
    end
    return text.super.__get(self, var)
end

function text:__set(var, val)
    if var == "font" then
        if self._font then
            self._font:unreference()
        end
        if self._text_obj then
            self._text_obj:release()
        end
        self._font = flora.assets:get_font(val)
        self._font:reference()

        self._font_data = self._font:get_data_for_size(self._size)
        self._text_obj = love.graphics.newTextBatch(self._font_data)
        
        self._dirty = true
        return false
        
    elseif var == "size" then
        self._size = val
        self._font_data = self._font:get_data_for_size(self._size)

        self._text_obj:setFont(self._font_data)
        self._dirty = true
        return false
        
    elseif var == "field_width" then
        self._field_width = val
        self._dirty = true
        return false

    elseif var == "alignment" then
        self._alignment = val
        self._dirty = true
        return false
        
    elseif var == "text" then
        self._dirty = self._text ~= val
        self._text = val
        return false

    elseif var == "border_size" then
        self._border_size = val
        self._dirty = true
        return false
        
    elseif var == "border_color" then
        self._border_color = color:new():copy_from(val)
        self._dirty = true
        return false

    elseif var == "border_quality" then
        self._border_quality = val
        self._dirty = true
        return false
    end
    return text.super.__set(self, var, val)
end

return text