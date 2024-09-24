---
--- @class flora.utils.axes
---
local axes = {
    x = 0,
    y = 1,
    xy = 2
}

function axes.has_x(a)
    return a == axes.x or a == axes.xy
end

function axes.has_y(a)
    return a == axes.y or a == axes.xy
end

return axes