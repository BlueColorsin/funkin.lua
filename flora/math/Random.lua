---
--- @class flora.math.Random
---
--- A basic class for obtaining random values.
---
local Random = Class:extend("Random", ...)

function Random:int(min, max)
    return math.floor(love.math.random(min, max))
end

function Random:float(min, max)
    return love.math.random(min, max)
end

function Random:bool(chance)
    return self:float(0, 100) < chance
end

return Random