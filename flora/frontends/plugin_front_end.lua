---
--- Accessed via `flora.plugins`.
---
--- @class flora.frontends.plugin_front_end
---
local plugin_front_end = class:extend()

function plugin_front_end:constructor()
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

function plugin_front_end:add(cam)
    if table.contains(self.list.members, cam) then
        flora.log:warn("Camera was already added!")
        return
    end
    self.list:add(cam)
end

function plugin_front_end:insert(pos, cam)
    if table.contains(self.list.members, cam) then
        flora.log:warn("Camera was already added!")
        return
    end
    self.list:insert(pos, cam)
end

function plugin_front_end:remove(cam)
    if not table.contains(self.list.members, cam) then
        flora.log:warn("Cannot remove camera that was not yet added!")
        return
    end
    self.list:remove(cam)
end

-----------------------
--- [ Private API ] ---
-----------------------

return plugin_front_end