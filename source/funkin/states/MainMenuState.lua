---
--- @type funkin.objects.game.HealthIcon
---
local HealthIcon = Flora.import("funkin.objects.game.HealthIcon")

---
--- @type funkin.objects.ui.mainmenu.MainMenuList
---
local MainMenuList = Flora.import("funkin.objects.ui.mainmenu.MainMenuList")

---
--- @class funkin.states.MainMenuState : funkin.states.MusicBeatState
---
local MainMenuState = MusicBeatState:extend("MainMenuState", ...)

---
--- @type integer
---
MainMenuState.lastSelected = 1

function MainMenuState:ready()
    MainMenuState.super.ready(self)

    -- yes keep updating actually
    self.persistentUpdate = true

    if not Flora.sound.music.playing then
        Tools.playMusic(Paths.music("freakyMenu"))
    end

    Discord.changePresence({
        state = "In the Main Menu",
        details = "Selecting nothing"
    })

    ---
    --- @type flora.display.Sprite
    ---
    self.bg = Sprite:new():loadTexture(Paths.image("yellow", "images/menus"))
    self.bg.scale:set(1.2, 1.2)
    self.bg:screenCenter(Axes.XY)
    self.bg.scrollFactor:set(0, 0.17)
    self:add(self.bg)

    ---
    --- @type flora.display.Sprite
    ---
    self.magenta = Sprite:new():loadTexture(Paths.image("desat", "images/menus"))
    self.magenta.scale:set(1.2, 1.2)
    self.magenta:screenCenter(Axes.XY)
    self.magenta.scrollFactor:set(0, 0.17)
    self.magenta.tint = Color:new(0xFFFD719B)
    self.magenta.visible = false
    self:add(self.magenta)

    ---
    --- @type flora.display.Object2D
    ---
    self.camFollow = Object2D:new(0, 0, 1, 1)
    self.camFollow:kill()
    self:add(self.camFollow)
    
    ---
    --- @type funkin.objects.ui.mainmenu.MainMenuList
    ---
    self.menuItems = MainMenuList:new()
    self.menuItems:addItem("storymode", "Story Mode", function()
        print("nah")
    end)
    self.menuItems:addItem("freeplay", "Freeplay", function()
        local FreeplayState = Flora.import("funkin.states.FreeplayState")
        self:startExitState(FreeplayState:new())
    end)
    self.menuItems:addItem("options", "Options", function()
        print("nah")
    end)
    self.menuItems:addItem("credits", "Credits", function()
        print("nah")
    end)
    self.menuItems.onChange:connect(function(item)
        self.camFollow:setPosition(item.x, item.y)
        Discord.changePresence({
            state = "In the Main Menu",
            details = "Selecting " .. item.rpcName
        })
    end)
    self.menuItems.onAcceptPress:connect(function(_)
        Flicker.flicker(self.magenta, 1.1, 0.15, false, true)
    end)
    self.menuItems:centerItems()
    self.menuItems:selectItem(MainMenuState.lastSelected)
    self:add(self.menuItems)

    ---
    --- @type flora.display.Text
    ---
    self.versionTxt = Text:new(5, Flora.gameHeight - 5, 0, "funkin.lua v0.1.0\nFriday Night Funkin' v0.5.0")
    self.versionTxt:setFormat(Paths.font("vcr"), 16)
    self.versionTxt:setBorderStyle("outline", Color.BLACK, 1)
    self.versionTxt.y = self.versionTxt.y - self.versionTxt.height
    self.versionTxt.scrollFactor:set()
    self:add(self.versionTxt)

    for i = 1, 10 do
        local balls = HealthIcon:new("gf", false)
        balls.x = i * 30
        balls.scrollFactor:set()
        self:add(balls)
    end
    Flora.camera:follow(self.camFollow, nil, 0.06)
end

function MainMenuState:startExitState(newState)
    self.menuItems.enabled = false

    local duration = 0.4
    for i = 1, self.menuItems.length do
        ---
        --- @type funkin.objects.ui.mainmenu.MainMenuButton
        ---
        local item = self.menuItems.members[i]
        if i ~= self.menuItems.selectedItem then
            local t = Tween:new()
            t:tweenProperty(item, "alpha", 0, duration, Ease.quadOut)
            t:start()
        else
            item.visible = false
        end
    end
    Timer:new():start(duration + 0.05, function(_)
        Flora.switchState(newState)
    end)
end

function MainMenuState:update(dt)
    MainMenuState.super.update(self, dt)

    if Flora.sound.music.volume < 1 then
        Flora.sound.music.volume = Flora.sound.music.volume + (dt * 0.5)
    end

    if Controls.justPressed.BACK then
        Flora.sound:play(Paths.sound("cancel", "sounds/menus"))
        
        local TitleState = Flora.import("funkin.states.TitleState")
        Flora.switchState(TitleState:new())
    end
end

function MainMenuState:dispose()
    MainMenuState.super.dispose(self)
    MainMenuState.lastSelected = self.menuItems.selectedItem
end

return MainMenuState