---
--- Accessed via `flora.plugins`.
---
--- @class flora.frontends.PluginFrontEnd : flora.base.Basic
---
local PluginFrontEnd = Basic:extend("PluginFrontEnd", ...)

function PluginFrontEnd:constructor()
    PluginFrontEnd.super.constructor(self)

    ---
    --- The list of all available plugins.
    --- 
    --- @type flora.display.Group
    ---
    self.list = Group:new()

    ---
    --- Controls whether or not plugins draw above
    --- the whole game.
    --- 
    --- @type boolean
    ---
    self.drawAbove = false
end

function PluginFrontEnd:update(dt)
    for i = 1, self.list.length do
        ---
        --- @type flora.base.Basic
        ---
        local plugin = self.list.members[i]

        if plugin and plugin.exists and plugin.active then
            plugin:update(dt)
        end
    end
end

function PluginFrontEnd:draw()
    for i = 1, self.list.length do
        ---
        --- @type flora.base.Basic
        ---
        local plugin = self.list.members[i]

        if plugin and plugin.exists and plugin.visible then
            plugin:draw()
        end
    end
end

function PluginFrontEnd:add(plugin)
    if table.contains(self.list.members, plugin) then
        Flora.log:warn("Plugin was already added!")
        return
    end
    self.list:add(plugin)
end

function PluginFrontEnd:insert(pos, plugin)
    if table.contains(self.list.members, plugin) then
        Flora.log:warn("Plugin was already added!")
        return
    end
    self.list:insert(pos, plugin)
end

function PluginFrontEnd:remove(plugin)
    if not table.contains(self.list.members, plugin) then
        Flora.log:warn("Cannot remove plugin that was not yet added!")
        return
    end
    self.list:remove(plugin)
end

-----------------------
--- [ Private API ] ---
-----------------------

return PluginFrontEnd