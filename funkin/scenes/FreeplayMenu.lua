--[[
    Copyright 2024 swordcube

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

---@diagnostic disable: invisible

local _disabled_, _inherit_ = "disabled", "inherit"
local thread = love.thread

local SongMetadata = require("funkin.backend.song.SongMetadata") --- @type funkin.backend.song.SongMetadata
local HealthIcon = require("funkin.ui.HealthIcon") --- @type funkin.ui.HealthIcon

---
--- @class funkin.scenes.FreeplayMenu : chip.core.Scene
---
local FreeplayMenu = Scene:extend("FreeplayMenu", ...)

function FreeplayMenu:init()
    self.songList = {} --- @type table<string>
    self.songMetas = {} --- @type table<string, table<string, funkin.backend.song.SongMetadata>>

    -- TODO: modding support for levelList
    local failedSongs = {} --- @type table<string, boolean>
    local levelList = Json.parse(File.read(Paths.json("levelList")))

    for i = 1, #levelList.levels do
        -- go through each level
        local levelID = levelList.levels[i] --- @type string
        if not File.exists(Paths.json(levelID, "data/levels")) then
            -- if it doesn't exist, skip
            goto levelContinue
        end
        local levelData = Json.parse(File.read(Paths.json(levelID, "data/levels")))
        for j = 1, #levelData.songs do
            -- go through each song in this level
            local songID = levelData.songs[j] --- @type string

            local songMeta = SongMetadata.get(songID) --- @type funkin.backend.song.SongMetadata?
            if not songMeta then
                -- if it doesn't exist, skip
                table.insert(failedSongs, songID)
                goto songContinue
            end
            songMeta._parsedColor = Color:new(songMeta.color)
            
            local data = {
                default = songMeta
            }
            Log.info({text = "[FREEPLAY] ", fgColor = Native.ConsoleColor.CYAN}, nil, nil, "Metadata found for " .. songID)

            for k = 1, #songMeta.variants do
                -- go through each variant
                local variant = songMeta.variants[k] --- @type string
                local variantMeta = SongMetadata.get(songID .. "-" .. variant) --- @type funkin.backend.song.SongMetadata?
                
                if variantMeta then
                    variantMeta._parsedColor = Color:new(variantMeta.color)

                    -- if it exists, add it
                    data[variant] = variantMeta
                    Log.info({text = "[FREEPLAY] ", fgColor = Native.ConsoleColor.CYAN}, nil, nil, "Metadata found for " .. songID .. " [" .. variant .. "]")
                end
            end
            table.insert(songMeta.variants, "default")
            self.songMetas[songID] = data

            table.insert(self.songList, songID)
            ::songContinue::
        end
        ::levelContinue::
    end
    if #failedSongs ~= 0 then
        print("============================================================")
        Log.info({text = "[FREEPLAY] ", fgColor = Native.ConsoleColor.CYAN}, nil, nil, "Non-existent songs: " .. table.join(failedSongs, ", "))
    end
    self.curSelected = 1
    self.curDifficulty = "normal"
    self.curVariant = "default"

    self.lerpSelected = 1
    self.lerpScore = 0.0

    ---
    --- @protected
    ---
    self._lastVisibles = {} --- @type table<integer>

    ---
    --- @protected
    ---
    self._loadedSongInsts = {} --- @type table<string, chip.audio.AudioStream>

    ---
    --- @protected
    ---
    self._loadedSongList = {} --- @type table<string>

    ---
    --- @protected
    ---
    self._playingSong = nil --- @type string

    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:loadTexture(Paths.image("desat", "images/menus"))
    self.bg:screenCenter("xy")
    self:add(self.bg)

    self.grpSongs = Group:new() --- @type chip.core.Group
    self:add(self.grpSongs)

    self.grpIcons = Group:new() --- @type chip.core.Group
    self:add(self.grpIcons)

    for i = 1, #self.songList do
        local songID = self.songList[i] --- @type string
        local songMetas = self.songMetas[songID] --- @type table<string, funkin.backend.song.SongMetadata>

        local text = AtlasText:new(0, 30 + (70 * i), "bold", "left", songMetas.default.title) --- @type funkin.ui.AtlasText
        text.targetY = i - 1
        self.grpSongs:add(text)

        local icon = HealthIcon:new(songMetas.default.icon or Constants.DEFAULT_HEALTH_ICON, false) --- @type funkin.ui.HealthIcon
        icon.tracked = text
        self.grpIcons:add(icon)
    end
    self.scoreBG = Sprite:new((Engine.gameWidth * 0.7) - 6, 0) --- @type chip.graphics.Sprite
    self.scoreBG:makeTexture(1, 66, Color.BLACK)
    self.scoreBG:setAlpha(0.6)
    self.scoreBG:setAntialiasing(false)
    self:add(self.scoreBG)

    self.scoreText = Text:new(self.scoreBG:getX() + 6, 5, 0, "PERSONAL BEST:0", 32) --- @type chip.graphics.Text
    self.scoreText:setAlignment("right")
    self.scoreText:setFont(Paths.font("vcr.ttf"))
    self:add(self.scoreText)

    self.diffText = Text:new(self.scoreText:getX(), self.scoreText:getY() + 36, 0, self.curDifficulty:upper(), 24) --- @type chip.graphics.Text
    self.diffText:setAlignment("center")
    self.diffText:setFont(Paths.font("vcr.ttf"))
    self:add(self.diffText)

    ---
    --- @protected
    ---
    self._instThread = thread.newThread([[
        local Json = require("chip.src.libs.Json")

        local audio = require("love.audio")
        local sound = require("love.sound")

        local timer = require("love.timer")
        local thread = require("love.thread")

        while true do
            local info = thread.getChannel("fi1"):pop()
            if info then
                if info.doBreak then
                    break
                end
                -- i love how this just works lmao
                local source = audio.newSource(info.instPath, "static")
                thread.getChannel("fi2"):push({
                    song = info.song,
                    source = source
                })
            end
            timer.sleep(0.01)
        end
    ]])
    self._instThread:start()

    self:changeSelection(0, true)
end

function FreeplayMenu:changeSelection(by, force)
    if by == 0 and not force then
        return
    end
    local songCount = #self.songList
    self.curSelected = math.wrap(self.curSelected + by, 1, songCount)

    for i = 1, songCount do
        local text = self.grpSongs:getMembers()[i] --- @type funkin.ui.AtlasText
        text.targetY = i - self.curSelected
        text:setAlpha((i == self.curSelected) and 1 or 0.6)
    end
    self:changeDifficulty(0, true)
    AudioPlayer.playSFX(Paths.sound("scroll", "sounds/menus"))
end

function FreeplayMenu:changeDifficulty(by, force)
    if by == 0 and not force then
        return
    end
    local songMetas = self.songMetas[self.songList[self.curSelected]] --- @type table<string, funkin.backend.song.SongMetadata>
    if not songMetas[self.curVariant] then
        self.curVariant = "default"
    end
    local difficulties = songMetas[self.curVariant].difficulties --- @type table<string>
    
    local prevDifficultyIndex = table.indexOf(difficulties, self.curDifficulty)
    local curDifficultyIndex = prevDifficultyIndex + by
    
    local prevVariantIndex = table.indexOf(songMetas.default.variants, self.curVariant)
    self.curDifficulty = difficulties[curDifficultyIndex]
    
    if curDifficultyIndex < 1 then
        local curVariantIndex = math.wrap(prevVariantIndex + by, 1, #songMetas.default.variants)
        self.curVariant = songMetas.default.variants[curVariantIndex]
        
        difficulties = songMetas[self.curVariant].difficulties
        curDifficultyIndex = #difficulties

        self.curDifficulty = difficulties[curDifficultyIndex]
        
    elseif curDifficultyIndex > #difficulties then
        curDifficultyIndex = 1

        local curVariantIndex = math.wrap(prevVariantIndex + by, 1, #songMetas.default.variants)
        self.curVariant = songMetas.default.variants[curVariantIndex]
        
        difficulties = songMetas[self.curVariant].difficulties
        self.curDifficulty = difficulties[curDifficultyIndex]
    end
    if #difficulties > 1 then
        self.diffText:setContents("< " .. self.curDifficulty:upper() .. " >")
    else
        self.diffText:setContents(self.curDifficulty:upper())
    end
    local song = self.songList[self.curSelected] .. (self.curVariant:lower() ~= "default" and ("-" .. self.curVariant:lower()) or "")
    local stream = self._loadedSongInsts[song]
    if not stream and not table.contains(self._loadedSongList, song) then
        thread.getChannel("fi1"):push({
            song = song,
            instPath = Paths.inst(song),
            doBreak = false
        })
        table.insert(self._loadedSongList, song)
    end
    self:positionHighscore()
end

function FreeplayMenu:update(dt)
    local songCount = #self.songList

    local lerpRatio = dt * 9.6
    self.lerpSelected = math.lerp(self.lerpSelected, self.curSelected, lerpRatio)
    
    for i = 1, #self._lastVisibles do
        local j = self._lastVisibles[i]

        local text = self.grpSongs:getMembers()[j] --- @type funkin.ui.AtlasText
        text:setUpdateMode(_disabled_)
        text:setVisibility(false)

        local icon = self.grpIcons:getMembers()[j] --- @type funkin.ui.HealthIcon
        icon:setUpdateMode(_disabled_)
        icon:setVisibility(false)
    end
    self._lastVisibles = {}

    local min = math.round(math.max(1, math.min(songCount, self.lerpSelected - 4)))
	local max = math.round(math.max(1, math.min(songCount, self.lerpSelected + 4)))

    for i = min, max do
        local text = self.grpSongs:getMembers()[i] --- @type funkin.ui.AtlasText
        text:setUpdateMode(_inherit_)
        text:setVisibility(true)

        text:setX(math.lerp(text:getX(), (text.targetY * 20) + 90, lerpRatio))
        text:setY(math.lerp(text:getY(), (text.targetY * 156) + (Engine.gameHeight * 0.45), lerpRatio))

        local icon = self.grpIcons:getMembers()[i] --- @type funkin.ui.HealthIcon
        icon:setUpdateMode(_inherit_)
        icon:setVisibility(true)

        table.insert(self._lastVisibles, i)
    end
    local songMetas = self.songMetas[self.songList[self.curSelected]] --- @type table<string, funkin.backend.song.SongMetadata>
    
    local bgColor = self.bg:getTint() --- @type chip.utils.Color
    self.bg:setTint(bgColor:interpolate(songMetas[self.curVariant]._parsedColor, dt * 2.7))

    local scoreData = Highscore.getScoreData(self.songList[self.curSelected], self.curDifficulty) --- @type funkin.backend.data.HighscoreData
    self.lerpScore = math.lerp(self.lerpScore, scoreData.score, dt * 24.0)

    self.scoreText:setContents("PERSONAL BEST:" .. math.floor(self.lerpScore))
    self:positionHighscore()

    local info = thread.getChannel("fi2"):pop()
    if info then
        local stream = AudioStream:new() --- @type chip.audio.AudioStream
        stream:setData(info.source)
        stream:reference()
        self._loadedSongInsts[info.song] = stream
    end
    local song = self.songList[self.curSelected] .. (self.curVariant:lower() ~= "default" and ("-" .. self.curVariant:lower()) or "")
    local stream = self._loadedSongInsts[song]
    if stream and self._playingSong ~= song then
        BGM.play(stream, true)
        BGM.fade(0, 1, 2)
        self._playingSong = song
    end
    if Controls.justPressed.BACK then
        Engine.switchScene(require("funkin.scenes.MainMenu"):new())
    end
    local wheel = -Input:getMouseWheelY()
    if Controls.justPressed.UI_UP or wheel < 0 then
        self:changeSelection(-1)
    end
    if Controls.justPressed.UI_DOWN or wheel > 0 then
        self:changeSelection(1)
    end
    if Controls.justPressed.UI_LEFT then
        self:changeDifficulty(-1)
    end
    if Controls.justPressed.UI_RIGHT then
        self:changeDifficulty(1)
    end
    if Controls.justPressed.ACCEPT then
        Engine.switchScene(Gameplay:new({
            song = self.songList[self.curSelected] .. (self.curVariant ~= "default" and ("-" .. self.curVariant) or ""),
            difficulty = self.curDifficulty
        }))
    end
    FreeplayMenu.super.update(self, dt)
end

function FreeplayMenu:positionHighscore()
    self.scoreText:setX(Engine.gameWidth - self.scoreText:getWidth() - 6)
    self.scoreBG.scale.x = (Engine.gameWidth - self.scoreText:getX()) + 6
    
    self.scoreBG:setX(Engine.gameWidth - self.scoreBG.scale.x)
    self.diffText:setX(self.scoreBG:getX() + ((self.scoreBG:getWidth() - self.diffText:getWidth()) * 0.5))
end

function FreeplayMenu:free()
    for _, value in pairs(self._loadedSongInsts) do
        value:unreference()
    end
    thread.getChannel("fi1"):push({doBreak = true})
    FreeplayMenu.super.free(self)
end

return FreeplayMenu