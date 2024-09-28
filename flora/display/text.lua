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

    self._type = "text"

    ---
    --- The font used to render this text object. (default is `flora/embed/fonts/nokiafc22.ttf`)
    --- 
    --- @type string
    ---
    self.font = nil

    ---
    --- The size of the font used to render this text object. (default: `8`)
    --- 
    --- @type integer
    ---
    self.size = nil

    ---
    --- The text displayed onto this text object. (default: `""`)
    --- 
    --- @type string
    ---
    self.text = nil

    ---
    --- The maximum width of this text object before
    --- it wraps to the next line. (in pixels, default: `0`)
    --- 
    --- @type number
    ---
    self.field_width = nil

    ---
    --- The alignment of the text displayed onto
    --- this text object. (default: `left`)
    --- 
    --- @type "left"|"center"|"right"
    ---
    self.alignment = nil

    ---
    --- The color of the text displayed onto
    --- this text object. (default: `color.white`)
    --- 
    --- This is different from `tint`, since it ONLY
    --- affects the raw text color, nothing else!
    --- 
    --- @type flora.utils.color
    ---
    self.color = nil

    ---
    --- The size of the border applied to this text. (default: `1`)
    --- 
    --- @type number
    ---
    self.border_size = nil

    ---
    --- The color of the border applied to this text. (default: `color.transparent`)
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
    --- The border style to use for this text object. (default: `outline`)
    --- 
    --- @type "none"|"outline"|"shadow"
    ---
    self.border_style = nil

    ---
    --- An offset that is applied on the shadow border style, if active.
    --- 
    --- The X and Y components of the offset are multiplied by `borderSize`.
    --- 
    --- @type flora.math.vector2
    ---
    self.shadow_offset = vector2:new(1, 1)

    ---
    --- @protected
    --- @type flora.assets.font?
    ---
    self._font = flora.assets:load_font("flora/embed/fonts/nokiafc22.ttf")

    ---
    --- @protected
    --- @type love.Font
    ---
    self._font_data = self._font:get_data_for_size(size and size or 8)

    ---
    --- @protected
    --- @type integer
    ---
    self._size = size and size or 8

    ---
    --- @protected
    --- @type number
    ---
    self._border_size = 1

    ---
    --- @protected
    --- @type flora.utils.color
    ---
    self._border_color = color:new(color.transparent)

    ---
    --- @protected
    --- @type number
    ---
    self._border_quality = 1

    ---
    --- @protected
    --- @type "none"|"outline"|"shadow"
    ---
    self._border_style = "none"

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
    --- @type flora.utils.color
    ---
    self._color = color:new(color.white)

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

    -- TODO: using normal frames property SHOULD work, but doesn't for some reason
    self._frames = frame_collection.from_texture(tex)
    self.frame = self._frames.frames[1]

    self:_regen_texture()
end

---
--- @param  font          string                      The font used to render this text object. (default is `flora/embed/fonts/nokiafc22.ttf`)
--- @param  size          integer                     The size of the font used to render this text object. (default: `8`)
--- @param  text_color    flora.utils.color           The The color of the text displayed onto this text object. This is different from `tint`, since it ONLY affects the raw text color, nothing else! (default: `color.white`)
--- @param  alignment     "left"|"center"|"right"?    The alignment of the text displayed onto this text object. (default: `left`)
--- @param  border_style  "none"|"outline"|"shadow"?  The border style to use for this text object. (default: `outline`)
--- @param  border_color  flora.utils.color|integer?  The color of the border applied to this text. (default: `color.black`)
---
function text:set_format(font, size, text_color, alignment, border_style, border_color)
    self.font = font and font or "flora/embed/fonts/nokiafc22.ttf"
    self.size = size and size or 8
    self.color = text_color and text_color or color.white
    self.alignment = alignment and alignment or "left"
    self.border_style = border_style and border_style or "none"

    ---
    --- @cast border_color flora.utils.color
    ---
    self.border_color = border_color and border_color or color.transparent
end

---
--- @param  style    "none"|"outline"|"shadow"  The border style to use for this text object.
--- @param  color    flora.utils.color|integer  The color of the border applied to this text. (default: `color.transparent`)
--- @param  size     number?                    The size of the border applied to this text. (default: `1`)
--- @param  quality  number?                    Controls how many iterations to use when drawing text border. (default: `1`)
---
function text:set_border_style(style, color, size, quality)
    self.border_style = style

    ---
    --- @cast color flora.utils.color
    ---
    self.border_color = color

    self.border_size = size and size or 1
    self.border_quality = quality and quality or 1
end

---
--- Draws this text to the screen.
---
function text:draw()
    self:_regen_texture()
    text.super.draw(self)
end

function text:dispose()
    text.super.dispose(self)

    if flora.config.debug_mode then
        flora.log:verbose("Unreferencing _font on text " .. tostring(self))
    end
    if self._font then
        self._font:unreference()
    end
    self._font = nil

    if flora.config.debug_mode then
        flora.log:verbose("Disposing _canvas on text " .. tostring(self))
    end
    self._canvas:release()
    self._canvas = nil

    if flora.config.debug_mode then
        flora.log:verbose("Disposing _text_obj on text " .. tostring(self))
    end
    if self._text_obj then
        self._text_obj:release()
    end
    self._text_obj = nil
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
        (self._text_obj:getWidth() / font.oversampling) + padding + (self.border_style == "shadow" and self.shadow_offset.x or 0.0),
        (self._text_obj:getHeight() / font.oversampling) + padding + (self.border_style == "shadow" and self.shadow_offset.y or 0.0)
    )
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)

    local tx = padding * 0.5
    local ty = padding * 0.5

    local tsx = 1 / font.oversampling
    local tsy = 1 / font.oversampling
    
    local pr, pg, pb, pa = love.graphics.getColor()

    if self.border_size > 0 and self.border_color.a > 0 then
        if self.border_style == "outline" then
            local iterations = math.round(self.border_size * self.border_quality)
            if iterations < 1 then
                iterations = 1
            end
            
            local delta = self.border_size / iterations
            local cur_delta = delta
        
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
            
        elseif self.border_style == "shadow" then
            love.graphics.setColor(self.border_color.r, self.border_color.g, self.border_color.b, self.border_color.a)
            love.graphics.draw(
                self._text_obj, 
                tx + (self.shadow_offset.x * self.border_size), ty + (self.shadow_offset.y * self.border_size),
                0, tsx, tsy
            )
        end
    end
    
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    love.graphics.draw(self._text_obj, tx, ty, 0, tsx, tsy)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)

    ---
    --- @type flora.assets.texture
    ---
    local tex = self.texture

    local img = love.graphics.newImage(love.graphics.readbackTexture(self._canvas))
    tex:update_image(img)

    self.frame.width = tex.width
    self.frame.height = tex.height

    ---
    --- @type love.Quad
    ---
    local quad = self.frame.quad
    quad:setViewport(0, 0, tex.width, tex.height, tex.width, tex.height)
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

    elseif var == "color" then
        return self._color
    
    elseif var == "text" then
        return self._text

    elseif var == "border_size" then
        return self._border_size
    
    elseif var == "border_color" then
        return self._border_color

    elseif var == "border_quality" then
        return self._border_quality

    elseif var == "border_style" then
        return self._border_style

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
        self._font = flora.assets:load_font(val)
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

    elseif var == "color" then
        self._color = color:new(val)
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
        self._border_color = color:new(val)
        self._dirty = true
        return false

    elseif var == "border_quality" then
        self._border_quality = val
        self._dirty = true
        return false

    elseif var == "border_style" then
        self._border_style = val
        self._dirty = true
        return false
    end
    return text.super.__set(self, var, val)
end

return text