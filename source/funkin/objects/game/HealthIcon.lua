---
--- @type funkin.objects.ui.sprite.TrackingSprite
---
local TrackingSprite = Flora.import("funkin.objects.ui.sprite.TrackingSprite")

---
--- @type funkin.data.characters.CharacterData
---
local CharacterData = Flora.import("funkin.data.characters.CharacterData")

---
--- @type funkin.data.characters.HealthIconData
---
local HealthIconData = Flora.import("funkin.data.characters.HealthIconData")

---
--- @class funkin.objects.game.HealthIcon : funkin.objects.ui.sprite.TrackingSprite
---
local HealthIcon = TrackingSprite:extend("HealthIcon", ...)

HealthIcon.WINNING_THRESHOLD = 0.8
HealthIcon.LOSING_THRESHOLD = 0.2
HealthIcon.ICON_SPEED = 0.25

HealthIcon.HEALTH_ICON_SIZE = 150
HealthIcon.PIXEL_ICON_SIZE = 32

HealthIcon.BUMP_AMOUNT = 0.2

---
--- @param  character  string
--- @param  isPlayer   boolean?
---
function HealthIcon:constructor(character, isPlayer)
    HealthIcon.super.constructor(self)

    isPlayer = isPlayer or false

    ---
    --- The ID of the character that this icon represents.
    --- 
    --- @type string
    ---
    self.characterID = nil

    ---
    --- Whether this health icon should bop to the beat.
    ---
    --- @type boolean
    ---
    self.canBop = false

    ---
    --- Whether this health icon represents the player.
    ---
    --- @type boolean
    ---
    self.isPlayer = isPlayer

    ---
    --- Whether this health icon is in legacy style.
    ---
    --- @type boolean
    ---
    self.isLegacyStyle = false

    ---
    --- Whether this health icon is in pixel style.
    ---
    --- @type boolean
    ---
    self.isPixel = false

    ---
    --- The initial X and Y scale of this health icon.
    --- 
    --- @type flora.math.Vector2
    ---
    self.size = Vector2:new(1, 1)

    ---
    --- The current health of this icon.
    --- 
    --- @type number
    ---
    self.health = 0.5

    ---
    --- @protected
    --- @type string
    ---
    self._characterID = nil

    self.__initializing = false
    self:set_characterID(character or "face")
end

---
--- @param  name      string
--- @param  fallback  string?
--- @param  restart   boolean?
---
function HealthIcon:playIconAnim(name, fallback, restart)
    restart = restart or false
    if self.animation:exists(name) then
        self.animation:play(name, restart, false, 1)
        return
    end
    if fallback and self.animation:exists(fallback) then
        self.animation:play(fallback, restart, false, 1)
    end
end

function HealthIcon:update(dt)
    self:_updateHealth(self.health)
    if self.canBop then
        if self.width > self.height then
            self:setGraphicSize(math.lerp(self.width, HealthIcon.HEALTH_ICON_SIZE * self.size.x, dt * 60 * HealthIcon.ICON_SPEED), 0)
        else
            self:setGraphicSize(0, math.lerp(self.height, HealthIcon.HEALTH_ICON_SIZE * self.size.y, dt * 60 * HealthIcon.ICON_SPEED))
        end
    end
    HealthIcon.super.update(self, dt)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
--- @param  characterID  string
---
function HealthIcon:_isNewSpritesheet(characterID)
    -- TODO: support mods
    return File.exists(Paths.xml(characterID, "images/game/icons"))
end

---
--- @protected
--- @param  characterID  string
---
function HealthIcon:_correctCharacterID(characterID)
    -- TODO: support mods
    if not characterID then
        characterID = Constants.DEFAULT_HEALTH_ICON
    end
    if characterID:contains("-") and not File.exists(Paths.image(characterID, "images/game/icons")) then
        characterID = characterID:sub(1, characterID:indexOf("-"))
    end
    if not File.exists(Paths.image(characterID, "images/game/icons")) then
        Flora.log:warn("Health icon for " .. characterID " doesn't exist!")
        return Constants.DEFAULT_HEALTH_ICON
    end
    return characterID
end

---
--- @protected
---
function HealthIcon:_loadAnimationNew()
    self.animation:addByPrefix("idle", "idle", 24, true)
    self.animation:addByPrefix("winning", "winning", 24, true)
    self.animation:addByPrefix("losing", "losing", 24, true)

    self.animation:addByPrefix("toWinning", "toWinning", 24, true)
    self.animation:addByPrefix("toLosing", "toLosing", 24, true)

    self.animation:addByPrefix("fromWinning", "fromWinning", 24, true)
    self.animation:addByPrefix("fromLosing", "fromLosing", 24, true)
end

---
--- @protected
---
function HealthIcon:_loadAnimationOld()
    self.animation:add("idle", {1}, 0, false)
    self.animation:add("losing", {2}, 0, false)
    if self.animation.numFrames >= 3 then
        self.animation:add("winning", {3}, 0, false)
    end
end

---
--- @protected
---
function HealthIcon:_updateHealth(health)
    local animName = self.animation.name
    if animName == "idle" then
        if health < HealthIcon.LOSING_THRESHOLD then
            self:playIconAnim("toLosing", "losing")
        
        elseif health > HealthIcon.WINNING_THRESHOLD then
            self:playIconAnim("toWinning", "winning")

        else
            self:playIconAnim("idle")
        end
    
    elseif animName == "winning" then
        if health < HealthIcon.WINNING_THRESHOLD then
            self:playIconAnim("fromWinning", "idle")
        else
            self:playIconAnim("winning", "idle")
        end
    
    elseif animName == "losing" then
        if health > HealthIcon.LOSING_THRESHOLD then
            self:playIconAnim("fromLosing", "idle")
        else
            self:playIconAnim("losing", "idle")
        end
    
    elseif animName == "toLosing" then
        if self.animation.finished then
            self:playIconAnim("losing", "idle")
        end
    
    elseif animName == "toWinning" then
        if self.animation.finished then
            self:playIconAnim("winning", "idle")
        end
    
    elseif animName == "fromLosing" or animName == "fromWinning" then
        if self.animation.finished then
            self:playIconAnim("idle")
        end
    else
        self:playIconAnim("idle")
    end
end

---
--- @protected
--- @param  characterID  string
---
function HealthIcon:_loadCharacter(characterID)
    characterID = self:_correctCharacterID(characterID)
    local charData = CharacterData.load(characterID)

    isPixel = (charData and charData.healthIcon) and charData.healthIcon.isPixel or false
    isLegacyStyle = not self:_isNewSpritesheet(characterID)

    if not isLegacyStyle then
        self.frames = Paths.getSparrowAtlas(characterID, "images/game/icons")
        self:_loadAnimationNew()
    else
        local size = isPixel and HealthIcon.PIXEL_ICON_SIZE or HealthIcon.HEALTH_ICON_SIZE
        self:loadTexture(Paths.image(characterID, "images/game/icons"), true, size, size)
        self:_loadAnimationOld()
    end
    self.antialiasing = not isPixel

    local leScale = (charData and charData.healthIcon) and charData.healthIcon.scale or 1.0
    self.size:set(leScale, leScale)
    self:setGraphicSize(HealthIcon.HEALTH_ICON_SIZE * self.size.x, HealthIcon.HEALTH_ICON_SIZE * self.size.y)

    self.flipX = (charData and charData.healthIcon and charData.healthIcon.flip) and charData.healthIcon.flip.x or false
    self.flipY = (charData and charData.healthIcon and charData.healthIcon.flip) and charData.healthIcon.flip.y or false

    self.frameOffset:set(
        (charData and charData.healthIcon and charData.healthIcon.offset) and charData.healthIcon.offset.x or 0.0,
        (charData and charData.healthIcon and charData.healthIcon.offset) and charData.healthIcon.offset.y or 0.0
    )
end

---
--- @protected
--- @param  val  string
---
function HealthIcon:set_characterID(val)
    if self._characterID ~= val then
        self._characterID = val
        self:_loadCharacter(self._characterID)
    end
    return self._characterID
end

return HealthIcon