--
-- https://github.com/rxi/classic
--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--
-- Modified for FNF-Aster purposes, ralty
-- Modified syntax slightly, swordcube
--

---
--- @class flora.libs.Class
---
local Class = {__class = "Class"}

function Class:constructor(...) end

local __class, get_, set_, _, recursiveget = "__class", "get_", "set_", "_"
function recursiveget(class, k)
	local v = rawget(class, k)
	if v == nil and class.super then return recursiveget(class.super, k)
	else return v end
end

function Class:__index(k)
	local cls = getmetatable(self)
	local getter = recursiveget(rawget(self, __class) == nil and cls or self, get_ .. k)
	if getter == nil then
		local v = rawget(self, k, _ .. k)
		if v ~= nil then return v end
		return cls[k]
	else return getter(self) end
end

function Class:__newindex(k, v)
	if self.__initializing then
		return rawset(self, k, v)
	end
	local isObj = rawget(self, __class) == nil
	local setter = recursiveget(isObj and getmetatable(self) or self, set_ .. k)
	if setter == nil then return rawset(self, k, v)
	elseif isObj then return setter(self, v)
	else return setter(v) end
end

function Class:extend(type, path)
	local cls = {}

	for k, v in pairs(self) do
		if k:sub(1, 2) == "__" then cls[k] = v end
	end

	cls.__class = type or ("Unknown(" .. self.__class .. ")")
	cls.__path = path
	cls.super = self
	setmetatable(cls, self)

	return cls
end

function Class:implement(...)
	for _, cls in pairs({...}) do
		for k, v in pairs(cls) do
			if self[k] == nil and type(v) == "function" and k ~= "constructor" and k ~= "new" and k:sub(1, 2) ~= "__" then
				self[k] = v
			end
		end
	end
end

function Class:exclude(...)
	for i = 1, select("#", ...) do
		self[select(i, ...)] = nil
	end
end

function Class:is(T)
	local mt = self
	repeat
		mt = getmetatable(mt)
		if mt == T then return true end
	until mt == nil
	return false
end

function Class:__tostring() return self.__class end

function Class:new(...)
	local obj = setmetatable({}, self)
	obj.__initializing = true
	obj:constructor(...)
	obj.__initializing = false
	return obj
end

return Class