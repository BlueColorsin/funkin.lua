---
--- @type funkin.ui.alphabet.alphabet_glyph
---
local alphabet_glyph = flora.import("funkin.ui.alphabet.alphabet_glyph")

---
--- @class funkin.ui.alphabet.alphabet : flora.display.sprite_group
---
local alphabet = sprite_group:extend("alphabet", ...)

---
---@param  x     number?
---@param  y     number?
---@param  text  string
---@param  type  "bold"|"normal"?
---@param  size  number
---
function alphabet:constructor(x, y, text, type, alignment, size)
    alphabet.super.constructor(self, x, y)

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
    self.target_y = 0

    ---
    --- Whether this object displays in a list like format.
    ---
    self.is_menu_item = false

    ---
    --- The spacing between items in menus like freeplay or options.
    ---
    self.menu_spacing = vector2:new(20, 120)

    ---
    --- The positional offset of this text.
    ---
    self.text_offset = vector2:new(0, 0)

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
    
    self:update_text(self._text, true)
    self:update_size(self._size)
end

function alphabet:update(dt)
    if self.is_menu_item then
        local scaledY = self.target_y * 1.3
        x = math.lerp(x, self.text_offset.x + (self.target_y * self.menu_spacing.x) + 90, dt * 9.6);
        y = math.lerp(y, self.text_offset.y + (scaledY * self.menu_spacing.y) + (flora.game_height * 0.45), dt * 9.6);
    end
    alphabet.super.update(self, dt)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
--- 
--- @param  new_text  string
--- @param  force     boolean?
---
function alphabet:update_text(new_text, force)
    if self._text == new_text and not force then
        return
    end
    for i = 1, self.length do
        local line = self.members[i]
        line:dispose()
    end
    self:clear()

    local glyph_pos = vector2:new()
    local rows = 0

    local line = sprite_group:new()

    for i = 1, #new_text do
        local char = new_text:char_at(i)
        if char == "\n" then
            rows = rows + 1
            glyph_pos.x = 0
            glyph_pos.y = rows * alphabet_glyph.y_per_row

            self:add(line)
            line = sprite_group:new()
        else
            local space_char = char == " "
            if space_char then
                glyph_pos.x = glyph_pos.x + 28
            
            elseif table.contains(alphabet_glyph.all_glyphs, char:lower()) then
                ---
                --- @type funkin.ui.alphabet.alphabet_glyph
                ---
                local glyph = alphabet_glyph:new(glyph_pos.x, glyph_pos.y, char, self._type)
                glyph.row = rows
                glyph.tint = color:new(self._tint)
                glyph.spawn_pos:copy_from(glyph_pos)
                line:add(glyph)

                glyph_pos.x = glyph_pos.x + glyph.width
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
function alphabet:update_alignment(align)
    local total_width = self.width
    for i = 1, self.length do
        ---
        --- @type flora.display.sprite_group
        ---
        local line = self.members[i]
        if align == "left" then
            line.x = self._x
            
        elseif align == "center" then
            line.x = self._x + ((total_width - line.width) * 0.5)
        
        elseif align == "right" then
            line.x = self._x + (total_width - line.width)
        end
    end
end

---
--- @protected
--- 
--- @param  size  integer
---
function alphabet:update_size(size)
    for i = 1, self.length do
        ---
        --- @type flora.display.sprite_group
        ---
        local line = self.members[i]
        line:for_each(function(glyph)
            glyph.scale:set(self._size, self._size)
            glyph:set_position(
                line.x + (glyph.spawn_pos.x * self._size),
                line.y + (glyph.spawn_pos.y * self._size)
            )
        end)
    end
    self:update_alignment(self._alignment)
end

---
--- @protected
---
function alphabet:set_type(val)
    self._type = val
    self:update_text(self._text, true)
    self:update_size(self._size)
    return self._type
end

---
--- @protected
---
function alphabet:set_text(val)
    self._text = val
    self:update_text(self._text)
    self:update_size(self._size)
    return self._text
end

---
--- @protected
---
function alphabet:set_alignment(val)
    self._alignment = val
    self:update_size(self._size)
    return self._alignment
end

---
--- @protected
---
function alphabet:set_size(val)
    self._size = val
    self:update_size(self._size)
    return self._size
end

return alphabet