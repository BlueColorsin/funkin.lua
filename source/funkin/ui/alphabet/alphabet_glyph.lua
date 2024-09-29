---
--- @class funkin.ui.alphabet.alphabet_glyph : flora.display.sprite
---
local alphabet_glyph = sprite:extend("alphabet_glyph", ...)

alphabet_glyph.y_per_row = 60.0
alphabet_glyph.letters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
alphabet_glyph.all_glyphs = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "#", "$", "%", "&", "(", ")", "[", "]", "|", "~", "<", ">", " ", "←", "↓", "↑", "→", "-", "_", "!", "'", ",", ".", ":", ";", "+", "?", "*", "^", "\\", "/", "\"", "=", "×", "♥"}
alphabet_glyph.conversion_table = {
    ["\\"] = "backslash",
    ["/"] = "forward slash",
    [","] = "comma",
    ["!"] = "exclamation mark",
    ["←"] = "left arrow",
    ["↓"] = "down arrow",
    ["↑"] = "up arrow",
    ["→"] = "right arrow",
    ["×"] = "multiply x",
    ["♥"] = "heart",
    ["\""] = "start parentheses",
    ["%"] = "percent",
    ["$"] = "dollar",
    ["&"] = "and",
    ["#"] = "hashtag",
    [":"] = "colon",
    [";"] = "semicolon"
}

---
--- @param  x     number?
--- @param  y     number?
--- @param  char  string
--- @param  type  "bold"|"normal"
---
function alphabet_glyph:constructor(x, y, char, type)
    alphabet_glyph.super.constructor(self, x, y)

    ---
    --- @type string
    ---
    self.type = nil

    ---
    --- @type string
    ---
    self.char = nil

    ---
    --- @type integer
    ---
    self.row = 0

    ---
    --- @type flora.math.vector2
    ---
    self.spawn_pos = vector2:new()

    ---
    --- @protected
    --- @type string
    ---
    self._type = type

    ---
    --- @protected
    --- @type string
    ---
    self._char = char
    self:set_char(char)
end

function alphabet_glyph.convert(char)
    local converted = alphabet_glyph.conversion_table[char]
    return converted and converted or char
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function alphabet_glyph:update_bold_offset()
    local offset = vector2:new(0, 0)
    local char_sets = {
        {
            chars = {"$", "%", "&", "(", ")", "[", "]", "<", ">"},
            offset = vector2:new(0, self.frame_height * 0.1)
        },
        {
            chars = {"#", "←", "↓", "↑", "→", "+", "=", "×", "♥"},
            offset = vector2:new(0, self.frame_height * 0.2)
        },
        {
            chars = {",", "."},
            offset = vector2:new(0, self.frame_height * 0.65)
        },
        {
            chars = {"~"},
            offset = vector2:new(0, self.frame_height * 0.3)
        },
        {
            chars = {"-"},
            offset = vector2:new(0, self.frame_height * 0.3)
        },
        {
            chars = {"_"},
            offset = vector2:new(0, self.frame_height * 0.6)
        },
        {
            chars = {"u", "i"},
            offset = vector2:new(0, self.frame_height * -0.1)
        }
    }
    for i = 1, #char_sets do
        local set = char_sets[i]
        for j = 1, #set.chars do
            if self._char == set.chars[j] then
                offset.x = offset.x + set.offset.x
                offset.y = offset.y + set.offset.y
                break
            end
        end
    end
    self.animation:set_offset("idle", -offset.x, -offset.y)
    self.animation:play("idle", true)
end

---
--- @protected
---
function alphabet_glyph:update_offset()
    local offset = vector2:new(0, 110 - self.frame_height)
    local char_sets = {
        {
            chars = {"a", "c", "e", "g", "m", "n", "o", "r", "u", "v", "w", "x", "z", "s"},
            offset = vector2:new(0, self.frame_height * 0.25)
        },
        {
            chars = {"$", "%", "&", "(", ")", "[", "]", "<", ">"},
            offset = vector2:new(0, self.frame_height * 0.1)
        },
        {
            chars = {"#", "←", "↓", "↑", "→", "+", "=", "×", "♥"},
            offset = vector2:new(0, self.frame_height * 0.2)
        },
        {
            chars = {",", "."},
            offset = vector2:new(0, self.frame_height * 0.7)
        },
        {
            chars = {"~"},
            offset = vector2:new(0, self.frame_height * 0.3)
        },
        {
            chars = {"-"},
            offset = vector2:new(0, self.frame_height * 0.32)
        },
        {
            chars = {"_"},
            offset = vector2:new(0, self.frame_height * 0.65)
        },
        {
            chars = {"p", "q", "y"},
            offset = vector2:new(0, self.frame_height * 0.22)
        }
    }
    for i = 1, #char_sets do
        local set = char_sets[i]
        for j = 1, #set.chars do
            if self._char == set.chars[j] then
                offset = offset + set.offset
                break
            end
        end
    end
    self.animation:set_offset("idle", -offset.x, -offset.y)
    self.animation:play("idle", true)
end

---
--- @protected
---
function alphabet_glyph:get_char()
    return self._char
end

---
--- @protected
---
function alphabet_glyph:get_type()
    return self._type
end

---
--- @protected
---
function alphabet_glyph:set_char(val)
    self._char = val
    self.frames = paths.get_sparrow_atlas(self._type, "images/menus/fonts")

    local is_letter = table.contains(alphabet_glyph.letters, self._char)
    local converted = alphabet_glyph.convert(self._char)

    if self._type ~= "bold" and is_letter then
        local letter_case = (self._char:lower() ~= self._char) and "capital" or "lowercase"
        converted = converted:upper() .. " " .. letter_case
    end
    self.animation:add_by_prefix("idle", converted:upper() .. "0", 24)
    
    if not self.animation:exists("idle") then
        self.animation:add_by_prefix("idle", converted .. "0", 24)
    end
    if not self.animation:exists("idle") then
        flora.log:warn('Letter in ' .. self._type .. ' alphabet: ' .. converted .. ' doesn\'t exist!');
        self.animation:add_by_prefix("idle", "?0", 24)
    end
    self.animation:play("idle")

    if self._type == "bold" then
        self:update_bold_offset()
    else
        self:update_offset()
    end
    return self._char
end

---
--- @protected
---
function alphabet_glyph:set_type(val)
    self._type = val
    self:set_char(self._char)
    return self._type
end

return alphabet_glyph