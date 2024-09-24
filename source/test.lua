---
--- @class test : flora.display.screen
---
local test = screen:extend()

function test:ready()
    test.super.ready(self)
    
    flora.mouse:load("assets/images/cursor-default.png")
    flora.mouse.antialiasing = true
    
    flora.sound.volume = 0.3 -- all sounds get affected
    
    self.dragging_bip = false

    ---
    --- @type flora.display.sprite
    ---
    self.bip = sprite:new()
    self.bip:load_texture("assets/images/bip.png")
    self.bip:screen_center(axes.xy)
    self:add(self.bip)

    ---
    --- @type flora.display.text
    ---
    self.txt_test = text:new()
    self.txt_test.border_size = 2
    self.txt_test.text = "sample text"
    self.txt_test:screen_center(axes.xy)
    self:add(self.txt_test)

    local snd = flora.sound:play_music("assets/music/freakyMenu/music.ogg")
    snd.looping = true
end

function test:update(dt)
    test.super.update(self, dt)
    flora.camera.zoom = math.lerp(flora.camera.zoom, 1.0, dt * 3.0)

    if flora.keys.just_pressed.space then
        flora.camera.zoom = 1.5
        self.txt_test.text = "smth different " .. math.random(0, 2989838982)
        self.txt_test:screen_center(axes.x)
    end

    if flora.mouse:overlaps(self.bip) then
        if flora.mouse.just_pressed then
            self.bip.tint = color.blue
            dragging_bip = true
            flora.sound:play("assets/sounds/check.ogg")
        end
    end
    if dragging_bip then
        self.bip.x = self.bip.x + flora.mouse.delta_x
        self.bip.y = self.bip.y + flora.mouse.delta_y
    end
    if dragging_bip and flora.mouse.just_released then
        self.bip.tint = color.white
        dragging_bip = false
        flora.sound:play("assets/sounds/uncheck.ogg")
    end
end

return test