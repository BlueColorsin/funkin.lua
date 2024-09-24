---@diagnostic disable: inject-field

--- 
--- An object that can hold several more game objects.
--- 
--- @class flora.display.group : flora.base.basic
--- 
local group = basic:extend()

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
    obj.__grp_index = self.length + 1
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
    obj.__grp_index = pos
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
    table.remove(obj, obj.__grp_index)
    obj.__grp_index = -1
    self.length = self.length - 1
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
    for i = 1, self.length do
        local obj = self.members[i]
        if obj and obj.exists and obj.visible then
            obj:draw()
        end
    end
end

---
--- Returns a string representation of this object.
---
function group:__tostring()
    return "group (length: " .. self.length .. ")"
end

return group