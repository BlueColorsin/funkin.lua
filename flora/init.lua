
if flora then
    print("Flora was already initialized!")
    return flora
end

io.stdout:setvbuf("no")

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

Object = require("flora.base.Object")
RefCounted = require("flora.base.RefCounted")
Basic = require("flora.base.Basic")

Texture = require("flora.assets.Texture")

Camera = require("flora.display.Camera")
Group = require("flora.display.Group")
Object2D = require("flora.display.Object2D")
State = require("flora.display.State")
Sprite = require("flora.display.Sprite")
SpriteGroup = require("flora.display.SpriteGroup")
Text = require("flora.display.Text")

Frame = require("flora.display.animation.FrameData")
FrameCollection = require("flora.display.animation.FrameCollection")
AtlasFrames = require("flora.display.animation.AtlasFrames")

KeyCode = require("flora.input.keyboard.KeyCode")

Vector2 = require("flora.math.Vector2")

Bit = require("flora.utils.Bit")
Axes = require("flora.utils.Axes")
Path = require("flora.utils.Path")
File = require("flora.utils.File")
Save = require("flora.utils.Save")
Color = require("flora.utils.Color")
Timer = require("flora.utils.Timer")
Signal = require("flora.utils.Signal")

Ease = require("flora.Tweens.Ease")
Tween = require("flora.Tweens.Tween")

HorizontalAlign = require("flora.utils.HorizontalAlign")
VerticalAlign = require("flora.utils.VerticalAlign")

Sound = require("flora.Sound")

local TimerManager = require("flora.plugins.TimerManager")
local TweenManager = require("flora.plugins.TweenManager")

---
--- @class flora
---
--- The main class used to initialize Flora
---
flora = Class:extend()

--- 
--- A helper object for configuring Flora.
--- 
--- @type flora.Config
--- 
flora.config = require("flora.Config"):new()

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
    return require(flora.config.sourceFolder .. "." .. modname)
end

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
--- @type flora.debug.Log
---
flora.log = require("flora.debug.Log"):new()

---
--- The object responsible for managing assets.
---
--- @type flora.frontends.AssetFrontEnd
---
flora.assets = require("flora.frontends.AssetFrontEnd"):new()

---
--- The object responsible for managing cameras.
---
--- @type flora.frontends.CameraFrontEnd
---
flora.cameras = require("flora.frontends.CameraFrontEnd"):new()

---
--- The object responsible for managing keyboard input.
---
--- @type flora.input.keyboard.KeyboardManager
---
flora.keys = require("flora.input.keyboard.KeyboardManager"):new()

---
--- The object responsible for managing mouse input.
---
--- @type flora.input.mouse.Pointer
---
flora.mouse = require("flora.input.mouse.Pointer"):new()

---
--- The object responsible for managing sound playback.
---
--- @type flora.frontends.SoundFrontEnd
---
flora.sound = require("flora.frontends.SoundFrontEnd"):new()

---
--- The object responsible for managing plugins.
---
--- @type flora.frontends.PluginFrontEnd
---
flora.plugins = require("flora.frontends.PluginFrontEnd"):new()

---
--- The object responsible for managing signals.
---
--- @type flora.frontends.SignalFrontEnd
---
flora.signals = require("flora.frontends.SignalFrontEnd"):new()

---
--- The object responsible for correctly sizing the game to the window.
---
--- @type flora.display.scalemodes.BaseScaleMode
---
flora.scaleMode = require("flora.display.scalemodes.RatioScaleMode"):new()

---
--- The object responsible for displaying a tray
--- for adjusting the game's volume.
---
--- @type flora.display.soundtray.DefaultSoundTray
---
flora.soundTray = require("flora.display.soundtray.DefaultSoundTray"):new()

---
--- The default Save data object for flora.
--- 
--- Contains `volume` and `muted`.
--- 
--- @type flora.utils.Save
---
flora.save = nil

---
--- The first available camera, usually set
--- after `flora.cameras` gets reset.
--- 
--- @type flora.display.Camera
---
flora.camera = nil

---
--- An instance of the currently loaded State.
---
--- @type flora.display.State
---
flora.state = nil

---
--- The width of the game area. (in pixels)
--- 
--- If you want to change the game width AFTER initializing
--- flora, plEase use `flora.resizeGame()`!
---
flora.gameWidth = 640

---
--- The height of the game area. (in pixels)
--- 
--- If you want to change the game height AFTER initializing
--- flora, plEase use `flora.resizeGame()`!
---
flora.gameHeight = 640

---
--- Starts the Flora engine after it has been
--- successfully configured.
---
function flora.start()
    flora.native.setDarkMode(true)
    if flora.config.debugMode then
        flora.log:verbose("Starting engine")
    end
    flora.save = Save:new()
    flora.save:bind("flora")

    if flora.save.data.volume then
        flora.sound.volume = flora.save.data.volume
    end
    if flora.save.data.muted then
        flora.sound.muted = flora.save.data.muted
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

            local cap = (focused and flora.config.maxFPS or 10)
            local capDt = (cap > 0) and 1 / cap or 0

            if love.timer then
                dt = math.min(love.timer.step(), math.max(capDt, 0.0416))
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
            busySleep(capDt)
            
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
    flora.gameWidth = flora.config.gameWidth
    flora.gameHeight = flora.config.gameHeight

    flora._canvas = love.graphics.newCanvas(flora.gameWidth, flora.gameHeight)

    TimerManager.global = TimerManager:new()
    flora.plugins:add(TimerManager.global)

    TweenManager.global = TweenManager:new()
    flora.plugins:add(TweenManager.global)

    if flora.config.initialState then
        flora._requestedState = flora.config.initialState
    else
        flora._requestedState = require("flora.display.State"):new()
    end

    if flora.config.debugMode then
        flora.log:verbose("Requesting switch to initial State")
    end
    flora.cameras:reset()
    flora._switchState()

    flora.scaleMode:onMeasure(love.graphics.getWidth(), love.graphics.getHeight())

    if flora.config.debugMode then
        flora.log:success("Started engine successfully")
    end
end

function flora.preUpdate(dt)
    if flora.soundTray and flora.soundTray.exists and flora.soundTray.active then
        flora.soundTray:update(dt)
    end
end

function flora.postDraw()
    if flora.soundTray and flora.soundTray.exists and flora.soundTray.visible then
        flora.soundTray:draw()
    end

    local displayedFPS = love.timer.getFPS()
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
--- @param  new_State  flora.display.State  The new State to switch to.
---
function flora.switchState(new_State)
    if flora.config.debugMode then
        flora.log:verbose("Requesting State switch")
    end
    flora._requestedState = new_State
end

function flora.resizeGame(width, height)
    local oldWidth = flora.gameWidth
    local oldHeight = flora.gameHeight

    for i = 1, flora.cameras.list.length do
        ---
        --- @type flora.display.Camera
        ---
        local cam = flora.cameras.list[i]
        if cam and cam.width == oldWidth and cam.height == oldHeight then
            cam:resize(width, height)
        end
    end
    
    flora.gameWidth = width
    flora.gameHeight = height

    if flora._canvas then
        flora._canvas:release()
    end
    flora._canvas = love.graphics.newCanvas(flora.gameWidth, flora.gameHeight)

    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()
    flora.scaleMode:onMeasure(ww, wh)
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
--- @type flora.display.State
---
flora._requestedState = nil

---
--- @protected
---
function flora._switchState()
    flora.signals.preStateSwitch:emit()
    
    if flora.state then
        flora.state:dispose() 
    end
    flora.cameras:reset()

    flora.state = flora._requestedState
    flora._requestedState = nil

    flora.signals.preStateCreate:emit(flora.state)
    flora.state:ready()
    
    if flora.config.debugMode then
        flora.log:success("State switched successfully")
    end
    flora.signals.postStateSwitch:emit()
end

---
--- @protected
---
function love.update(dt)
    if love.window.hasFocus() then
        if flora._requestedState then
            flora._switchState()
        end

        if flora.preUpdate then
            flora.preUpdate(dt)
        end
        flora.signals.preUpdate:emit()

        flora.mouse:update()
        
        flora.sound:update()
        flora.plugins:update(dt)

        if flora.state then
            flora.state:update(dt)
        end
        flora.cameras:update(dt)

        flora.keys:update()
        flora.mouse:postUpdate()
        
        if flora.postUpdate then
            flora.postUpdate(dt)
        end
        flora.signals.postUpdate:emit()
    else
        flora.sound:update()
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
    
    if flora.preDraw then
        flora.preDraw()
    end
    flora.signals.preDraw:emit()

    if not flora.plugins.drawAbove then
        flora.plugins:draw()
    end
    if flora.state then
        flora.state:draw()
    end
    love.graphics.setCanvas(flora._canvas)
    
    for i = 1, flora.cameras.list.length do
        local cam = flora.cameras.list.members[i]
        if cam and cam.exists and cam.visible then
            cam:draw()
        end
    end
    if flora.plugins.drawAbove then
        flora.plugins:draw()
    end

    love.graphics.setCanvas()
    love.graphics.draw(
        flora._canvas,
        flora.scaleMode.offset.x, flora.scaleMode.offset.y, 0,
        flora.scaleMode.scale.x, flora.scaleMode.scale.y
    )
    if not flora.mouse.useSystemCursor and flora.mouse.visible then
        flora.mouse:draw()
    end

    if flora.postDraw then
        flora.postDraw()
    end
    flora.signals.postDraw:emit()
end

---
--- @protected
---
function love.resize(width, height)
    flora.scaleMode:onMeasure(width, height)
end

function love.keypressed(key, scancode, isrepeat)
    flora.keys:keyPressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
    flora.keys:keyReleased(key, scancode, isrepeat)
end

function love.mousemoved(x, y, _, _, _)
    if love.window.hasFocus() then
        flora.mouse:onMoved(x, y)
    end
end

function love.mousepressed(_, _, button, _, _)
    if love.window.hasFocus() then
        flora.mouse:onPressed(button)
    end
end

function love.mouserelEased(_, _, button, _, _)
    if love.window.hasFocus() then
        flora.mouse:onReleased(button)
    end
end

function love.quit()
    lily.quit()
end

return flora