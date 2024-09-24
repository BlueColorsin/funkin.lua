---
---@diagnostic disable: inject-field
---

--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

---
--- @class flora.libs.class
---
local class = {}
class.__index = class

function class:constructor(...)
end

function class:__get(var)
    return nil
end

function class:__set(var, val)
    return true
end

function class:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function class:implement(...)
    for _, cls in pairs({ ... }) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

function class:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function class:__tostring()
    return "class"
end

function class:new(...)
    local obj = setmetatable({}, self)
    local og = getmetatable(obj)
    setmetatable(obj, {
        __index = function(object, property)
            if property ~= "__get" then
                local pain = object:__get(property)
                if pain ~= nil then
                    return pain
                end
            end
            return og[property]
        end,
        __newindex = function(object, property, value)
            if object.__initializing then
                rawset(object, property, value)
                return
            end
            local doRawSet = object:__set(property, value)
            if doRawSet then
                rawset(object, property, value)
            end
        end
    })
    obj.__initializing = true
    obj:constructor(...)
    obj.__initializing = false
    return obj
end

return class