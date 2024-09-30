---
--- @class flora.utils.Axes
---
local Axes = {
    X = 0,
    Y = 1,
    XY = 2
}

function Axes.hasX(a)
    return a == Axes.X or a == Axes.XY
end

function Axes.hasY(a)
    return a == Axes.Y or a == Axes.XY
end

return Axes