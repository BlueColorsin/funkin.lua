---@diagnostic disable: inject-field

--- 
--- An object that can hold several more game objects.
--- 
--- @class flora.display.group : flora.base.basic
--- 
local group = basic:extend("group", ...)

---
--- Constructs a new group.
---
function group:constructor()
    group.super.constructor(self)

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
--- @param  obj  flora.base.object  The object to add to this group.
---
function group:add(obj)
    if not obj then
        flora.log:warn("Cannot add an invalid object to a group!")
    end
    table.insert(self.members, obj)
    self.length = self.length + 1
end

---
--- @param  pos  integer            The position to add the given object at.
--- @param  obj  flora.base.object  The object to add to this group.
---
function group:insert(pos, obj)
    if not obj then
        flora.log:warn("Cannot add an invalid object to a group!")
    end
    table.insert(self.members, pos, obj)
    self.length = self.length + 1
end

---
--- @param  obj  flora.base.object  The object to remove from this group.
---
function group:remove(obj)
    if not obj then
        flora.log:warn("Cannot remove an invalid object from a group!")
    end
    table.remove_item(self.members, obj)
    self.length = self.length - 1
end

function group:contains(obj)
    return table.contains(self.members, obj)
end

function group:update(dt)
    for i = 1, self.length do
        local obj = self.members[i]
        if obj and obj.exists and obj.active then
            obj:update(dt)
        end
    end
end

function group:draw()
    local old_default_cameras = flora.cameras.default_cameras
    if self._cameras then
        flora.cameras.default_cameras = self._cameras
    end
    for i = 1, self.length do
        local obj = self.members[i]
        if obj and obj.exists and obj.visible then
            obj:draw()
        end
    end
    flora.cameras.default_cameras = old_default_cameras
end

function group:for_each(func, recurse)
    for i = 1, self.length do
        ---
        --- @type flora.base.basic
        ---
        local basic = self.members[i]
        if basic then
            if recurse then
                if basic:is(group) or basic:is(sprite_group) then
                    group:for_each(func, recurse)
                end
            end
            func(basic)
        end
    end
end

function group:for_each_alive(func, recurse)
    for i = 1, self.length do
        ---
        --- @type flora.base.basic
        ---
        local basic = self.members[i]
        if basic and basic.exists and basic.alive then
            if recurse then
                if basic:is(group) or basic:is(sprite_group) then
                    group:for_each_alive(func, recurse)
                end
            end
            func(basic)
        end
    end
end

function group:for_each_dead(func, recurse)
    for i = 1, self.length do
        ---
        --- @type flora.base.basic
        ---
        local basic = self.members[i]
        if basic and not basic.alive then
            if recurse then
                if basic:is(group) or basic:is(sprite_group) then
                    group:for_each_dead(func, recurse)
                end
            end
            func(basic)
        end
    end
end

function group:dispose()
    group.super.dispose(self)

    for i = 1, self.length do
        local obj = self.members[i]
        if obj then
            if flora.config.debug_mode then
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
function group:__tostring()
    return "group (length: " .. self.length .. ")"
end

return group