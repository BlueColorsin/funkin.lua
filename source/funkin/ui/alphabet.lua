---
--- @class funkin.ui.alphabet : flora.display.sprite_group
---
local alphabet = sprite_group:extend("alphabet", ...)

function alphabet:constructor(x, y, text, bold)
    alphabet.super.constructor(self, x, y)

    if bold == nil then
        bold = true
    end
    self.bold = bold
    if self.bold then
        self.alphabet_frames = atlas_frames.from_sparrow("assets/images/menus/fonts/bold.png", "assets/images/menus/fonts/bold.xml")
    else
        self.alphabet_frames = atlas_frames.from_sparrow("assets/images/menus/fonts/normal.png", "assets/images/menus/fonts/normal.xml")
    end

    self.text = text
    self:regen_text()
end

function alphabet:regen_text()
    local x, y = 0.0, 0.0

    for i = 1, #self.text do
        local char = string.char_at(self.text, i)
        if char == "\n" then
            x = 0
            y = y + 67
        else
            local spr = sprite:new(x, y)
            spr.frames = self.alphabet_frames
            spr.animation:add_by_prefix("anim", string.upper(char), 24, true)
            spr.animation:play("anim")
            -- bullshit way of checking if anim is valid :3333333333333
            if #spr.animation.cur_anim.frames > 0 then
                x = x + spr.width
                self:add(spr)
            else
                x = x + 55
                spr:dispose()
            end
        end
    end
end

return alphabet