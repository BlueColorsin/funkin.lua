---
--- @class flora.utils.Pool
---
local Pool = Class:extend("Pool", ...)

function Pool:constructor(class)
	self._pooledClass = class
	self._pool = {}

	self.count = 1
end

function Pool:get()
	if self.count == 1 then
		return self._pooledClass:new()
	end
	self.count = self.count - 1
	return self._pool[self.count]
end

function Pool:put(obj)
	if obj == nil then
		return
	end
	local i = table.indexOf(self._pool, obj)
	if i == -1 or i >= self.count then
		if obj.destroy ~= nil then
			obj:destroy()
		end
		self._pool[self.count] = obj
		self.count = self.count + 1
	end
end

function Pool:putUnsafe(obj)
	if obj == nil then
		return
	end
	if obj.destroy ~= nil then
		obj:destroy()
	end
	self._pool[self.count] = obj
	self.count = self.count + 1
end

function Pool:preAllocate(objAmount)
	while objAmount > 0 do
		objAmount = objAmount - 1
		self._pool[self.count] = self._pooledClass:new()
		self.count = self.count + 1
	end
end

function Pool:clear()
	self.count = 0
	self._pool = {}
end

return Pool