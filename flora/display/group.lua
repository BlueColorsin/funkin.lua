---@diagnostic disable: inject-field

--- 
--- An object that can hold several more game objects.
--- 
--- @class flora.display.Group : flora.base.Basic
--- 
local Group = Basic:extend("Group", ...)

---
--- Constructs a new group.
---
function Group:constructor()
    Group.super.constructor(self)

    ---
    --- The members inside of this group.
    ---
    self.members = {}
    
    ---
    --- The amount of members inside of this group.
    ---
    self.length = 0
end

---
--- @param  obj  flora.base.Basic  The object to add to this group.
--- 
--- @return flora.base.Basic
---
function Group:add(obj)
    if not obj then
        flora.log:warn("Cannot add an invalid object to a group!")
        return obj
    end
    table.insert(self.members, obj)
    self.length = self.length + 1
    return obj
end

---
--- @param  pos  integer           The position to add the given object at.
--- @param  obj  flora.base.Basic  The object to add to this group.
--- 
--- @return flora.base.Basic
---
function Group:insert(pos, obj)
    if not obj then
        flora.log:warn("Cannot add an invalid object to a group!")
        return obj
    end
    table.insert(self.members, pos, obj)
    self.length = self.length + 1
    return obj
end

---
--- @param  obj  flora.base.Basic  The object to remove from this group.
--- 
--- @return flora.base.Basic
---
function Group:remove(obj)
    if not obj then
        flora.log:warn("Cannot remove an invalid object from a group!")
        return obj
    end
    table.removeItem(self.members, obj)
    self.length = self.length - 1
    return obj
end

---
--- @param  obj  flora.base.Basic
---
--- @return boolean
---
function Group:contains(obj)
    return table.contains(self.members, obj)
end

function Group:clear()
    self.members = {}
    self.length = 0
end

function Group:update(dt)
    for i = 1, self.length do
        local obj = self.members[i]
        if obj and obj.exists and obj.active then
            obj:update(dt)
        end
    end
end

function Group:draw()
    local oldDefaultCameras = flora.cameras.defaultCameras
    if self._cameras then
        flora.cameras.defaultCameras = self._cameras
    end
    for i = 1, self.length do
        local obj = self.members[i]
        if obj and obj.exists and obj.visible then
            obj:draw()
        end
    end
    flora.cameras.defaultCameras = oldDefaultCameras
end

---
--- @param  func      function
--- @param  recurse?  boolean
---
function Group:forEach(func, recurse)
    for i = 1, self.length do
        ---
        --- @type flora.base.Basic
        ---
        local basic = self.members[i]
        if basic then
            if recurse then
                if basic:is(Group) or basic:is(SpriteGroup) then
                    Group:forEach(func, recurse)
                end
            end
            func(basic)
        end
    end
end

---
--- @param  func      function
--- @param  recurse?  boolean
---
function Group:forEachAlive(func, recurse)
    for i = 1, self.length do
        ---
        --- @type flora.base.Basic
        ---
        local basic = self.members[i]
        if basic and basic.exists and basic.alive then
            if recurse then
                if basic:is(Group) or basic:is(SpriteGroup) then
                    Group:forEachAlive(func, recurse)
                end
            end
            func(basic)
        end
    end
end

---
--- @param  func      function
--- @param  recurse?  boolean
---
function Group:forEachDead(func, recurse)
    for i = 1, self.length do
        ---
        --- @type flora.base.Basic
        ---
        local basic = self.members[i]
        if basic and not basic.alive then
            if recurse then
                if basic:is(Group) or basic:is(SpriteGroup) then
                    Group:forEachDead(func, recurse)
                end
            end
            func(basic)
        end
    end
end

function Group:dispose()
    Group.super.dispose(self)

    for i = 1, self.length do
        local obj = self.members[i]
        if obj then
            if flora.config.debugMode then
                flora.log:verbose("Disposing object " .. tostring(obj))
            end
            obj:dispose()
        end
    end
    self.members = nil
    self.length = 0
end

---
--- Returns a string representation of this object.
---
function Group:__tostring()
    return "Group (length: " .. self.length .. ")"
end

return Group