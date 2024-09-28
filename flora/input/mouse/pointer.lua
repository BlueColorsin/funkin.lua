--- 
--- A simple graphical mouse pointer.
--- 
--- @class flora.input.mouse.pointer
--- 
local pointer = class:extend("pointer", ...)

function pointer:constructor()
    ---
    --- The texture used to draw this mouse pointer to the screen.
    ---
    --- @type flora.assets.texture?
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
    self.use_system_cursor = false

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
    self.screen_x = 0.0

    ---
    --- The mouse pointer's Y position. (in pixels, screen space)
    ---
    self.screen_y = 0.0

    ---
    --- The X amount that the cursor has moved since last frame. (in pixels, world space)
    ---
    self.delta_x = 0.0

    ---
    --- The Y amount that the cursor has moved since last frame. (in pixels, world space)
    ---
    self.delta_y = 0.0

    ---
    --- The X amount that the cursor has moved since last frame. (in pixels, screen space)
    ---
    self.delta_screen_x = 0.0

    ---
    --- The Y amount that the cursor has moved since last frame. (in pixels, screen space)
    ---
    self.delta_screen_y = 0.0

    ---
    --- Whether or not the left mouse button has just been pressed.
    ---
    self.just_pressed = false

    ---
    --- Whether or not the middle mouse button has just been pressed.
    ---
    self.just_pressed_middle = false

    ---
    --- Whether or not the right mouse button has just been pressed.
    ---
    self.just_pressed_right = false

    ---
    --- Whether or not the left mouse button is pressed.
    ---
    self.pressed = false

    ---
    --- Whether or not the middle mouse button is pressed.
    ---
    self.pressed_middle = false

    ---
    --- Whether or not the right mouse button is pressed.
    ---
    self.pressed_right = false

    ---
    --- Whether or not the left mouse button is released.
    ---
    self.released = true

    ---
    --- Whether or not the middle mouse button is released.
    ---
    self.released_middle = true

    ---
    --- Whether or not the right mouse button is released.
    ---
    self.released_right = true

    ---
    --- Whether or not the left mouse button has just been released.
    ---
    self.just_released = false

    ---
    --- Whether or not the middle mouse button has just been released.
    ---
    self.just_released_middle = false

    ---
    --- Whether or not the right mouse button has just been released.
    ---
    self.just_released_right = false

    ---
    --- Whether or not antialiasing is enabled on the cursor.
    ---
    self.antialiasing = false

    ---
    --- The X and Y scale factor of this sprite.
    ---
    --- @type flora.math.vector2
    ---
    self.scale = vector2:new(1, 1)

    ---
    --- @protected
    --- @type flora.math.vector2
    ---
    self._vec = vector2:new()

    ---
    --- @protected
    --- @type flora.assets.texture
    ---
    self._texture = nil

    ---
    --- Loads default cursor
    ---
    self:load("flora/embed/images/cursor.png")
end

function pointer:load(texture)
    self.texture = flora.assets:load_texture(texture)
end

function pointer:update()
    local prevX = self.x
    local prevY = self.y

    local pos = self:get_world_position(nil, self._vec)
    self.x = pos.x
    self.y = pos.y

    self.delta_x = self.x - prevX
    self.delta_y = self.y - prevY
end

function pointer:post_update()
    self.delta_x = 0.0
    self.delta_y = 0.0

    self.delta_screen_x = 0.0
    self.delta_screen_y = 0.0

    self.just_pressed = false
    self.just_pressed_middle = false
    self.just_pressed_right = false

    self.just_released = false
    self.just_released_middle = false
    self.just_released_right = false

    love.mouse.setVisible(self.use_system_cursor and self.visible)
end

function pointer:draw()
    if not self.texture then
        return
    end
    local filter = self.antialiasing and "linear" or "nearest"
    self.texture.image:setFilter(filter, filter)

    love.graphics.draw(self.texture.image, self.screen_x, self.screen_y, 0, self.scale.x, self.scale.y)
end

function pointer:on_moved(screen_x, screen_y)
    local prev_screen_x = self.screen_x
    local prev_screen_y = self.screen_y
    
    self.screen_x = screen_x
    self.screen_y = screen_y

    self.delta_screen_x = self.screen_x - prev_screen_x
    self.delta_screen_y = self.screen_y - prev_screen_y
end

function pointer:on_pressed(button)
    if button == 1 then
        self.just_pressed = true
        self.pressed = true
        self.released = false
        
    elseif button == 2 then
        self.just_pressed_right = true
        self.pressed_right = true
        self.released_right = false
        
    elseif button == 3 then
        self.just_pressed_middle = true
        self.pressed_middle = true
        self.released_middle = false
    end
end

function pointer:on_released(button)
    if button == 1 then
        self.just_released = true
        self.pressed = false
        self.released = true
        
    elseif button == 2 then
        self.just_released_right = true
        self.pressed_right = false
        self.released_right = true
        
    elseif button == 3 then
        self.just_released_middle = true
        self.pressed_middle = false
        self.released_middle = true
    end
end

---
--- @param  cam  flora.display.camera
--- @param  vec  flora.math.vector2
--- 
--- @return flora.math.vector2
---
function pointer:get_world_position(cam, vec)
    if not cam then
        cam = flora.camera
    end
    if not vec then
        vec = vector2:new()
    end
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    local gw = flora.config.game_width
    local gh = flora.config.game_height

    local scale = math.min(ww / gw, wh / gh) * cam.zoom
    return vec:set(
        ((self.screen_x - (ww - scale * gw) * 0.5) / scale) + cam.scroll.x,
        ((self.screen_y - (wh - scale * gh) * 0.5) / scale) + cam.scroll.y
    )
end

function pointer:overlaps(obj, cam)
    if not cam then
        cam = flora.camera
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
function pointer:get_texture()
    return self._texture
end

---
--- @protected
---
function pointer:set_texture(val)
    if self._texture then
        self._texture:unreference()
    end
    if val then
        val:reference()
    end
    self._texture = val
    return self._texture
end

return pointer