---
--- @type funkin.assets.Paths
---
local Paths = flora.import("funkin.assets.Paths")

---
--- @class funkin.Preloader : funkin.states.MusicBeatState
---
local Preloader = MusicBeatState:extend("Preloader", ...)
Preloader.tips = {
    "Press 7 in the main menu to access some useful editors!",
    "Press SHIFT while a transition is on-screen to skip it!",
    "Press F5 to instantly reload the current state!"
}

function Preloader:ready()
    Preloader.super.ready(self)

    if not flora.save.data.volume then
        flora.sound.volume = 0.3

        flora.save.data.volume = flora.sound.volume
        flora.save:flush()
    end

    self.chosenTip = Preloader.tips[love.math.random(1, #Preloader.tips)]
    self.test = 0.0

    ---
    --- @type flora.display.Sprite
    ---
    self.preloaderArt = Sprite:new()
    self.preloaderArt:loadTexture("assets/images/preloaderArt.png")
    self.preloaderArt.scale:set(0.3, 0.3)
    self.preloaderArt:screenCenter(Axes.XY)
    self.preloaderArt.y = self.preloaderArt.y - 30
    self:add(self.preloaderArt)

    ---
    --- @type flora.display.Sprite
    ---
    self.spinner = Sprite:new()
    self.spinner:loadTexture("assets/images/spinner.png")
    self.spinner:setGraphicSize(48, 48)
    self.spinner:setPosition(
        flora.gameWidth - self.spinner.width - 30,
        flora.gameHeight - self.spinner.height - 30
    )
    self:add(self.spinner)

    ---
    --- @type flora.display.Text
    ---
    self.statusTxt = Text:new()
    self.statusTxt.text = self.chosenTip .. "\nPreloading assets..."
    self.statusTxt:setFormat("assets/fonts/vcr.ttf", 18, Color.WHITE, "left")
    self.statusTxt:setBorderStyle("outline", Color.BLACK, 3)
    self.statusTxt:setPosition(30, flora.gameHeight - self.statusTxt.height - 30)
    self:add(self.statusTxt)

    self.preloadedAssets = 0
    self.assetCount = 0

    self.finished = false

    Timer:new():start(0.5, function(_)
        self:doPreload()
    end)
end

function Preloader:preloadTexture(path, compressed)
    flora.assets:loadTextureASync(path, compressed, function(tex)
        tex:reference()
        self.statusTxt.text = self.chosenTip .. "\nPreloaded " .. path .. " successfully"
        self.preloadedAssets = self.preloadedAssets + 1
    end)
    self.assetCount = self.assetCount + 1
end

function Preloader:preloadSound(path)
    flora.assets:loadSoundASync(path, function(_)
        self.statusTxt.text = self.chosenTip .. "\nPreloaded " .. path .. " successfully"
        self.preloadedAssets = self.preloadedAssets + 1
    end)
    self.assetCount = self.assetCount + 1
end

function Preloader:doPreload()
    -- Preload menu bgs since they're commonly used
    self:preloadTexture(Paths.image("desat", "images/menus"))
    self:preloadTexture(Paths.image("yellow", "images/menus"))

    -- Preload commonly used characters
    self:preloadTexture(Paths.image("normal", "images/game/characters/bf"))
    self:preloadTexture(Paths.image("dead", "images/game/characters/bf"))

    self:preloadTexture(Paths.image("speakers", "images/game/characters/gf"))
    self:preloadTexture(Paths.image("woman", "images/game/characters/gf"))
end

function Preloader:update(dt)
    Preloader.super.update(self, dt)

    self.test = self.test + (dt * 10)
    self.spinner.angle = self.spinner.angle + (dt * 150)
    
    if self.assetCount > 0 and self.preloadedAssets == self.assetCount then
        self.finished = true
        self.assetCount = self.assetCount + 1
    end
    if self.finished then
        self.finished = false
        
        self.spinner:kill()
        self.statusTxt.text = self.chosenTip .. "\nFinished preloading, game on!"

        flora.sound:play(Paths.sound("select", "sounds/menus"))
        flora.camera:fade(Color.BLACK, 1.25, false, function()
            -- flora.camera._fade_fx_alpha = 0.0
            Timer:new():start(0.5, function(_)
                local TitleScreen = flora.import("funkin.states.TitleScreen")
                flora.switchState(TitleScreen:new())
            end)
        end)
    end
end

return Preloader