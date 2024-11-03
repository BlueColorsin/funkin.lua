---@diagnostic disable: invisible

if Flora then
    print("Flora was already initialized!")
    return Flora
end

io.stdout:setvbuf("no")

require("flora.libs.autobatch")

require("flora.utils.lua.Math")
require("flora.utils.lua.String")
require("flora.utils.lua.Table")

local lily = require("flora.libs.lily")

local displayedMemory = 0.0
local displayedVRAM = 0.0

local function busySleep(time) -- uses more cpu BUT results in more accurate fps
    if time <= 0 then
        return
    end
    local duration = os.clock() + time
    love.timer.sleep(time)
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

Xml = require("flora.libs.Xml")
Json = require("flora.libs.Json")
Class = require("flora.libs.Classic")

Object = require("flora.Object")
RefCounted = require("flora.RefCounted")
Basic = require("flora.Basic")

Bit = require("flora.utils.Bit")
Axes = require("flora.utils.Axes")
Path = require("flora.utils.Path")
File = require("flora.utils.File")
Save = require("flora.utils.Save")
Pool = require("flora.utils.Pool")
Color = require("flora.utils.Color")
Timer = require("flora.utils.Timer")
Signal = require("flora.utils.Signal")

HorizontalAlign = require("flora.utils.HorizontalAlign")
VerticalAlign = require("flora.utils.VerticalAlign")

Texture = require("flora.assets.Texture")

Camera = require("flora.display.Camera")
Group = require("flora.display.Group")
Object2D = require("flora.display.Object2D")

State = require("flora.display.State")
SubState = require("flora.display.SubState")

Sprite = require("flora.display.Sprite")
SpriteGroup = require("flora.display.SpriteGroup")
Text = require("flora.display.Text")

Frame = require("flora.animation.FrameData")
FrameCollection = require("flora.animation.FrameCollection")

TileFrames = require("flora.animation.TileFrames")
AtlasFrames = require("flora.animation.AtlasFrames")

Flicker = require("flora.display.effects.Flicker")

KeyCode = require("flora.input.keyboard.KeyCode")

Vector2 = require("flora.math.Vector2")
Rect2 = require("flora.math.Rect2")

Ease = require("flora.tweens.Ease")
Tween = require("flora.tweens.Tween")

Sound = require("flora.Sound")

local TimerManager = require("flora.plugins.TimerManager")
local TweenManager = require("flora.plugins.TweenManager")

---
--- @class flora.Flora
---
--- The main class used to initialize Flora
---
Flora = Class:extend("Flora", ...)

---
--- The amount of time passed since the last frame. (in seconds)
--- 
--- @type number
---
Flora.deltaTime = 0.0

---
--- Controls whether or not the game window is in fullscreen.
---
--- @type boolean
---
Flora.fullscreen = nil

--- 
--- A helper object for configuring Flora.
--- 
--- @type flora.Config
--- 
Flora.config = require("flora.Config"):new()

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
Flora.import = function(modname)
    return require(Flora.config.sourceFolder .. "." .. modname)
end

---
--- The name of the current operating system.
---
--- @type string
---
Flora.os = love.system.getOS()

--- 
--- The native system API for Flora.
--- 
--- @type flora.native
--- 
Flora.native = require("flora.native")

---
--- The logging system for Flora.
---
--- @type flora.debug.Log
---
Flora.log = require("flora.debug.Log"):new()

---
--- The object responsible for managing signals.
---
--- @type flora.frontends.SignalFrontEnd
---
Flora.signals = require("flora.frontends.SignalFrontEnd"):new()

---
--- The object responsible for managing assets.
---
--- @type flora.frontends.AssetFrontEnd
---
Flora.assets = require("flora.frontends.AssetFrontEnd"):new()

---
--- The object responsible for managing cameras.
---
--- @type flora.frontends.CameraFrontEnd
---
Flora.cameras = require("flora.frontends.CameraFrontEnd"):new()

---
--- The object responsible for managing keyboard input.
---
--- @type flora.input.keyboard.KeyboardManager
---
Flora.keys = require("flora.input.keyboard.KeyboardManager"):new()

---
--- The object responsible for managing mouse input.
---
--- @type flora.input.mouse.Pointer
---
Flora.mouse = require("flora.input.mouse.Pointer"):new()

---
--- The object responsible for managing sound playback.
---
--- @type flora.frontends.SoundFrontEnd
---
Flora.sound = require("flora.frontends.SoundFrontEnd"):new()

---
--- The object responsible for managing plugins.
---
--- @type flora.frontends.PluginFrontEnd
---
Flora.plugins = require("flora.frontends.PluginFrontEnd"):new()

---
--- The object responsible for managing random number generation.
--- 
--- @type flora.math.Random
---
Flora.random = require("flora.math.Random"):new()

---
--- The object responsible for correctly sizing the game to the window.
---
--- @type flora.display.scalemodes.BaseScaleMode
---
Flora.scaleMode = require("flora.display.scalemodes.RatioScaleMode"):new()

---
--- The object responsible for displaying a tray
--- for adjusting the game's volume.
---
--- @type flora.display.soundtray.DefaultSoundTray
---
Flora.soundTray = require("flora.display.soundtray.DefaultSoundTray"):new()

---
--- The default Save data object for flora.
--- 
--- Contains `volume` and `muted`.
--- 
--- @type flora.utils.Save
---
Flora.save = nil

---
--- The first available camera, usually set
--- after `flora.cameras` gets reset.
--- 
--- @type flora.display.Camera
---
Flora.camera = nil

---
--- An instance of the currently loaded State.
---
--- @type flora.display.State
---
Flora.state = nil

---
--- The width of the game area. (in pixels)
--- 
--- If you want to change the game width AFTER initializing
--- flora, please use `flora.resizeGame()`!
---
Flora.gameWidth = 640

---
--- The height of the game area. (in pixels)
--- 
--- If you want to change the game height AFTER initializing
--- flora, please use `flora.resizeGame()`!
---
Flora.gameHeight = 640

---
--- Starts the Flora engine after it has been
--- successfully configured.
---
function Flora.start()
    Flora.native.setDarkMode(true)
    if Flora.config.debugMode then
        Flora.log:verbose("Starting engine")
    end
    Flora.save = Save:new()
    Flora.save:bind("flora")

    Flora._fullscreen = love.window.getFullscreen()

    if Flora.save.data.volume then
        Flora.sound.volume = Flora.save.data.volume
    end
    if Flora.save.data.muted then
        Flora.sound.muted = Flora.save.data.muted
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
        local fpsTimer = 0.0

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
            
            local focused = love.window.hasFocus()

            local cap = (focused and Flora.config.maxFPS or 10)
            local capDt = (cap > 0) and 1 / cap or 0

            if love.timer then
                dt = math.min(love.timer.step(), math.max(capDt, 0.0416))
                Flora.deltaTime = dt
            end
            
            fpsTimer = fpsTimer + dt
            if fpsTimer >= 0.5 then
                fpsTimer = 0.0
                displayedMemory = collectgarbage("count") * 1024

                local stats = love.graphics.getStats()
                displayedVRAM = stats.texturememory
            end

            if love.update then
                love.update(dt)
            end

            if love.graphics and love.graphics.isActive() then
                love.graphics.origin()
                love.graphics.clear(love.graphics.getBackgroundColor())
                
                if love.draw then
                    love.draw()
                end

                love.graphics.present()
            end
            busySleep(capDt - dt)
            
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
        Flora.log:print(str, cur_file, cur_line)
    end
    Flora.gameWidth = Flora.config.gameWidth
    Flora.gameHeight = Flora.config.gameHeight

    TimerManager.global = TimerManager:new()
    Flora.plugins:add(TimerManager.global)

    TweenManager.global = TweenManager:new()
    Flora.plugins:add(TweenManager.global)

    if Flora.config.initialState then
        Flora._requestedState = Flora.config.initialState
    else
        Flora._requestedState = require("flora.display.State"):new()
    end

    if Flora.config.debugMode then
        Flora.log:verbose("Requesting switch to initial State")
    end
    Flora.cameras:reset()
    Flora._switchState()

    Flora.scaleMode:onMeasure(love.graphics.getWidth(), love.graphics.getHeight())

    if Flora.config.debugMode then
        Flora.log:success("Started engine successfully")
    end
    love.args = {}
    if arg then
        for i = 1, #arg do
            if arg[i] == "-profile" or arg[i] == "--profile" then
                table.insert(love.args, "profile")
            end
        end
    end
    if table.contains(love.args, "profile") then
        love.profiler = require("profiler")
        love.profiler:start('once')
    end
end

function Flora.preUpdate(dt)
    if Flora.soundTray and Flora.soundTray.exists and Flora.soundTray.active then
        Flora.soundTray:update(dt)
    end
end

function Flora.postDraw()
    if Flora.soundTray and Flora.soundTray.exists and Flora.soundTray.visible then
        Flora.soundTray:draw()
    end
    local displayedFPS = love.timer.getFPS()
    if Flora.config.maxFPS > 0 and displayedFPS > Flora.config.maxFPS then
        displayedFPS = Flora.config.maxFPS
    end
    local displayedText = "FPS: " .. displayedFPS .. "\n" ..
        "RAM: " .. math.humanizeBytes(displayedMemory) .. " | " ..
        "VRAM: " .. math.humanizeBytes(displayedVRAM)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(displayedText, 10.5, 3.5, 0)
    love.graphics.print(displayedText, 11, 4, 0)
    love.graphics.print(displayedText, 11.5, 4.5, 0)
    love.graphics.print(displayedText, 12, 5, 0)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(displayedText, 10, 3, 0)
end

---
--- Switches to a given State, and disposes of the old one.
--- 
--- @param  newState  flora.display.State  The new State to switch to.
---
function Flora.switchState(newState)
    if Flora.config.debugMode then
        Flora.log:verbose("Running state outro on current state")
    end
    local stateOnCall = Flora.state
    stateOnCall:startOutro(function()
        if Flora.state == stateOnCall then
            Flora._requestedState = newState
        else
            Flora.log:warn("onOutroComplete was called after the state was switched, ignoring!")
        end
    end)
end

---
--- Switches to a given State, and disposes of the old one.
--- 
--- @param  newState  flora.display.State  The new State to switch to.
---
function Flora.forceSwitchState(newState)
    if Flora.config.debugMode then
        Flora.log:verbose("Running state outro on current state")
    end
    Flora._requestedState = newState
end

---
--- Resets the current state with the given parameters.
---
function Flora.resetState(...)
    local cl = require(Flora.state.__path)
    Flora.switchState(cl:new(...))
end

---
--- Resets the current state with the given parameters.
---
function Flora.forceResetState(...)
    local cl = require(Flora.state.__path)
    Flora._requestedState = cl:new(...)
end

function Flora.resizeGame(width, height)
    local oldWidth = Flora.gameWidth
    local oldHeight = Flora.gameHeight

    for i = 1, Flora.cameras.list.length do
        ---
        --- @type flora.display.Camera
        ---
        local cam = Flora.cameras.list[i]
        if cam and cam.width == oldWidth and cam.height == oldHeight then
            cam:resize(width, height)
        end
    end
    
    Flora.gameWidth = width
    Flora.gameHeight = height

    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()
    Flora.scaleMode:onMeasure(ww, wh)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
--- @type boolean
---
Flora._fullscreen = nil

---
--- @protected
--- @type flora.display.State
---
Flora._requestedState = nil

---
--- @protected
---
function Flora._switchState()
    Flora.signals.preStateSwitch:emit()
    
    if Flora.state then
        Flora.state:dispose() 
    end
    Flora.cameras:reset()

    Flora.state = Flora._requestedState
    Flora._requestedState = nil

    Flora.signals.preStateCreate:emit(Flora.state)
    Flora.state:ready()

    love.timer.step()
    
    if Flora.config.debugMode then
        Flora.log:success("State switched successfully")
    end
    Flora.signals.postStateSwitch:emit()
end

---
--- @protected
---
function Flora.get_fullscreen()
    return Flora._fullscreen
end

---
--- @protected
---
function Flora.set_fullscreen(val)
    Flora._fullscreen = val
    if love.window then
        love.window.setFullscreen(val, "desktop")
    end
    return Flora._fullscreen
end

---
--- @protected
---
function love.update(dt)
    if love.window.hasFocus() then
        if Flora._requestedState then
            Flora._switchState()
        end
        if Flora.preUpdate then
            Flora.preUpdate(dt)
        end
        Flora.signals.preUpdate:emit()

        Flora.mouse:update()
        
        Flora.sound:update()
        Flora.plugins:update(dt)

        if Flora.state then
            Flora.state:tryUpdate(dt)
        end
        Flora.cameras:update(dt)

        Flora.keys:update()
        Flora.mouse:postUpdate()
        
        if Flora.postUpdate then
            Flora.postUpdate(dt)
        end
        Flora.signals.postUpdate:emit()
    else
        Flora.sound:update()
    end
end

---
--- @protected
---
function love.draw()
    for i = 1, Flora.cameras.list.length do
        local cam = Flora.cameras.list.members[i]
        if cam and cam.exists and cam.visible then
            cam:clear()
        end
    end
    if Flora.preDraw then
        Flora.preDraw()
    end
    Flora.signals.preDraw:emit()

    if not Flora.plugins.drawAbove then
        Flora.plugins:draw()
    end
    if Flora.state then
        Flora.state:draw()
    end
    if Flora.plugins.drawAbove then
        Flora.plugins:draw()
    end
    for i = 1, Flora.cameras.list.length do
        local cam = Flora.cameras.list.members[i]
        if cam and cam.exists and cam.visible then
            cam:draw()
        end
    end

    if not Flora.mouse.useSystemCursor and Flora.mouse.visible then
        Flora.mouse:draw()
    end

    if Flora.postDraw then
        Flora.postDraw()
    end
    Flora.signals.postDraw:emit()
end

---
--- @protected
---
function love.resize(width, height)
    Flora.scaleMode:onMeasure(width, height)
end

function love.keypressed(key, scancode, isrepeat)
    Flora.keys:keyPressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
    Flora.keys:keyReleased(key, scancode, isrepeat)
end

function love.mousemoved(x, y, _, _, _)
    if love.window.hasFocus() then
        Flora.mouse:onMoved(x, y)
    end
end

function love.mousepressed(_, _, button, _, _)
    if love.window.hasFocus() then
        Flora.mouse:onPressed(button)
    end
end

function love.mousereleased(_, _, button, _, _)
    if love.window.hasFocus() then
        Flora.mouse:onReleased(button)
    end
end

function love.wheelmoved(dx, dy)
    if love.window.hasFocus() then
        Flora.mouse:onWheelMoved(dx, dy)
    end
end

function love.quit()
    Flora.signals.preQuit:emit()
    if Flora.signals.preQuit._cancelled then
        return true
    end
    lily.quit()
    if table.contains(love.args, "profile") then
        love.profiler:stop()
        love.profiler:writeReport("profiler_report.txt")
    end
    return false
end

return Flora