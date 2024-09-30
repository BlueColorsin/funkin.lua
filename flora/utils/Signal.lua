---
--- @class flora.utils.Signal 
---
local Signal = Class:extend("Signal", ...)

function Signal:constructor()
    ---
    --- @protected
    ---
    self.__connected = {}
end

-- This function is syntax sugar.
function Signal:type(...)
	return self
end

---
--- Connects a listener function to this signal.
---
--- @param listener  function  The listener to connect to this signal.
---
function Signal:connect(listener)
	if type(listener) ~= "function" or table.contains(self.__connected, listener) then
		return
	end
	table.insert(self.__connected, listener)
end

---
--- Disconnects a listener function from this signal.
---
--- @param listener  function  The listener to disconnect from this signal.
---
function Signal:disconnect(listener)
	if type(listener) ~= "function" or not table.contains(self.__connected, listener) then
		return
	end
	table.remove_item(self.__connected, listener)
end

---
--- Emits/calls each listener functions connected
--- to this signal.
---
--- @param ...  vararg  The parameters to call on each function.
---
function Signal:emit(...)
	for i = 1, #self.__connected do
		self.__connected[i](...)
	end
end

---
--- Removes all listener functions from this signal.
---
function Signal:reset()
	self.__connected = {}
end

return Signal