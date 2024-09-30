---
--- Accessed via `flora.Sound`.
---
--- @class flora.frontends.SoundFrontEnd : flora.base.Basic
---
local SoundFrontEnd = Basic:extend("SoundFrontEnd", ...)

function SoundFrontEnd:constructor()
    SoundFrontEnd.super.constructor(self)

    ---
    --- The volume multiplier of ALL sounds. Ranges from 0 to 1. (default: `1.0`)
    ---
    self.volume = 1.0

    ---
    --- Controls whether or not ALL sounds are muted.
    ---
    self.muted = false

    ---
    --- Built-in background music functionality, useful for
    --- menus, levels, etc.
    --- 
    --- @type flora.Sound
    ---
    self.music = Sound:new()

    ---
    --- A list containing every sound that has been loaded.
    --- 
    --- Non-playing sounds in the list are recycled whenever
    --- `load()` or `play()` are called.
    ---
    self.list = {}
end

---
--- Loads and returns a new sound.
---
--- @param  data     string|love.SoundData  The data to load onto a new sound.
--- @param  stream   boolean?               Whether or not this sound should be streamed. This only works if `data` is a string. (default: `true`)
--- @param  volume   number?                The volume of the sound. (default: `1.0`)
--- @param  looping  boolean?               Whether or not the sound should loop. (default: `false`)
---
--- @return flora.Sound
---
function SoundFrontEnd:load(data, stream, volume, looping)
    ---
    --- @type flora.Sound
    ---
    local snd = nil
    for i = 1, #self.list do
        ---
        --- @type flora.Sound
        ---
        local s = self.list[i]
        if s and not s.playing then
            snd = s
            break
        end
    end
    if not snd then
        -- no available sound was found, make a new one
        snd = Sound:new()
        table.insert(self.list, snd)
    end
    snd:load(data, stream)
    snd.volume = volume and volume or 1.0
    snd.looping = looping and looping or false
    return snd
end

---
--- Loads, plays, and returns a new sound.
---
--- @param  data     string|love.SoundData  The data to load onto a new sound.
--- @param  stream   boolean?               Whether or not this sound should be streamed. This only works if `data` is a string. (default: `true`)
--- @param  volume   number?                The volume of the sound. (default: `1.0`)
--- @param  looping  boolean?               Whether or not the sound should loop. (default: `false`)
---
--- @return flora.Sound
---
function SoundFrontEnd:play(data, stream, volume, looping)
    local snd = self:load(data, stream, volume, looping)
    snd:play()
    return snd
end

---
--- Loads given data onto the background music, plays it, and returns it.
---
--- @param  data     string|love.SoundData  The data to load onto the background music.
--- @param  stream   boolean?               Whether or not the music should be streamed. This only works if `data` is a string. (default: `true`)
--- @param  volume   number?                The volume of the music. (default: `1.0`)
--- @param  looping  boolean?               Whether or not the music should loop. (default: `true`)
---
--- @return flora.Sound
---
function SoundFrontEnd:playMusic(data, stream, volume, looping)
    self.music:load(data, stream)
    self.music.volume = volume and volume or 1.0
    self.music.looping = looping and looping or true
    self.music:play()
    return self.music
end

function SoundFrontEnd:update()
    self.music:update()

    for i = 1, #self.list do
        ---
        --- @type flora.Sound
        ---
        local snd = self.list[i]
        if snd and snd.playing then
            snd:update()
        end
    end
end

return SoundFrontEnd