---
--- @type funkin.ui.alphabet.AlphabetGlyph
---
local AlphabetGlyph = Flora.import("funkin.ui.alphabet.AlphabetGlyph")

---
--- @class funkin.ui.alphabet.Alphabet : flora.display.SpriteGroup
---
local Alphabet = SpriteGroup:extend("Alphabet", ...)

---
---@param  x     number?
---@param  y     number?
---@param  text  string
---@param  type  "bold"|"normal"?
---@param  size  number
---
function Alphabet:constructor(x, y, text, type, alignment, size)
    Alphabet.super.constructor(self, x, y)

    ---
    --- @type string
    ---
    self.type = nil

    ---
    --- The currently set alignment type for the text.
    ---
    --- @type "left"|"center"|"right"
    ---
    self.alignment = nil

    ---
    --- The currently set text.
    ---
    --- @type string
    ---
    self.text = nil

    ---
    --- The size multiplier of the text.
    --- 
    --- It is recommended to use this instead of `scale`
    --- as it auto-adjusts the position of each glyph/letter.
    ---
    --- @type number
    ---
    self.size = nil

    ---
    --- The index of this text when displayed in a list.
    ---
    self.targetY = 0

    ---
    --- Whether this object displays in a list like format.
    ---
    self.isMenuItem = false

    ---
    --- The spacing between items in menus like freeplay or options.
    ---
    self.menuSpacing = Vector2:new(20, 120)

    ---
    --- The positional offset of this text.
    ---
    self.textOffset = Vector2:new(0, 0)

    ---
    --- @protected
    --- @type string
    ---
    self._type = type and type or "bold"
    
    ---
    --- @protected
    --- @type "left"|"center"|"right"
    ---
    self._alignment = alignment and alignment or "left"
    
    ---
    --- @protected
    --- @type string
    ---
    self._text = text
    
    ---
    --- @protected
    --- @type number
    ---
    self._size = size and size or 1.0
    
    ---
    --- @protected
    --- @type love.SpriteBatch
    ---
    self._batch = love.graphics.newSpriteBatch(Paths.getSparrowAtlas(self._type, "images/menus/fonts").texture.image, nil, "stream")

    self:set_type(self._type)
end

function Alphabet:update(dt)
    if self.isMenuItem then
        local scaledY = self.targetY * 1.3
        x = math.lerp(x, self.textOffset.x + (self.targetY * self.menuSpacing.x) + 90, dt * 9.6);
        y = math.lerp(y, self.textOffset.y + (scaledY * self.menuSpacing.y) + (Flora.gameHeight * 0.45), dt * 9.6);
    end
    Alphabet.super.update(self, dt)
end

function Alphabet:draw()
    for i = 1, self.length do
        local glyph = self.members[i]
        glyph:draw()
    end
    local oldDefaultCameras = Flora.cameras.defaultCameras
    if self._cameras then
        Flora.cameras.defaultCameras = self._cameras
    end
    local batchTex = self._batch:getTexture()
    for i = 1, #Flora.cameras.defaultCameras do
        ---
        --- @type flora.display.Camera
        ---
        local cam = Flora.cameras.defaultCameras[i]

        local otx = self.origin.x * (self.width / math.abs(self.scale.x))
        local oty = self.origin.y * (self.height / math.abs(self.scale.y))

        local ox = self.origin.x * self.width
        local oy = self.origin.y * self.height

        local rx = self.x + ox
        local ry = self.y + oy

        local offx = 0.0
        local offy = 0.0

        offx = offx - (cam.scroll.x * self.scrollFactor.x)
        offy = offy - (cam.scroll.y * self.scrollFactor.y)

        rx = rx + (offx * math.abs(self.scale.x)) * self._cosAngle + (offy * math.abs(self.scale.y)) * -self._sinAngle
	    ry = ry + (offx * math.abs(self.scale.x)) * self._sinAngle + (offy * math.abs(self.scale.y)) * self._cosAngle

        local filter = self.antialiasing and "linear" or "nearest"
        batchTex:setFilter(filter, filter)

        cam:drawSpriteBatch(
            self._batch, rx, ry,
            batchTex:getWidth() * self.scale.x, batchTex:getHeight() * self.scale.y,
            self.angle, otx, oty, Color.WHITE
        )
    end
    Flora.cameras.defaultCameras = oldDefaultCameras
end

function Alphabet:dispose()
    Alphabet.super.dispose(self)

    self._batch:release()
    self._batch = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
--- 
--- @param  newText  string
--- @param  force    boolean?
---
function Alphabet:updateText(newText, force)
    if self._text == newText and not force then
        return
    end
    if self._batch then
        self._batch:clear()
    end
    for i = 1, self.length do
        local line = self.members[i]
        line:dispose()
    end
    self:clear()
    local glyphPos = Vector2:new()
    local rows = 0

    local line = SpriteGroup:new()

    for i = 1, #newText do
        local char = newText:charAt(i)
        if char == "\n" then
            rows = rows + 1
            glyphPos.x = 0
            glyphPos.y = rows * AlphabetGlyph.Y_PER_POW

            self:add(line)
            line = SpriteGroup:new()
        else
            local spaceChar = char == " "
            if spaceChar then
                glyphPos.x = glyphPos.x + 28
            
            elseif table.contains(AlphabetGlyph.ALL_GLYPHS, char:lower()) then
                ---
                --- @type funkin.ui.alphabet.AlphabetGlyph
                ---
                local glyph = AlphabetGlyph:new(self, glyphPos.x, glyphPos.y, char, self._type)
                glyph.row = rows
                glyph.tint = Color:new(self._tint)
                glyph.spawnPos:copyFrom(glyphPos)
                line:add(glyph)

                glyphPos.x = glyphPos.x + glyph.width
            end
        end
    end
    if not self:contains(line) then
        self:add(line)
    end
end

---
--- @protected
--- 
--- @param  align  "left"|"center"|"right"
---
function Alphabet:updateAlignment(align)
    local totalWidth = self.width
    for i = 1, self.length do
        ---
        --- @type flora.display.SpriteGroup
        ---
        local line = self.members[i]
        if align == "left" then
            line.x = self._x
            
        elseif align == "center" then
            line.x = self._x + ((totalWidth - line.width) * 0.5)
        
        elseif align == "right" then
            line.x = self._x + (totalWidth - line.width)
        end
    end
end

---
--- @protected
--- 
--- @param  size  integer
---
function Alphabet:updateSize(size)
    for i = 1, self.length do
        ---
        --- @type flora.display.SpriteGroup
        ---
        local line = self.members[i]
        line:forEach(function(glyph)
            glyph.scale:set(size, size)
            glyph:setPosition(
                line.x + (glyph.spawnPos.x * size),
                line.y + (glyph.spawnPos.y * size)
            )
        end)
    end
    self:updateAlignment(self._alignment)
end

---
--- @protected
---
function Alphabet:set_type(val)
    self._type = val
    self._batch:setTexture(Paths.getSparrowAtlas(self._type, "images/menus/fonts").texture.image)

    self:updateText(self._text, true)
    self:updateSize(self._size)
    return self._type
end

---
--- @protected
---
function Alphabet:set_text(val)
    self:updateText(val)
    self:updateSize(self._size)
    self._text = val
    return self._text
end

---
--- @protected
---
function Alphabet:set_alignment(val)
    self._alignment = val
    self:updateSize(self._size)
    return self._alignment
end

---
--- @protected
---
function Alphabet:set_size(val)
    self._size = val
    self:updateSize(self._size)
    return self._size
end

---
--- @protected
---
function Alphabet:set_angle(val)
    self._angle = val

    local radianAngle = math.rad(val)
    self._cosAngle = math.cos(radianAngle)
    self._sinAngle = math.sin(radianAngle)

    return self._angle
end

---
--- @protected
---
function Alphabet:get_width()
    if self.group.length > 0 then
        return (self:_find_max_x_helper() - self:_find_min_x_helper()) * self.scale.x
    end
    return 0.0
end

---
--- @protected
---
function Alphabet:get_height()
    if self.group.length > 0 then
        return (self:_find_max_y_helper() - self:_find_min_y_helper()) * self.scale.y
    end
    return 0.0
end

return Alphabet