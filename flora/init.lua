if flora then
    print("Flora was already initialized!")
    return flora
end

io.stdout:setvbuf("no")

local displayed_memory = 0.0
local displayed_vram = 0.0

local function busy_sleep(time) -- uses more cpu BUT results in more accurate fps
    if time <= 0 then
        return
    end
    local duration = os.clock() + time
    while os.clock() < duration do end
end
if (love.filesystem.isFused() or not love.filesystem.getInfo("assets")) and love.filesystem.mountFullPath then
    love.filesystem.mountFullPath(love.filesystem.getSourceBaseDirectory(), "")
end

---
--- Gets the current device the game is running on.
---
--- @return string -- The current device. (`Desktop` or `Mobile`)
---
function love.system.getDevice()
	local os = love.system.getOS()
	if os == "Android" or os == "iOS" then
		return "Mobile"
	elseif os == "OS X" or os == "Windows" or os == "Linux" then
		return "Desktop"
	end
	return "Unknown"
end

require("flora.utils.lua.math")

xml = require("flora.libs.xml")
json = require("flora.libs.json")
class = require("flora.libs.classic")

object = require("flora.base.object")
ref_counted = require("flora.base.ref_counted")
basic = require("flora.base.basic")

texture = require("flora.assets.texture")

camera = require("flora.display.camera")
group = require("flora.display.group")
object2d = require("flora.display.object2d")
screen = require("flora.display.screen")
sprite = require("flora.display.sprite")
text = require("flora.display.text")

keycode = require("flora.input.keyboard.keycode")

vector2 = require("flora.math.vector2")

bit = require("flora.utils.bit")
axes = require("flora.utils.axes")
color = require("flora.utils.color")

horizontal_align = require("flora.utils.horizontal_align")
vertical_align = require("flora.utils.vertical_align")

sound = require("flora.sound")

---
--- @class flora
---
--- The main class used to initialize Flora
---
flora = class:extend()

---
--- Loads the given module, returns any value returned by the given module(`true` when `nil`).
---
--- [View documentation for Lua's require function](command:extension.lua.doc?["en-us/51/manual.html/pdf-require"])
---
--- This function provides raw access to Lua's `require` function.
--- 
--- Flora shadows the original function to load from the source folder,
--- set when configuring Flora.
--- 
--- You should use this function when you need to import
--- another class from Flora itself, or an external library.
---
--- @param  modname  string
--- @return unknown
---
flora.import = function(modname)
    return require(flora.config.source_folder .. "." .. modname)
end

--- 
--- A helper object for configuring Flora.
--- 
--- @type flora.config
--- 
flora.config = require("flora.config"):new()

---
--- The name of the current operating system.
---
--- @type string
---
flora.os = love.system.getOS()

--- 
--- The native system API for Flora.
--- 
--- @type flora.native
--- 
flora.native = require("flora.native")

---
--- The logging system for Flora.
---
--- @type flora.debug.log
---
flora.log = require("flora.debug.log"):new()

---
--- The object responsible for managing assets.
---
--- @type flora.frontends.asset_front_end
---
flora.assets = require("flora.frontends.asset_front_end"):new()

---
--- The object responsible for managing cameras.
---
--- @type flora.frontends.camera_front_end
---
flora.cameras = require("flora.frontends.camera_front_end"):new()

---
--- The object responsible for managing keyboard input.
---
--- @type flora.input.keyboard.keyboard_manager
---
flora.keys = require("flora.input.keyboard.keyboard_manager"):new()

---
--- The object responsible for managing mouse input.
---
--- @type flora.input.mouse.pointer
---
flora.mouse = require("flora.input.mouse.pointer"):new()

---
--- The object responsible for managing sound playback.
---
--- @type flora.frontends.sound_front_end
---
flora.sound = require("flora.frontends.sound_front_end"):new()

---
--- The object responsible for correctly sizing the game to the window.
---
--- @type flora.display.scalemodes.base_scale_mode
---
flora.scale_mode = require("flora.display.scalemodes.ratio_scale_mode"):new()

---
--- The first available camera, usually set
--- after `flora.cameras` gets reset.
--- 
--- @type flora.display.camera
---
flora.camera = nil

---
--- An instance of the currently loaded screen.
---
--- @type flora.display.screen
---
flora.screen = nil

---
--- Starts the Flora engine after it has been
--- successfully configured.
---
function flora.start()
    flora.native.set_dark_mode(true)
    if flora.config.debug_mode then
        flora.log:verbose("Starting engine")
    end
    love.run = function()
        if love.math then
            love.math.setRandomSeed(os.time())
        end
        if love.load then
            love.load(love.arg.parseGameArguments(arg), arg)
        end
        if love.timer then
            love.timer.step()
        end
    
        local dt = 0.0
        local fps_timer = 0.0

        return function()
            if love.event then
                love.event.pump()
                for name, a, b, c, d, e, f in love.event.poll() do
                    if name == "quit" then
                        if not love.quit or not love.quit() then
                            return a or 0
                        end
                    end
                    love.handlers[name](a,b,c,d,e,f)
                end
            end
            
            if love.timer then
                dt = love.timer.step()
            end
            
            fps_timer = fps_timer + dt
            if fps_timer >= 0.5 then
                fps_timer = 0.0
                displayed_memory = collectgarbage("count") * 1024

                local stats = love.graphics.getStats()
                displayed_vram = stats.texturememory
            end

            local focused = love.window.hasFocus()

            local cap = (focused and flora.config.max_fps or 10)
            local cap_dt = (cap > 0) and 1 / cap or 0

            if love.update then
                love.update(dt)
            end

            if love.graphics and love.graphics.isActive() then
                love.graphics.origin()
                love.graphics.clear(love.graphics.getBackgroundColor())

                if flora.pre_draw then
                    flora.pre_draw()
                end
                
                if love.draw then
                    love.draw()
                end

                if flora.post_draw then
                    flora.post_draw()
                end

                love.graphics.present()
            end
            busy_sleep(cap_dt)
            
            if focused then
                collectgarbage("step")
            else
                collectgarbage("collect")
                collectgarbage("collect")
            end
        end
    end
    print = function(...)
        local str = ""
        local arg_count = select("#", ...)
        for i = 1, arg_count do
            str = str .. tostring(select(i, ...))
            if i < arg_count then
                str = str .. ", "
            end
        end
        local cur_file = debug.getinfo(2, "S").source:sub(2)
        local cur_line = debug.getinfo(2, "l").currentline
        flora.log:print(str, cur_file, cur_line)
    end
    flora._canvas = love.graphics.newCanvas(flora.config.game_size.x, flora.config.game_size.y)

    if flora.config.initial_screen then
        flora._requested_screen = flora.config.initial_screen
    else
        flora._requested_screen = require("flora.display.screen"):new()
    end

    if flora.config.debug_mode then
        flora.log:verbose("Requesting switch to initial screen")
    end
    flora._switch_screen()
    flora.scale_mode:on_measure(love.graphics.getWidth(), love.graphics.getHeight())

    if flora.config.debug_mode then
        flora.log:success("Started engine successfully")
    end
end

function flora.pre_draw()

end

function flora.post_draw()
    local displayed_fps = love.timer.getFPS()
    local displayed_text = "FPS: " .. displayed_fps .. "\n" ..
        "RAM: " .. math.humanize_bytes(displayed_memory) .. " | " ..
        "VRAM: " .. math.humanize_bytes(displayed_vram)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(displayed_text, 10.5, 3.5, 0)
    love.graphics.print(displayed_text, 11, 4, 0)
    love.graphics.print(displayed_text, 11.5, 4.5, 0)
    love.graphics.print(displayed_text, 12, 5, 0)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(displayed_text, 10, 3, 0)
end

---
--- Switches to a given screen, and disposes of the old one.
--- 
--- @param  new_screen  flora.display.screen  The new screen to switch to.
---
function flora.switch_screen(new_screen)
    if flora.config.debug_mode then
        flora.log:verbose("Requesting screen switch")
    end
    flora._requested_screen = new_screen
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
--- @type love.Canvas
---
flora._canvas = nil

---
--- @protected
--- @type flora.display.screen
---
flora._requested_screen = nil

---
--- @protected
---
function flora._switch_screen()
    if flora.screen then
       flora.screen:dispose() 
    end
    flora.screen = flora._requested_screen
    flora.screen:ready()

    flora.cameras:reset()
    
    if flora.config.debug_mode then
        flora.log:success("Screen switched successfully")
    end
    flora._requested_screen = nil
end

---
--- @protected
---
function love.update(dt)
    flora.sound:update()
    
    if love.window.hasFocus() then
        flora.mouse:update()

        if flora._requested_screen then
            flora._switch_screen()
        end

        if flora.screen then
            flora.screen:update(dt)
        end
    
        for i = 1, flora.cameras.list.length do
            local cam = flora.cameras.list.members[i]
            if cam and cam.exists and cam.active then
                cam:update(dt)
            end
        end

        flora.keys:update()
        flora.mouse:post_update()
    end
end

---
--- @protected
---
function love.draw()
    for i = 1, flora.cameras.list.length do
        local cam = flora.cameras.list.members[i]
        if cam and cam.exists and cam.visible then
            cam:clear()
        end
    end

    if flora.screen then
        flora.screen:draw()
    end
    love.graphics.setCanvas(flora._canvas)
    
    for i = 1, flora.cameras.list.length do
        local cam = flora.cameras.list.members[i]
        if cam and cam.exists and cam.visible then
            cam:draw()
        end
    end

    love.graphics.setCanvas()
    love.graphics.draw(
        flora._canvas,
        flora.scale_mode.offset.x, flora.scale_mode.offset.y, 0,
        flora.scale_mode.scale.x, flora.scale_mode.scale.y
    )

    if not flora.mouse.use_system_cursor and flora.mouse.visible then
        flora.mouse:draw()
    end
end

---
--- @protected
---
function love.resize(width, height)
    flora.scale_mode:on_measure(width, height)
end

function love.keypressed(key, scancode, isrepeat)
    flora.keys:key_pressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
    flora.keys:key_released(key, scancode, isrepeat)
end

function love.mousemoved(x, y, _, _, _)
    if love.window.hasFocus() then
        flora.mouse:on_moved(x, y)
    end
end

function love.mousepressed(_, _, button, _, _)
    if love.window.hasFocus() then
        flora.mouse:on_pressed(button)
    end
end

function love.mousereleased(_, _, button, _, _)
    if love.window.hasFocus() then
        flora.mouse:on_released(button)
    end
end

return flora