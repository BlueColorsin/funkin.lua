---
--- @class flora.display.sprite_group : flora.display.sprite
--- @diagnostic disable: return-type-mismatch
---
local sprite_group = sprite:extend("sprite_group", ...)

function sprite_group:constructor(x, y)
    sprite_group.super.constructor(self, x, y)

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

function sprite_group:init_group()
    ---
    --- @type flora.display.group
    ---
    self.group = group:new()
end

function sprite_group:update(dt)
    self.group:update(dt)
end

function sprite_group:draw()
    self.group:draw()
end

--- 
--- @param  obj  flora.display.sprite
---
function sprite_group:pre_add(obj)
    obj.x = obj.x + self._x
    obj.y = obj.y + self._y
    obj.alpha = obj.alpha * self.alpha
    obj.scroll_factor:copy_from(self.scroll_factor)
    obj.cameras = self._cameras
end

--- 
--- @param  obj  flora.display.sprite
--- 
--- @return flora.display.sprite
---
function sprite_group:add(obj)
    if not self.group:contains(obj) then
        self:pre_add(obj)
    end
    return self.group:add(obj)
end

---
--- @param  pos  integer 
--- @param  obj  flora.display.sprite
---
function sprite_group:insert(pos, obj)
    if not self.group:contains(obj) then
        self:pre_add(obj)
    end
    return self.group:insert(pos, obj)
end

--- 
--- @param  obj  flora.display.sprite
---
function sprite_group:remove(obj)
    obj.x = obj.x - self._x
    obj.y = obj.y - self._y
    obj.cameras = nil
    return self.group:remove(obj)
end

--- 
--- @param  obj  flora.display.sprite
--- 
--- @return boolean
---
function sprite_group:contains(obj)
    return self.group:contains(obj)
end

function sprite_group:clear()
    self.group:clear()
end

---
--- @param  func     function
--- @param  recurse  boolean?
---
function sprite_group:for_each(func, recurse)
    self.group:for_each(func, recurse)
end

---
--- @param  func     function
--- @param  recurse  boolean?
---
function sprite_group:for_each_alive(func, recurse)
    self.group:for_each_alive(func, recurse)
end

---
--- @param  func     function
--- @param  recurse  boolean?
---
function sprite_group:for_each_dead(func, recurse)
    self.group:for_each_dead(func, recurse)
end

---
--- @param  func     function
--- @param  recurse  boolean
---
function sprite_group:find_min_x()
    return self.group.length == 0 and self._x or self:_find_min_x_helper()
end

function sprite_group:find_max_x()
    return self.group.length == 0 and self._x or self:_find_max_x_helper()
end

function sprite_group:find_min_y()
    return self.group.length == 0 and self._y or self:_find_min_y_helper()
end

function sprite_group:find_max_y()
    return self.group.length == 0 and self._y or self:_find_max_y_helper()
end

function sprite_group:dispose()
    sprite_group.super.dispose(self)

    self.group:dispose()
    self.group = nil
end

---
--- Returns a string representation of this object.
---
function sprite_group:__tostring()
    return "sprite_group (length: " .. self.length .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function sprite_group:_find_min_x_helper()
    local value = math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local min_x = 0.0
            if member:is(sprite_group) then
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
function sprite_group:_find_max_x_helper()
    local value = -math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local max_x = 0.0
            if member:is(sprite_group) then
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
function sprite_group:_find_min_y_helper()
    local value = math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local min_y = 0.0
            if member:is(sprite_group) then
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
function sprite_group:_find_max_y_helper()
    local value = -math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local max_y = 0.0
            if member:is(sprite_group) then
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
function sprite_group:get_x()
    return self._x
end

---
--- @protected
---
function sprite_group:get_y()
    return self._y
end

---
--- @protected
---
function sprite_group:get_width()
    if self.group.length > 0 then
        return self:_find_max_x_helper() - self:_find_min_x_helper()
    end
    return 0.0
end

---
--- @protected
---
function sprite_group:get_height()
    if self.group.length > 0 then
        return self:_find_max_y_helper() - self:_find_min_y_helper()
    end
    return 0.0
end

---
--- @protected
---
function sprite_group:get_alpha()
    return self._alpha
end

---
--- @protected
---
function sprite_group:get_members()
    return self.group.members
end

---
--- @protected
---
function sprite_group:get_length()
    return self.group.length
end

---
--- @protected
---
function sprite_group:set_x(val)
    local old_x = self._x
    self._x = val

    local delta = self._x - old_x
    for i = 1, self.group.length do
        ---
        --- @type flora.display.object2d
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
function sprite_group:set_y(val)
    local old_y = self._y
    self._y = val

    local delta = self._y - old_y
    for i = 1, self.group.length do
        ---
        --- @type flora.display.object2d
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
function sprite_group:set_alpha(val)
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
function sprite_group:set_frames(val)
    if val then -- doing this check to prevent a crash on sprite_group:dispose()
        error("Cannot set frames on a sprite group")
    end
    return nil
end

---
--- @protected
---
function sprite_group:set_angle(val)
    -- TODO: make this work properly
    self._angle = val
    for i = 1, self.group.length do
        local obj = self.group.members[i]
        obj.angle = val
    end
    return self._angle
end

---
--- @protected
---
function sprite_group:set_tint(val)
    self._tint = color:new(val)
    for i = 1, self.group.length do
        local obj = self.group.members[i]
        obj.tint = color:new(val)
    end
    return self._tint
end

return sprite_group