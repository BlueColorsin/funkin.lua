---
--- A basic object used for playing sounds.
--- 
--- @class flora.sound : flora.base.object
---
local sound = object:extend("sound", ...)

function sound:constructor()
    sound.super.constructor(self)

    ---
    --- The source used to play this sound.
    --- 
    --- NOTE: You must call `load()` to initialize this
    --- sound before playing it!
    ---
    --- @type love.Source?
    ---
    self.source = nil

    ---
    --- Whether or not this sound is playing.
    --- 
    --- @type boolean
    ---
    self.playing = nil

    ---
    --- The volume multiplier of this sound. Ranges from 0 to 1. (default: `1`)
    --- 
    --- @type number
    ---
    self.volume = nil

    ---
    --- The pitch multiplier of this sound. (default: `1`)
    --- 
    --- @type number
    ---
    self.pitch = nil
    
    ---
    --- The current playback time of this sound. (in seconds)
    --- 
    --- @type number
    ---
    self.time = nil

    ---
    --- The current length of this sound. (in seconds)
    --- 
    --- @type number
    ---
    self.length = nil
    
    ---
    --- Whether or not this sound should loop indefinitely.
    --- 
    --- @type boolean
    ---
    self.looping = nil

    --- 
    --- The function that gets called when this sound
    --- finishes playing.
    --- 
    --- @type function?
    --- 
    self.on_complete = nil

    ---
    --- @protected
    --- @type number
    ---
    self._volume = 1.0

    ---
    --- @protected
    --- @type number
    ---
    self._pitch = 1.0

    ---
    --- @protected
    --- @type boolean
    ---
    self._playing = false

    ---
    --- @protected
    --- @type boolean
    ---
    self._paused = false
    
    ---
    --- @protected
    --- @type flora.tweens.tween
    ---
    self._fade_tween = nil
end

---
--- @param  data    string|love.SoundData  The data to load onto this sound object.
--- @param  stream  boolean?               Whether or not this sound should be streamed. This only works if `data` is a string. (default: `true`)
--- 
--- @return flora.sound
---
function sound:load(data, stream)
    stream = stream and stream or true

    if self.source then
        self.source:release()
    end
    if stream then
        self.source = love.audio.newSource(data, "stream")
    else
        self.source = love.audio.newSource(flora.assets:load_sound(data), "static")
    end
    self.source:setLooping(false)
    self.source:setVolume(math.clamp(self.volume * flora.sound.volume * (not flora.sound.muted and 1.0 or 0.0), 0.0, 1.0))
    self.source:setPitch(self.pitch)
    
    return self
end

function sound:play()
    if self.source then
        self.source:play()
        self.source:setVolume(math.clamp(self.volume * flora.sound.volume * (not flora.sound.muted and 1.0 or 0.0), 0.0, 1.0))
    end
    self._playing = true
    self._paused = false
end

function sound:pause()
    if self.source then
        self.source:pause()
    end
    self._playing = false
    self._paused = true
end

function sound:stop()
    if self.source then
        self.source:stop()
    end
    self._playing = false
    self._paused = false
end

function sound:seek(time)
    if self.source then
        self.source:seek(time, "seconds")
    end
end

---
--- @param  duration     number     The duration of the fade.
--- @param  from         number?    The volume to fade in from. (default: `0.0`)
--- @param  to           number?    The volume to fade in towards. (default: `1.0`)
--- @param  on_complete  function?  The function that gets called when this sound finishes fading in.
---
--- @return flora.sound
---
function sound:fade_in(duration, from, to, on_complete)
    if not self.playing then
        self:play()
    end
    self.volume = from and from or 0.0

    if self._fade_tween then
        self._fade_tween:dispose()
    end
    self._fade_tween = tween:new()
    self._fade_tween:tween_property(self, "volume", to and to or 1.0, duration)
    self._fade_tween.on_complete = on_complete
    self._fade_tween:start()

    return self
end

---
--- @param  duration     number     The duration of the fade.
--- @param  to           number?    The volume to fade out towards. (default: `0.0`)
--- @param  on_complete  function?  The function that gets called when this sound finishes fading out.
---
--- @return flora.sound
---
function sound:fade_out(duration, to, on_complete)
    if self._fade_tween then
        self._fade_tween:dispose()
    end
    self._fade_tween = tween:new()
    self._fade_tween:tween_property(self, "volume", to and to or 0.0, duration)
    self._fade_tween.on_complete = on_complete
    self._fade_tween:start()

    return self
end

function sound:update()
    if self.source then
        self.source:setVolume(math.clamp(self.volume * flora.sound.volume * (not flora.sound.muted and 1.0 or 0.0), 0.0, 1.0))
        
        if self._playing and not self._paused and not self.source:isPlaying() then
            self._playing = false
            if self.on_complete then
                self.on_complete()
            end
        end
        if self._playing then
            if not love.window.hasFocus() then
                self._paused = true
                self.source:pause()
            else
                self._paused = false
                self.source:play()
            end
        end
    end
end

function sound:dispose()
    if self.source then
        self.source:release()
    end
    self.source = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function sound:get_time()
    if self.source then
        return self.source:tell("seconds")
    end
    return 0.0
end

---
--- @protected
---
function sound:get_length()
    if self.source then
        return self.source:getDuration("seconds")
    end
    return 0.0
end
        
---
--- @protected
---
function sound:get_volume()
    return self._volume
end

---
--- @protected
---
function sound:get_pitch()
    return self._pitch
end

---
--- @protected
---
function sound:get_playing()
    return self._playing
end

---
--- @protected
---
function sound:get_looping()
    if self.source then
        return self.source:isLooping()
    end
    return false
end

---
--- @protected
---
function sound:set_time(val)
    self.source:seek(val, "seconds")
    return val
end

---
--- @protected
---
function sound:set_volume(val)
    self._volume = math.clamp(val, 0.0, 1.0)
    if self.source then
        self.source:setVolume(math.clamp(self.volume * flora.sound.volume, 0.0, 1.0))
    end
    return self._volume
end

---
--- @protected
---
function sound:set_pitch(val)
    self._pitch = val
    if self.source then
        self.source:setPitch(self._pitch)
    end
    return self._pitch
end

---
--- @protected
---
function sound:set_looping(val)
    if self.source then
        self.source:setLooping(val)
    end
    return val
end

return sound