local SpriteUtil = require("flora.utils.SpriteUtil")

---
--- The default swipe transition used through out the menus.
--- This transition is found in many other engines, including base game!
---
--- @class funkin.objects.ui.transition.SwipeTransition : funkin.objects.ui.transition.BaseTransition
---
local SwipeTransition = BaseTransition:extend("SwipeTransition", ...)

function SwipeTransition:startIn()
    local canContinue = InstantTransition.super.startIn(self)
    if canContinue then
        local duration = 0.6

        ---
        --- @type flora.display.Sprite
        ---
        self.blackSpr = Sprite:new(0, -(Flora.gameHeight * 2))
        self.blackSpr:makeSolid(Flora.gameWidth, Flora.gameHeight, Color.BLACK)
        self.blackSpr:screenCenter(Axes.X)
        self:add(self.blackSpr)

        ---
        --- @type flora.display.Sprite
        ---
        self.gradientSpr = Sprite:new(0, -Flora.gameHeight)
        self.gradientSpr:loadTexture(SpriteUtil.makeGradient(false, Color.BLACK, Color.TRANSPARENT, Flora.gameWidth, Flora.gameHeight))
        self.gradientSpr:screenCenter(Axes.X)
        self:add(self.gradientSpr)

        ---
        --- @type flora.tweens.Tween
        ---
        local t = Tween:new()
        t:tweenProperty(self.blackSpr, "y", 0, duration, Ease.sineOut)
        t:tweenProperty(self.gradientSpr, "y", Flora.gameHeight, duration, Ease.sineOut)
        t:start()

        Timer:new():start(duration + 0.05, function(_)
            self:finish()
        end)
        return true
    end
    return false
end

function SwipeTransition:startOut()
    local canContinue = InstantTransition.super.startOut(self)
    if canContinue then
        local duration = 0.6

        ---
        --- @type flora.display.Sprite
        ---
        self.blackSpr = Sprite:new(0, 0)
        self.blackSpr:makeSolid(Flora.gameWidth, Flora.gameHeight, Color.BLACK)
        self.blackSpr:screenCenter(Axes.X)
        self:add(self.blackSpr)

        ---
        --- @type flora.display.Sprite
        ---
        self.gradientSpr = Sprite:new(0, -Flora.gameHeight)
        self.gradientSpr:loadTexture(SpriteUtil.makeGradient(false, Color.TRANSPARENT, Color.BLACK, 1, Flora.gameHeight))
        self.gradientSpr.scale.x = Flora.gameWidth
        self.gradientSpr:screenCenter(Axes.X)
        self:add(self.gradientSpr)

        ---
        --- @type flora.tweens.Tween
        ---
        local t = Tween:new()
        t:tweenProperty(self.blackSpr, "y", Flora.gameHeight * 2, duration, Ease.sineOut)
        t:tweenProperty(self.gradientSpr, "y", Flora.gameHeight, duration, Ease.sineOut)
        t:start()

        Timer:new():start(duration + 0.05, function(_)
            self:finish()
        end)
        return true
    end
    return false
end

return SwipeTransition