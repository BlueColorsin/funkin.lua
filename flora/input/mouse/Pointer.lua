--- 
--- A simple graphical mouse pointer.
--- 
--- @class flora.input.mouse.Pointer
--- 
local Pointer = Class:extend("Pointer", ...)

function Pointer:constructor()
    ---
    --- The texture used to draw this mouse pointer to the screen.
    ---
    --- @type flora.assets.Texture?
    ---
    self.texture = nil

    ---
    --- Whether or not the mouse pointer is visible.
    ---
    self.visible = true

    ---
    --- Whether or not to use the system mouse cursor
    --- instead of Flora's software cursor.
    ---
    self.useSystemCursor = false

    ---
    --- The mouse pointer's X position. (in pixels, world space)
    ---
    self.x = 0.0

    ---
    --- The mouse pointer's Y position. (in pixels, world space)
    ---
    self.y = 0.0

    ---
    --- The mouse pointer's X position. (in pixels, screen space)
    ---
    self.screenX = 0.0

    ---
    --- The mouse pointer's Y position. (in pixels, screen space)
    ---
    self.screenY = 0.0

    ---
    --- The X amount that the cursor has moved since last frame. (in pixels, world space)
    ---
    self.deltaX = 0.0

    ---
    --- The Y amount that the cursor has moved since last frame. (in pixels, world space)
    ---
    self.deltaY = 0.0

    ---
    --- The X amount that the cursor has moved since last frame. (in pixels, screen space)
    ---
    self.deltaScreenX = 0.0

    ---
    --- The Y amount that the cursor has moved since last frame. (in pixels, screen space)
    ---
    self.deltaScreenY = 0.0

    ---
    --- Whether or not the left mouse button has just been pressed.
    ---
    self.justPressed = false

    ---
    --- Whether or not the middle mouse button has just been pressed.
    ---
    self.justPressedMiddle = false

    ---
    --- Whether or not the right mouse button has just been pressed.
    ---
    self.justPressedRight = false

    ---
    --- Whether or not the left mouse button is pressed.
    ---
    self.pressed = false

    ---
    --- Whether or not the middle mouse button is pressed.
    ---
    self.pressedMiddle = false

    ---
    --- Whether or not the right mouse button is pressed.
    ---
    self.pressedRight = false

    ---
    --- Whether or not the left mouse button is released.
    ---
    self.released = true

    ---
    --- Whether or not the middle mouse button is released.
    ---
    self.releasedMiddle = true

    ---
    --- Whether or not the right mouse button is released.
    ---
    self.releasedRight = true

    ---
    --- Whether or not the left mouse button has just been released.
    ---
    self.justReleased = false

    ---
    --- Whether or not the middle mouse button has just been released.
    ---
    self.justReleasedMiddle = false

    ---
    --- Whether or not the right mouse button has just been released.
    ---
    self.justReleasedRight = false

    ---
    --- Whether or not antialiasing is enabled on the cursor.
    ---
    self.antialiasing = false

    ---
    --- The X and Y scale factor of this sprite.
    ---
    --- @type flora.math.Vector2
    ---
    self.scale = Vector2:new(1, 1)

    ---
    --- @protected
    --- @type flora.math.Vector2
    ---
    self._vec = Vector2:new()

    ---
    --- @protected
    --- @type flora.assets.Texture
    ---
    self._texture = nil

    ---
    --- Loads default cursor
    ---
    self:load("flora/embed/images/cursor.png")
end

function Pointer:load(texture)
    self.texture = Flora.assets:loadTexture(texture)
end

function Pointer:update()
    local prevX = self.x
    local prevY = self.y

    local pos = self:getWorldPosition(nil, self._vec)
    self.x = pos.x
    self.y = pos.y

    self.deltaX = self.x - prevX
    self.deltaY = self.y - prevY
end

function Pointer:postUpdate()
    self.deltaX = 0.0
    self.deltaY = 0.0

    self.deltaScreenX = 0.0
    self.deltaScreenY = 0.0

    self.justPressed = false
    self.justPressedMiddle = false
    self.justPressedRight = false

    self.justReleased = false
    self.justReleasedMiddle = false
    self.justReleasedRight = false

    love.mouse.setVisible(self.useSystemCursor and self.visible)
end

function Pointer:draw()
    if not self.texture then
        return
    end
    local filter = self.antialiasing and "linear" or "nearest"
    self.texture.image:setFilter(filter, filter)

    love.graphics.draw(self.texture.image, self.screenX, self.screenY, 0, self.scale.x, self.scale.y)
end

function Pointer:onMoved(screenX, screenY)
    local prevScreenX = self.screenX
    local prevScreenY = self.screenY
    
    self.screenX = screenX
    self.screenY = screenY

    self.deltaScreenX = self.screenX - prevScreenX
    self.deltaScreenY = self.screenY - prevScreenY
end

function Pointer:onPressed(button)
    if button == 1 then
        self.justPressed = true
        self.pressed = true
        self.released = false
        
    elseif button == 2 then
        self.justPressedRight = true
        self.pressedRight = true
        self.releasedRight = false
        
    elseif button == 3 then
        self.justPressedMiddle = true
        self.pressedMiddle = true
        self.releasedMiddle = false
    end
end

function Pointer:onReleased(button)
    if button == 1 then
        self.justReleased = true
        self.pressed = false
        self.released = true
        
    elseif button == 2 then
        self.justReleasedRight = true
        self.pressedRight = false
        self.releasedRight = true
        
    elseif button == 3 then
        self.justReleasedMiddle = true
        self.pressedMiddle = false
        self.releasedMiddle = true
    end
end

---
--- @param  cam  flora.display.Camera
--- @param  vec  flora.math.Vector2
--- 
--- @return flora.math.Vector2
---
function Pointer:getWorldPosition(cam, vec)
    if not cam then
        cam = Flora.camera
    end
    if not vec then
        vec = Vector2:new()
    end
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    local gw = Flora.gameWidth
    local gh = Flora.gameHeight

    local scale = math.min(ww / gw, wh / gh) * cam.zoom
    return vec:set(
        ((self.screenX - (ww - scale * gw) * 0.5) / scale) + cam.scroll.x,
        ((self.screenY - (wh - scale * gh) * 0.5) / scale) + cam.scroll.y
    )
end

function Pointer:overlaps(obj, cam)
    if not cam then
        cam = Flora.camera
    end
    return (
        obj.visible and
        self.x >= obj.x and self.x <= obj.x + obj.width and
        self.y >= obj.y and self.y <= obj.y + obj.height
    )
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Pointer:get_texture()
    return self._texture
end

---
--- @protected
---
function Pointer:set_texture(val)
    if self._texture then
        self._texture:unreference()
    end
    if val then
        val:reference()
    end
    self._texture = val
    return self._texture
end

return Pointer