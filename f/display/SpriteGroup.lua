---
--- @class flora.display.SpriteGroup : flora.display.Sprite
--- @diagnostic disable: return-type-mismatch
---
local SpriteGroup = Sprite:extend("SpriteGroup", ...)

function SpriteGroup:constructor(x, y)
    SpriteGroup.super.constructor(self, x, y)

    -- These five have to be nil for the getters to work
    self.x = nil
    self.y = nil

    self.width = nil
    self.height = nil

    self.alpha = nil

    self:init_group()

    self.members = nil
    self.length = nil

    self.direct_alpha = false

    ---
    --- @protected
    --- @type number
    ---
    self._x = x and x or 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._y = y and y or 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._alpha = 1.0
end

function SpriteGroup:init_group()
    ---
    --- @type flora.display.Group
    ---
    self.group = Group:new()
end

function SpriteGroup:update(dt)
    self.group:update(dt)
end

function SpriteGroup:draw()
    self.group:draw()
end

--- 
--- @param  obj  flora.display.Sprite
---
function SpriteGroup:preAdd(obj)
    obj.x = obj.x + self._x
    obj.y = obj.y + self._y
    obj.alpha = obj.alpha * self.alpha
    obj.scrollFactor:copyFrom(self.scrollFactor)
    obj.cameras = self._cameras
end

--- 
--- @param  obj  flora.display.Sprite
--- 
--- @return flora.display.Sprite
---
function SpriteGroup:add(obj)
    if not self.group:contains(obj) then
        self:preAdd(obj)
    end
    return self.group:add(obj)
end

---
--- @param  pos  integer 
--- @param  obj  flora.display.Sprite
---
function SpriteGroup:insert(pos, obj)
    if not self.group:contains(obj) then
        self:preAdd(obj)
    end
    return self.group:insert(pos, obj)
end

--- 
--- @param  obj  flora.display.Sprite
---
function SpriteGroup:remove(obj)
    obj.x = obj.x - self._x
    obj.y = obj.y - self._y
    obj.cameras = nil
    return self.group:remove(obj)
end

--- 
--- @param  obj  flora.display.Sprite
--- 
--- @return boolean
---
function SpriteGroup:contains(obj)
    return self.group:contains(obj)
end

function SpriteGroup:clear()
    self.group:clear()
end

---
--- @param  func     function
--- @param  recurse  boolean?
---
function SpriteGroup:forEach(func, recurse)
    self.group:forEach(func, recurse)
end

---
--- @param  func     function
--- @param  recurse  boolean?
---
function SpriteGroup:forEachAlive(func, recurse)
    self.group:forEachAlive(func, recurse)
end

---
--- @param  func     function
--- @param  recurse  boolean?
---
function SpriteGroup:forEachDead(func, recurse)
    self.group:forEachDead(func, recurse)
end

---
--- @param  func     function
--- @param  recurse  boolean
---
function SpriteGroup:find_min_x()
    return self.group.length == 0 and self._x or self:_find_min_x_helper()
end

function SpriteGroup:find_max_x()
    return self.group.length == 0 and self._x or self:_find_max_x_helper()
end

function SpriteGroup:find_min_y()
    return self.group.length == 0 and self._y or self:_find_min_y_helper()
end

function SpriteGroup:find_max_y()
    return self.group.length == 0 and self._y or self:_find_max_y_helper()
end

function SpriteGroup:dispose()
    SpriteGroup.super.dispose(self)

    self.group:dispose()
    self.group = nil
end

---
--- Returns a string representation of this object.
---
function SpriteGroup:__tostring()
    return "SpriteGroup (length: " .. self.length .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function SpriteGroup:_find_min_x_helper()
    local value = math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local min_x = 0.0
            if member:is(SpriteGroup) then
                min_x = member:find_min_x()
            else
                min_x = member.x
            end
            if min_x < value then
                value = min_x
            end
        end
    end
    return value
end

---
--- @protected
---
function SpriteGroup:_find_max_x_helper()
    local value = -math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local max_x = 0.0
            if member:is(SpriteGroup) then
                max_x = member:find_max_x()
            else
                max_x = member.x + member.width
            end
            if max_x > value then
                value = max_x
            end
        end
    end
    return value
end

---
--- @protected
---
function SpriteGroup:_find_min_y_helper()
    local value = math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local min_y = 0.0
            if member:is(SpriteGroup) then
                min_y = member:find_min_y()
            else
                min_y = member.y
            end
            if min_y < value then
                value = min_y
            end
        end
    end
    return value
end

---
--- @protected
---
function SpriteGroup:_find_max_y_helper()
    local value = -math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local max_y = 0.0
            if member:is(SpriteGroup) then
                max_y = member:find_max_y()
            else
                max_y = member.y + member.height
            end
            if max_y > value then
                value = max_y
            end
        end
    end
    return value
end

---
--- @protected
---
function SpriteGroup:get_x()
    return self._x
end

---
--- @protected
---
function SpriteGroup:get_y()
    return self._y
end

---
--- @protected
---
function SpriteGroup:get_width()
    if self.group.length > 0 then
        return self:_find_max_x_helper() - self:_find_min_x_helper()
    end
    return 0.0
end

---
--- @protected
---
function SpriteGroup:get_height()
    if self.group.length > 0 then
        return self:_find_max_y_helper() - self:_find_min_y_helper()
    end
    return 0.0
end

---
--- @protected
---
function SpriteGroup:get_alpha()
    return self._alpha
end

---
--- @protected
---
function SpriteGroup:get_members()
    return self.group.members
end

---
--- @protected
---
function SpriteGroup:get_length()
    return self.group.length
end

---
--- @protected
---
function SpriteGroup:set_x(val)
    local old_x = self._x
    self._x = val

    local delta = self._x - old_x
    for i = 1, self.group.length do
        ---
        --- @type flora.display.Object2D
        ---
        local obj = self.group.members[i]
        if obj then
            obj.x = obj.x + delta
        end
    end
    return self._x
end

---
--- @protected
---
function SpriteGroup:set_y(val)
    local old_y = self._y
    self._y = val

    local delta = self._y - old_y
    for i = 1, self.group.length do
        ---
        --- @type flora.display.Object2D
        ---
        local obj = self.group.members[i]
        if obj then
            obj.y = obj.y + delta
        end
    end
    return self._y
end

---
--- @protected
---
function SpriteGroup:set_alpha(val)
    self._alpha = val
    for i = 1, self.group.length do
        local obj = self.group.members[i]
        if self.direct_alpha then
            obj.alpha = val
        else
            if obj.alpha > 0 or val == 0 then
                obj.alpha = obj.alpha * val
            else
                obj.alpha = 1 / val
            end
        end
    end
    return self._alpha
end

---
--- @protected
---
function SpriteGroup:set_frames(val)
    if val then -- doing this check to prevent a crash on SpriteGroup:dispose()
        error("Cannot set frames on a sprite group")
    end
    return nil
end

---
--- @protected
---
function SpriteGroup:set_angle(val)
    -- TODO: make this work properly
    self._angle = val

    local radianAngle = math.rad(val)
    self._cosAngle = math.cos(radianAngle)
    self._sinAngle = math.sin(radianAngle)

    for i = 1, self.group.length do
        local obj = self.group.members[i]
        obj.angle = val
    end
    return self._angle
end

---
--- @protected
---
function SpriteGroup:set_tint(val)
    self._tint = Color:new(val)
    for i = 1, self.group.length do
        local obj = self.group.members[i]
        obj.tint = Color:new(val)
    end
    return self._tint
end

return SpriteGroup