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

    ---
    --- The maximum amount of members allowed in this group.
    ---
    self.maxSize = 0

    ---
    --- The signal that is emitted when an object is added to this group.
    ---
    self.memberAdded = Signal:new():type(Object)

    ---
    --- The signal that is emitted when an object is removed from this group.
    ---
    self.memberRemoved = Signal:new():type(Object)

    ---
    --- @protected
    ---
    self._marker = 1
end

---
--- @param  obj  flora.base.Basic  The object to add to this group.
--- 
--- @return flora.base.Basic
---
function Group:add(obj)
    if not obj then
        Flora.log:warn("Cannot add an invalid object to a group!")
        return obj
    end
    if table.contains(self.members, obj) then
        return obj
    end
    -- look for the index of the first null object in this group
	local nullIndex = -1
	for i = 1, self.length do
		if self.members[i] == nil then
			nullIndex = i
			break
		end
	end

	-- then replace that null object with our new one (if the null one was found)
	if nullIndex ~= -1 then
		self.members[nullIndex] = obj
		if nullIndex >= self.length then
			self.length = nullIndex + 1
		end
		self.memberAdded:emit(obj)
		return obj
	end

	-- if the group is full, return member and don't continue
	if self.maxSize > 0 and self.length >= self.maxSize then
		return obj
	end

	-- increase length and add to members list
	table.insert(self.members, obj)
	self.length = self.length + 1

	self.memberAdded:emit(obj)
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
        Flora.log:warn("Cannot add an invalid object to a group!")
        return obj
    end
    if table.contains(self.members, obj) then
        return obj
    end
    -- set the member in this position of the group
	-- if said position of the group is nil
	if pos < self.length and self.members[pos] == nil then
		self.members[pos] = obj
		self.memberAdded:emit(obj)
		return obj
	end

	-- if the group is full, return member and don't continue
	if self.maxSize > 0 and self.length >= self.maxSize then
		return obj
	end
	
	-- increase length and add to members list
	table.insert(self.members, obj)
	self.length = self.length + 1

	self.memberAdded:emit(obj)
    return obj
end

---
--- @param  obj     flora.base.Basic  The object to remove from this group.
--- @param  splice  boolean?          Whether or not to splice the object from the group. Turn this off if you plan to use recycling on this group!
--- 
--- @return flora.base.Basic
---
function Group:remove(obj, splice)
    splice = splice and splice or true
    if not obj then
        Flora.log:warn("Cannot remove an invalid object from a group!")
        return obj
    end
    local index = table.indexOf(self.members, obj)
	if index == -1 then
		return obj
	end
    if splice then
        table.remove(self.members, index)
        self.length = self.length - 1
    else
        self.members[index] = nil
    end
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

function Group:getFirstAvailable(class, force)
	for i = 1, self.length do
		local m = self.members[i]
		if (m ~= nil and not m.exists and (class == nil or m:is(class))) then
			if not (force and not m:is(class)) then
				return m
			end
		end
	end
	return nil
end

function Group:recycleCreateObject(factory, class)
	if factory then
		return self:add(factory())
	end
	if class then
		return self:add(class())
	end
	return nil
end

function Group:recycle(class, factory, force, revive)
	force = force and force or false
	revive = revive and revive or true

	-- rotated recycle
	if self.maxSize > 0 then
		if self.length < self.maxSize then
			return self:recycleCreateObject(factory, class)
		end
		local member = self.members[self._marker]
		self._marker = self._marker + 1

		if self._marker >= self.maxSize then
			self._marker = 1
		end
		if revive then
			member:revive()
		end
		return member
	end

	-- grow-style recycle - grab the first member with it's "exists" field set to false
	local member = self:getFirstAvailable(class, force)
	if member ~= nil then
		if revive then
			member:revive()
		end
		return member
	end
	return self:recycleCreateObject(factory, class)
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
    local oldDefaultCameras = Flora.cameras.defaultCameras
    if self._cameras then
        Flora.cameras.defaultCameras = self._cameras
    end
    for i = 1, self.length do
        local obj = self.members[i]
        if obj and obj.exists and obj.visible then
            obj:draw()
        end
    end
    Flora.cameras.defaultCameras = oldDefaultCameras
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
            if Flora.config.debugMode then
                Flora.log:verbose("Disposing object " .. tostring(obj))
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