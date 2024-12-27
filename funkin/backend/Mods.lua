---
---@class Mods
---
local Mods = {}

---the current loaded mod, gets priority over any global or any other mod
Mods.currentMod = "" ---@type string

---a table of every global mod
Mods.globalMods = {} ---@type table<string>

--- a table of every active mod
Mods.modsList = {} ---@type table<string>

--- a table of mod json data
Mods.modsData = {} ---@type table<table>

function Mods.reloadMods()
	Mods.modsList = love.filesystem.getDirectoryItems("mods/")

	-- filter for non valid mod folders
	for index, folder in ipairs(Mods.modsList) do
		if File.fileExists("mods/" .. folder .. "/mod.json") and File.dirExists("mods/" .. folder) then goto continue end

		table.remove(Mods.modsList, index)

		::continue::
	end

	-- maybe like rebuild the asset cache or smth
end

---returns a table of every possible location an asset can be
---@param key string
---@param subfolder? string
---@return table<string>
function Mods.allPaths(key, subfolder)
    local filepath = (subfolder and subfolder .. "/" or "") .. key

	local list = {}

	for _,mod in ipairs(Mods.modsList) do
		table.insert(list, "mods/" .. mod .. "/" .. filepath)
	end

	return list
end

---merger utils for the jsonCompound function 
local mergeFunctions = {
	override = function(master, append)
		table.set(master, append.key:split("."), append.value)
	end,

	insert = function (master, append)
		table.insert(table.get(master, append.key:split(".")), append.position, append.value)
	end,

	append = function(master, append)
		table.insert(table.get(master, append.key:split(".")), append.value)
	end,

	unshift = function(master, append)
		table.insert(table.get(master, append.key:split(".")), 0, append.value)
	end,

	remove = function(master, append)
		table.removeItem(table.get(master, append.key:split(".")), append.value)
	end
}

---
---returns a compounded json of all existing json files from every active mod   
---HEAVY WORK IN PROGRESS
---
--- @param key string
--- @param subfolder? string
--- @return table
function Mods.jsonCompound(key, subfolder)
	--bro thinks he's polymod 💀🙏
	local filepath = (subfolder or "data") .. "/" .. key .. ".json"

	local masterJson = Json.parse(File.read("assets/" .. filepath))

	for _, path in pairs(Mods.allPaths(key .. ".json", (subfolder or "data"))) do
		if not File.fileExists(path) then goto continue end

		local jsonData = Json.parse(File.read(path))

		if #jsonData < 0 then goto continue end

		for _, append in ipairs(jsonData) do
			mergeFunctions[append.mode](masterJson, append)
		end

	    ::continue::
	end

	return masterJson
end

return Mods