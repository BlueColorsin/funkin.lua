---
--- @class funkin.backend.InitState : chip.core.Scene
---
local InitState = Scene:extend("InitState", ...)

function InitState:init()
    for i = 1, 15 do
        local spinny = Sprite:new():setPosition(30 + (i * 10), 30) --- @type chip.graphics.Sprite
        spinny.texture = love.graphics.newImage("assets/images/spinner.png")
        self:add(spinny)
    end
end

return InitState