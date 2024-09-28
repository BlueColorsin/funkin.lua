---
--- Accessed via `flora.plugins`.
---
--- @class flora.frontends.plugin_front_end : flora.base.basic
---
local plugin_front_end = basic:extend()

function plugin_front_end:constructor()
    plugin_front_end.super.constructor(self)

    self._type = "plugin_front_end"

    ---
    --- The list of all available plugins.
    --- 
    --- @type flora.display.group
    ---
    self.list = group:new()

    ---
    --- Controls whether or not plugins draw above
    --- the whole game.
    --- 
    --- @type boolean
    ---
    self.draw_above = false
end

function plugin_front_end:update(dt)
    for i = 1, self.list.length do
        ---
        --- @type flora.base.basic
        ---
        local plugin = self.list.members[i]

        if plugin and plugin.exists and plugin.active then
            plugin:update(dt)
        end
    end
end

function plugin_front_end:draw()
    for i = 1, self.list.length do
        ---
        --- @type flora.base.basic
        ---
        local plugin = self.list.members[i]

        if plugin and plugin.exists and plugin.visible then
            plugin:draw()
        end
    end
end

function plugin_front_end:add(plugin)
    if table.contains(self.list.members, plugin) then
        flora.log:warn("Plugin was already added!")
        return
    end
    self.list:add(plugin)
end

function plugin_front_end:insert(pos, plugin)
    if table.contains(self.list.members, plugin) then
        flora.log:warn("Plugin was already added!")
        return
    end
    self.list:insert(pos, plugin)
end

function plugin_front_end:remove(plugin)
    if not table.contains(self.list.members, plugin) then
        flora.log:warn("Cannot remove plugin that was not yet added!")
        return
    end
    self.list:remove(plugin)
end

-----------------------
--- [ Private API ] ---
-----------------------

return plugin_front_end