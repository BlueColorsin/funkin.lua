---
--- @type funkin.assets.paths
---
local paths = flora.import("funkin.assets.paths")

---
--- @class funkin.preloader : funkin.states.music_beat_state
---
local preloader = music_beat_state:extend()
preloader.tips = {
    "Press 7 in the main menu to access some useful editors!",
    "Press SHIFT while a transition is on-screen to skip it!",
    "Press F5 to instantly reload the current state!"
}

function preloader:ready()
    preloader.super.ready(self)

    self._type = "preloader"

    if not flora.save.data.volume then
        flora.sound.volume = 0.3

        flora.save.data.volume = flora.sound.volume
        flora.save:flush()
    end

    self.chosen_tip = preloader.tips[love.math.random(1, #preloader.tips)]
    self.test = 0.0

    ---
    --- @type flora.display.sprite
    ---
    self.preloader_art = sprite:new()
    self.preloader_art:load_texture("assets/images/preloaderArt.png")
    self.preloader_art.scale:set(0.3, 0.3)
    self.preloader_art:screen_center(axes.xy)
    self.preloader_art.y = self.preloader_art.y - 30
    self:add(self.preloader_art)

    ---
    --- @type flora.display.sprite
    ---
    self.spinner = sprite:new()
    self.spinner:load_texture("assets/images/spinner.png")
    self.spinner:set_graphic_size(48, 48)
    self.spinner:set_position(
        flora.game_width - self.spinner.width - 30,
        flora.game_height - self.spinner.height - 30
    )
    self:add(self.spinner)

    ---
    --- @type flora.display.text
    ---
    self.status_txt = text:new()
    self.status_txt.text = self.chosen_tip .. "\nPreloading assets..."
    self.status_txt:set_format("assets/fonts/vcr.ttf", 18, color.white, "left")
    self.status_txt:set_border_style("outline", color.black, 3)
    self.status_txt:set_position(30, flora.game_height - self.status_txt.height - 30)
    self:add(self.status_txt)

    self.preloaded_assets = 0
    self.asset_count = 0

    self.finished = false

    timer:new():start(0.5, function(_)
        self:do_preload()
    end)
end

function preloader:preload_texture(path, compressed)
    flora.assets:load_texture_async(path, compressed, function(tex)
        tex:reference()
        self.status_txt.text = self.chosen_tip .. "\nPreloaded " .. path .. " successfully"
        self.preloaded_assets = self.preloaded_assets + 1
    end)
    self.asset_count = self.asset_count + 1
end

function preloader:preload_sound(path)
    flora.assets:load_sound_async(path, function(_)
        self.status_txt.text = self.chosen_tip .. "\nPreloaded " .. path .. " successfully"
        self.preloaded_assets = self.preloaded_assets + 1
    end)
    self.asset_count = self.asset_count + 1
end

function preloader:do_preload()
    -- Preload menu bgs since they're commonly used
    self:preload_texture(paths.image("desat", "images/menus"))
    self:preload_texture(paths.image("yellow", "images/menus"))

    -- Preload commonly used characters
    self:preload_texture(paths.image("normal", "images/game/characters/bf"))
    self:preload_texture(paths.image("dead", "images/game/characters/bf"))

    self:preload_texture(paths.image("speakers", "images/game/characters/gf"))
    self:preload_texture(paths.image("woman", "images/game/characters/gf"))
end

function preloader:update(dt)
    preloader.super.update(self, dt)

    self.test = self.test + (dt * 10)
    self.spinner.angle = self.spinner.angle + (dt * 150)
    
    if self.asset_count > 0 and self.preloaded_assets == self.asset_count then
        self.finished = true
        self.asset_count = self.asset_count + 1
    end
    if self.finished then
        self.finished = false
        
        self.spinner:kill()
        self.status_txt.text = self.chosen_tip .. "\nFinished preloading, game on!"

        flora.sound:play(paths.sound("select", "sounds/menus"))
        flora.camera:fade(color.black, 1.25, false, function()
            timer:new():start(0.5, function(_)
                local title_screen = flora.import("funkin.states.title_screen")
                flora.switch_state(title_screen:new())
            end)
        end)
    end
end

return preloader