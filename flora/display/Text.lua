local Font = require("flora.assets.Font")

---
--- A sprite that can render text to the screen.
---
--- @class flora.display.Text : flora.display.Sprite
---
local Text = Sprite:extend("Text", ...)

---
--- @param  x            number   The X coordinate of this text object on-screen.
--- @param  y            number   The Y coordinate of this text object on-screen.
--- @param  fieldWidth  number   The maximum width of this text object before it wraps to the next line. (in pixels, default: `0`)
--- @param  txt          string   The text to render onto this text object.
--- @param  size         integer  The size of the text to render onto this text object.
---
function Text:constructor(x, y, fieldWidth, txt, size)
    Text.super.constructor(self, x, y)

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
    self.fieldWidth = nil

    ---
    --- The alignment of the text displayed onto
    --- this text object. (default: `left`)
    --- 
    --- @type "left"|"center"|"right"
    ---
    self.alignment = nil

    ---
    --- The color of the text displayed onto
    --- this text object. (default: `Color.WHITE`)
    --- 
    --- This is different from `tint`, since it ONLY
    --- affects the raw text color, nothing else!
    --- 
    --- @type flora.utils.Color|integer
    ---
    self.color = nil

    ---
    --- The size of the border applied to this text. (default: `1`)
    --- 
    --- @type number
    ---
    self.borderSize = nil

    ---
    --- The color of the border applied to this text. (default: `Color.TRANSPARENT`)
    --- 
    --- @type flora.utils.Color|integer
    ---
    self.borderColor = nil

    ---
    --- Controls how many iterations to use when drawing text border. (default: `1`)
    --- 
    --- @type number
    ---
    self.borderQuality = nil

    ---
    --- The border style to use for this text object. (default: `outline`)
    --- 
    --- @type "none"|"outline"|"shadow"
    ---
    self.borderStyle = nil

    ---
    --- An offset that is applied on the shadow border style, if active.
    --- 
    --- The X and Y components of the offset are multiplied by `borderSize`.
    --- 
    --- @type flora.math.Vector2
    ---
    self.shadowOffset = Vector2:new(1, 1)

    ---
    --- @protected
    --- @type flora.assets.Font?
    ---
    self._font = Flora.assets:loadFont("flora/embed/fonts/nokiafc22.ttf")

    ---
    --- @protected
    --- @type love.Font
    ---
    self._fontData = self._font:getDataForSize(size and size or 8)

    ---
    --- @protected
    --- @type integer
    ---
    self._size = size and size or 8

    ---
    --- @protected
    --- @type number
    ---
    self._borderSize = 1

    ---
    --- @protected
    --- @type flora.utils.Color
    ---
    self._borderColor = Color:new(Color.TRANSPARENT)

    ---
    --- @protected
    --- @type number
    ---
    self._borderQuality = 1

    ---
    --- @protected
    --- @type "none"|"outline"|"shadow"
    ---
    self._borderStyle = "none"

    ---
    --- @protected
    --- @type integer
    ---
    self._fieldWidth = fieldWidth and fieldWidth or 0

    ---
    --- @protected
    --- @type string
    ---
    self._text = txt and txt or ""

    ---
    --- @protected
    --- @type love.Text?
    ---
    self._textObj = love.graphics.newTextBatch(self._fontData)

    ---
    --- @protected
    --- @type string
    ---
    self._alignment = "left"

    ---
    --- @protected
    --- @type flora.utils.Color
    ---
    self._color = Color:new(Color.WHITE)

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
    local tex = Texture:new(key, love.graphics.newImage(love.image.newImageData(1, 1)))
    Flora.assets:cacheTexture(key, tex)

    -- TODO: using normal frames property SHOULD work, but doesn't for some reason
    self._frames = FrameCollection.fromTexture(tex)
    self.frame = self._frames.frames[1]

    self:_regenTexture()
end

---
--- @param  font         string                      The font used to render this text object. (default is `flora/embed/fonts/nokiafc22.ttf`)
--- @param  size         integer                     The size of the font used to render this text object. (default: `8`)
--- @param  textColor    flora.utils.Color?          The color of the text displayed onto this text object. This is different from `tint`, since it ONLY affects the raw text color, nothing else! (default: `Color.WHITE`)
--- @param  alignment    "left"|"center"|"right"?    The alignment of the text displayed onto this text object. (default: `left`)
--- @param  borderStyle  "none"|"outline"|"shadow"?  The border style to use for this text object. (default: `outline`)
--- @param  borderColor  flora.utils.Color|integer?  The color of the border applied to this text. (default: `Color.TRANSPARENT`)
---
function Text:setFormat(font, size, textColor, alignment, borderStyle, borderColor)
    self.font = font and font or "flora/embed/fonts/nokiafc22.ttf"
    self.size = size and size or 8
    self.color = textColor and textColor or Color.WHITE
    self.alignment = alignment and alignment or "left"
    self.borderStyle = borderStyle and borderStyle or "none"

    ---
    --- @cast borderColor flora.utils.Color
    ---
    self.borderColor = borderColor and borderColor or Color.TRANSPARENT
end

---
--- @param  style    "none"|"outline"|"shadow"  The border style to use for this text object.
--- @param  color    flora.utils.Color|integer  The color of the border applied to this text. (default: `Color.TRANSPARENT`)
--- @param  size     number?                    The size of the border applied to this text. (default: `1`)
--- @param  quality  number?                    Controls how many iterations to use when drawing text border. (default: `1`)
---
function Text:setBorderStyle(style, color, size, quality)
    self.borderStyle = style

    ---
    --- @cast color flora.utils.Color
    ---
    self.borderColor = color

    self.borderSize = size and size or 1
    self.borderQuality = quality and quality or 1
end

---
--- Draws this text to the screen.
---
function Text:draw()
    self:_regenTexture()
    Text.super.draw(self)
end

function Text:dispose()
    Text.super.dispose(self)

    if Flora.config.debugMode then
        Flora.log:verbose("Unreferencing _font on text " .. tostring(self))
    end
    if self._font then
        self._font:unreference()
    end
    self._font = nil

    if Flora.config.debugMode then
        Flora.log:verbose("Disposing _canvas on text " .. tostring(self))
    end
    self._canvas:release()
    self._canvas = nil

    if Flora.config.debugMode then
        Flora.log:verbose("Disposing _textObj on text " .. tostring(self))
    end
    if self._textObj then
        self._textObj:release()
    end
    self._textObj = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

function Text:_regenTexture()
    if not self._dirty then
        return
    end
    self._dirty = false

    -- TODO: colored text
    if self.fieldWidth > 0 then        
        self._textObj:setf(self.text, self.fieldWidth, self.alignment)
    else
        self._textObj:setf(self.text, math.huge, self.alignment)
    end

    local padding = math.floor(self.borderSize) + 8
    if self._canvas then
        self._canvas:release()
    end
    self._canvas = love.graphics.newCanvas(
        (self._textObj:getWidth() / Font.oversampling) + padding + (self.borderStyle == "shadow" and self.shadowOffset.x or 0.0),
        (self._textObj:getHeight() / Font.oversampling) + padding + (self.borderStyle == "shadow" and self.shadowOffset.y or 0.0)
    )
    local prev_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)

    local tx = padding * 0.5
    local ty = padding * 0.5

    local tsx = 1 / Font.oversampling
    local tsy = 1 / Font.oversampling
    
    local pr, pg, pb, pa = love.graphics.getColor()

    if self.borderSize > 0 and self.borderColor.a > 0 then
        if self.borderStyle == "outline" then
            local iterations = math.round(self.borderSize * self.borderQuality)
            if iterations < 1 then
                iterations = 1
            end
            
            local delta = self.borderSize / iterations
            local curDelta = delta
        
            love.graphics.setColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a)
        
            for _ = 1, iterations do
                -- upper-left
                love.graphics.draw(self._textObj, tx - curDelta, ty - curDelta, 0, tsx, tsy)
                
                -- upper-middle
                love.graphics.draw(self._textObj, tx, ty - curDelta, 0, tsx, tsy)
        
                -- upper-right
                love.graphics.draw(self._textObj, tx + curDelta, ty - curDelta, 0, tsx, tsy)
        
                -- middle-right
                love.graphics.draw(self._textObj, tx + curDelta, ty, 0, tsx, tsy)
        
                -- lower-right
                love.graphics.draw(self._textObj, tx + curDelta, ty + curDelta, 0, tsx, tsy)
        
                -- lower-middle
                love.graphics.draw(self._textObj, tx, ty + curDelta, 0, tsx, tsy)
        
                -- lower-left
                love.graphics.draw(self._textObj, tx - curDelta, ty + curDelta, 0, tsx, tsy)
                
                curDelta = curDelta + delta
            end
            
        elseif self.borderStyle == "shadow" then
            love.graphics.setColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a)
            love.graphics.draw(
                self._textObj, 
                tx + (self.shadowOffset.x * self.borderSize), ty + (self.shadowOffset.y * self.borderSize),
                0, tsx, tsy
            )
        end
    end
    
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    love.graphics.draw(self._textObj, tx, ty, 0, tsx, tsy)
    
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.setCanvas(prev_canvas)

    ---
    --- @type flora.assets.Texture
    ---
    local tex = self.texture

    local img = love.graphics.newImage(love.graphics.readbackTexture(self._canvas))
    tex:updateImage(img)

    self.frame.width = tex.width
    self.frame.height = tex.height

    ---
    --- @type love.Quad
    ---
    local quad = self.frame.quad
    quad:setViewport(0, 0, tex.width, tex.height, tex.width, tex.height)
end

---
--- @protected
---
function Text:get_font()
    return self._Font.path
end

---
--- @protected
---
function Text:get_size()
    return self._size
end

---
--- @protected
---
function Text:get_fieldWidth()
    return self._fieldWidth
end

---
--- @protected
---
function Text:get_alignment()
    return self._alignment
end

---
--- @protected
---
function Text:get_color()
    return self._color
end

---
--- @protected
---
function Text:get_text()
    return self._text
end

---
--- @protected
---
function Text:get_borderSize()
    return self._borderSize
end

---
--- @protected
---
function Text:get_borderColor()
    return self._borderColor
end

---
--- @protected
---
function Text:get_borderQuality()
    return self._borderQuality
end

---
--- @protected
---
function Text:get_borderStyle()
    return self._borderStyle
end

---
--- @protected
---
function Text:get_width()
    self:_regenTexture()
    return Text.super.get_width(self)
end

---
--- @protected
---
function Text:get_height()
    self:_regenTexture()
    return Text.super.get_height(self)
end

---
--- @protected
---
function Text:set_font(val)
    if self._font then
        self._font:unreference()
    end
    if self._textObj then
        self._textObj:release()
    end
    self._font = Flora.assets:loadFont(val)
    self._font:reference()

    self._fontData = self._font:getDataForSize(self._size)
    self._textObj = love.graphics.newTextBatch(self._fontData)
        
    self._dirty = true
    return self._font.path
end

---
--- @protected
---
function Text:set_size(val)
    self._size = val
    self._fontData = self._font:getDataForSize(self._size)

    self._textObj:setFont(self._fontData)
    self._dirty = true
    return self._size
end

---
--- @protected
---
function Text:set_fieldWidth(val)
    self._fieldWidth = val
    self._dirty = true
    return self._fieldWidth
end

---
--- @protected
---
function Text:set_alignment(val)
    self._alignment = val
    self._dirty = true
    return self._alignment
end

---
--- @protected
---
function Text:set_color(val)
    self._color = Color:new(val)
    self._dirty = true
    return self._color
end

---
--- @protected
---
function Text:set_text(val)
    self._dirty = self._text ~= val
    self._text = val
    return self._text
end

---
--- @protected
---
function Text:set_borderSize(val)
    self._borderSize = val
    self._dirty = true
    return self._borderSize
end

---
--- @protected
---
function Text:set_borderColor(val)
    self._borderColor = Color:new(val)
    self._dirty = true
    return self._borderColor
end

---
--- @protected
---
function Text:set_borderQuality(val)
    self._borderQuality = val
    self._dirty = true
    return self._borderQuality
end

---
--- @protected
---
function Text:set_borderStyle(val)
    self._borderStyle = val
    self._dirty = true
    return self._borderStyle
end

return Text