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

    self:initGroup()

    self.members = nil
    self.length = nil

    self.directAlpha = false

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

function SpriteGroup:initGroup()
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

function SpriteGroup:recycle(class, factory, force, revive)
	force = force and force or false
	revive = revive and revive or true
    self.group:recycle(class, factory, force, revive)
end

function SpriteGroup:getFirstAvailable(class, force)
	return self.group:getFirstAvailable(class, force)
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
function SpriteGroup:findMinX()
    return self.group.length == 0 and self._x or self:_findMinXHelper()
end

function SpriteGroup:findMaxX()
    return self.group.length == 0 and self._x or self:_findMaxXHelper()
end

function SpriteGroup:findMinY()
    return self.group.length == 0 and self._y or self:_findMinYHelper()
end

function SpriteGroup:findMaxY()
    return self.group.length == 0 and self._y or self:_findMaxYHelper()
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
function SpriteGroup:_findMinXHelper()
    local value = math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local minX = 0.0
            if member:is(SpriteGroup) then
                minX = member:findMinX()
            else
                minX = member.x
            end
            if minX < value then
                value = minX
            end
        end
    end
    return value
end

---
--- @protected
---
function SpriteGroup:_findMaxXHelper()
    local value = -math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local maxX = 0.0
            if member:is(SpriteGroup) then
                maxX = member:findMaxX()
            else
                maxX = member.x + member.width
            end
            if maxX > value then
                value = maxX
            end
        end
    end
    return value
end

---
--- @protected
---
function SpriteGroup:_findMinYHelper()
    local value = math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local minY = 0.0
            if member:is(SpriteGroup) then
                minY = member:findMinY()
            else
                minY = member.y
            end
            if minY < value then
                value = minY
            end
        end
    end
    return value
end

---
--- @protected
---
function SpriteGroup:_findMaxYHelper()
    local value = -math.huge
    for i = 1, self.group.length do
        local member = self.group.members[i]
        if member then
            local maxY = 0.0
            if member:is(SpriteGroup) then
                maxY = member:findMaxY()
            else
                maxY = member.y + member.height
            end
            if maxY > value then
                value = maxY
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
        return self:_findMaxXHelper() - self:_findMinXHelper()
    end
    return 0.0
end

---
--- @protected
---
function SpriteGroup:get_height()
    if self.group.length > 0 then
        return self:_findMaxYHelper() - self:_findMinYHelper()
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
    local factor = (self._alpha > 0) and val / self._alpha or 0
    for i = 1, self.group.length do
        local obj = self.group.members[i]
        if self.directAlpha or val <= 0 then
            obj.alpha = val
        else
            if obj.alpha > 0 or val <= 0 then
                obj.alpha = obj.alpha * factor
            else
                obj.alpha = 1 / val
            end
        end
    end
    self._alpha = val
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