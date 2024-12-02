--[[
    Copyright 2024 swordcube

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

local File = crequire("utils.File") --- @type chip.utils.File
local Glyph = require("funkin.ui.AtlasText.Glyph") --- @type funkin.ui.AtlasText.Glyph

---
--- @class funkin.ui.AtlasText : chip.graphics.CanvasLayer
---
local AtlasText = CanvasLayer:extend("AtlasText", ...)

function AtlasText.loadFontData(name)
    local jsonPath = Paths.json(name, "data/fonts")
    return Json.decode(File.read(jsonPath)) --- @type funkin.ui.AtlasText.AtlasFont
end

function AtlasText:constructor(x, y, font, alignment, contents)
    AtlasText.super.constructor(self)

    ---
    --- @protected
    ---
    self._x = x

    ---
    --- @protected
    ---
    self._y = y

    ---
    --- @protected
    ---
    self._font = nil --- @type string

    ---
    --- @protected
    ---
    self._fontData = nil --- @type funkin.ui.AtlasText.AtlasFont

    ---
    --- @protected
    ---
    self._contents = nil --- @type string

    ---
    --- @protected
    ---
    self._alignment = nil --- @type "left"|"center"|"right"

    self:setFont(font)
    self:setContents(contents)
    self:setAlignment(alignment)
end

function AtlasText:getFont()
    return self._font
end

function AtlasText:getFontData()
    return self._fontData
end

---
--- @param  font  string
---
function AtlasText:setFont(font)
    font = font or "default"
    if self._font == font then
        return
    end
    self._font = font
    self._fontData = AtlasText.loadFontData(self._font)

    if self:getLength() == 0 then
        return
    end
    self:_regenGlyphs()
    self:_updateAlignment(self._alignment)
end

function AtlasText:getContents()
    return self._contents
end

---
--- @param  contents  string
---
function AtlasText:setContents(contents)
    local lastContents = self._contents
    self._contents = contents

    if self._contents == lastContents then
        return
    end
    self:_regenGlyphs()
    self:_updateAlignment(self._alignment)
end

function AtlasText:getAlignment()
    return self._alignment
end

---
--- @param  alignment  "left"|"center"|"right"
---
function AtlasText:setAlignment(alignment)
    local lastAlignment = self._alignment
    self._alignment = alignment

    if self._alignment == lastAlignment then
        return
    end
    self:_updateAlignment(alignment)
end

function AtlasText:getTint()
    return self:getMembers()[1]:getTint()
end

function AtlasText:setTint(tint)
    local members = self:getMembers()
    for i = 1, self:getLength() do
        local line = members[i] --- @type chip.graphics.CanvasLayer
        local lineMembers = line:getMembers()
        
        for j = 1, line:getLength() do
            local glyph = lineMembers[j] --- @type funkin.ui.AtlasText.Glyph
            glyph:setTint(tint)
        end
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function AtlasText:_regenGlyphs()
    while self:getLength() > 0 do
        local actor = self:getMembers()[1] --- @type chip.core.Actor
        actor:free()
        self:remove(actor)
    end
    local contents = self._contents
    local glyphX, glyphY = 0.0, 0.0

    local fontData = self._fontData
    local line = CanvasLayer:new() --- @type chip.graphics.CanvasLayer

    for i = 1, #contents do
        local char = contents:charAt(i)
        if char == "\n" then
            self:add(line)
            line = CanvasLayer:new() --- @type chip.graphics.CanvasLayer

            glyphX = 0.0
            glyphY = glyphY + ((fontData.lineHeight or 60.0) * fontData.scale)
            goto continue
        end
        local glyph = Glyph:new(glyphX, glyphY, self, char) --- @type funkin.ui.AtlasText.Glyph
        glyph.scale:set(fontData.scale, fontData.scale)
        glyph:updateOffset()
        line:add(glyph)

        local glyphData = fontData.glyphs[char]
        if glyphData and glyphData.visible == false then
            glyphX = glyphX + (glyphData.width * fontData.scale)
        else
            glyphX = glyphX + glyph:getWidth()
        end
        ::continue::
    end
    if not table.contains(self:getMembers(), line) then
        self:add(line)
    end
end

---
--- @protected
--- @param  alignment  "left"|"center"|"right"
---
function AtlasText:_updateAlignment(alignment)
    local totalWidth = self:getWidth()
    local members = self:getMembers()
    for i = 1, self:getLength() do
        local line = members[i] --- @type chip.graphics.CanvasLayer
        if alignment == "left" then
            line:setX(0)
        
        elseif alignment == "center" then
            line:setX((totalWidth - line:getWidth()) * 0.5)
        
        elseif alignment == "right" then
            line:setX(totalWidth - line:getWidth())
        end
    end
end

return AtlasText