local animation_data = require("flora.display.animation.animation_data")

---
--- @class flora.display.animation.animation_controller
---
local animation_controller = class:extend()

function animation_controller:constructor(parent)
    ---
    --- The attached sprite that utilizes this
    --- animation player.
    --- 
    --- @type flora.display.sprite
    ---
    self.parent = parent
    
    ---
    --- The list of added animations.
    ---
    self.animations = {}
    
    ---
    --- The name of the currently playing animation.
    ---
    --- ⚠️ **WARNING**: This can be `nil`!
    --- 
    --- @type string?
    ---
    self.name = nil
    
    ---
    --- The data of the currently playing animation.
    ---
    --- ⚠️ **WARNING**: This can be `nil`!
    --- 
    --- @type flora.display.animation.animation_data
    ---
    self.cur_anim = nil
    
    ---
    --- The function that gets ran when
    --- the current animation has finished playing.
    --- 
    --- @type function?
    ---
    self.on_complete = nil
    
    ---
    --- Whether or not the currently playing
    --- animation is reversed.
    ---
    self.reversed = false
    
    ---
    --- Whether or not the currently playing
    --- animation is finished.
    ---
    self.finished = false

    ---
    --- @protected
    --- @type number
    ---
    self._elapsed_time = 0.0
end

---
--- Resets this animation player and
--- destroys & removes all previously added animations.
---
function animation_controller:reset()
    self.animations = {}
    self.cur_anim = nil
    self.on_complete = nil
    self.reversed = false
    self.finished = false
    self.name = nil
end

---
--- Updates the currently playing animation.
---
--- This shouldn't be called explicitly as it is already
--- called automatically by the engine.
---
--- @param delta number  The time between the last and current frame.
---
function animation_controller:update(delta)
    if self.finished or self.cur_anim == nil then
        return
    end

    self._elapsed_time = self._elapsed_time + delta

    if self._elapsed_time < (1 / self.cur_anim.fps) then
        return
    end
    self._elapsed_time = 0

    if self.cur_anim.cur_frame < self.cur_anim.frame_count - 1 then
        self.cur_anim.cur_frame = self.cur_anim.cur_frame + 1
        self.parent.frame = self.cur_anim.frames[self.cur_anim.cur_frame]
        return
    end

    if self.cur_anim.loop then
        self.cur_anim.cur_frame = 1
        self.parent.frame = self.cur_anim.frames[self.cur_anim.cur_frame]
    else
        self.finished = true
        if self.on_complete then
            self.on_complete(self.name)
        end
    end
end

---
--- Adds a new animation to the sprite.
---
--- @param name   string   What this animation should be called (e.g. `"run"`).
--- @param frames table    An array of numbers indicating what frames to play in what order (e.g. `[1, 2, 3]`).
--- @param fps    number   The speed in frames per second that the animation should play at (e.g. `30` fps).
--- @param loop   boolean  Whether or not the animation is looped or just plays once.
---
function animation_controller:add(name, frames, fps, loop)
    local atlas = self.parent.frames
    if atlas == nil then
        return
    end
    local datas = {}
    for _, num in ipairs(frames) do
        table.insert(datas, atlas.frames[num])
    end
    local anim = animation_data:new(name, datas, fps, loop)
    self.animations[name] = anim
end

---
--- Adds a new animation to the sprite.
---
--- @param name   string   What this animation should be called (e.g. `"run"`).
--- @param prefix string   Common beginning of image names in atlas (e.g. `"tiles-"`).
--- @param fps    number   The speed in frames per second that the animation should play at (e.g. `30` fps).
--- @param loop   boolean  Whether or not the animation is looped or just plays once.
---
function animation_controller:add_by_prefix(name, prefix, fps, loop)
    local atlas = self.parent.frames
    if atlas == nil then
        return
    end
    local __frames = {}

    for _, data in ipairs(atlas.frames) do
        if string.starts_with(data.name, prefix) then
            table.insert(__frames, data)
        end
    end
    local anim = animation_data:new(name, __frames, fps, loop)
    self.animations[name] = anim
end

---
--- Adds a new animation to the sprite.
---
--- @param name    string   What this animation should be called (e.g. `"run"`).
--- @param prefix  string   Common beginning of image names in atlas (e.g. `"tiles-"`).
--- @param indices table    An array of numbers indicating what frames to play in what order (e.g. `[1, 2, 3]`)
--- @param fps     number   The speed in frames per second that the animation should play at (e.g. `30` fps).
--- @param loop    boolean  Whether or not the animation is looped or just plays once.
---
function animation_controller:add_by_indices(name, prefix, indices, fps, loop)
    local atlas = self.parent.frames
    if atlas == nil then
        return
    end
    local __frames = {}

    for _, data in ipairs(atlas.frames) do
        if string.starts_with(data.name, prefix) then
            table.insert(__frames, data)
        end
    end
    local datas = {}
    for _, num in ipairs(indices) do
        table.insert(datas, __frames[num])
    end

    local anim = animation_data:new(name, datas, fps, loop)
    self.animations[name] = anim
end

---
--- Returns whether or not any specified animation exists.
---
--- @param name string  The name of the animation to check.
---
function animation_controller:exists(name)
    return self.animations[name] ~= nil
end

---
--- Returns the data of any specified animation.
---
--- @param name string  The name of the animation to get the data of.
---
function animation_controller:get_by_name(name)
    return self.animations[name]
end

---
--- Removes any specified animation.
---
--- @param name string  The name of the animation to remove.
---
function animation_controller:remove(name)
    local anim = self.animations[name]
    if anim == nil then
        return
    end
    table.remove(self.animations, table.indexOf(anim))
    anim:destroy()
end

---
--- Plays any specified animation if it exists.
---
--- Returns a boolean of `true` on success, and `false` on failure,
--- And a string containing the error if this fails.
---
--- @param  name     string    The name of the animation to play.
--- @param  force    boolean?  Whether or not to forcefully restart the animation.
--- @param  reversed boolean?  Whether or not to play the animation in reverse.
--- @param  frame    integer?  The starting frame to play of the animation.
---
--- @return boolean
---
function animation_controller:play(name, force, reversed, frame)
    if not self:exists(name) then
        flora.log:warn("Animation called "..name.." doesn't exist!")
        return false
    end
    if self.name == name and not self.finished and not (force and force or false) then
        return true
    end

    self.name = name
    self.reversed = reversed and reversed or false
    self.finished = false
    self._elapsed_time = 0

    self.cur_anim = self.animations[name]
    self.cur_anim.cur_frame = frame and frame or 1
    
    self.parent.frame = self.cur_anim.frames[self.cur_anim.cur_frame]

    if self.parent == nil or self.cur_anim == nil or self.cur_anim.frames == nil or self.cur_anim.frames[1] == nil then
        return false
    end

    local first_frame = self.cur_anim.frames[1]
    self.parent.frame_width = first_frame.width
    self.parent.frame_height = first_frame.height
    
    return true
end

---
--- Set an offset for a specified animation.
---
--- Useful for spritesheets generated with software that have
--- wonky offsets for spritesheets.
---
--- @param name string  The name of the animation to offset.
--- @param x    number  The X offset to set on the animation.
--- @param y    number  The Y offset to set on the animation.
---
function animation_controller:set_offset(name, x, y)
    local anim = self.animations[name]
    if anim == nil then
        return
    end
    anim.offset:set(x, y)
end

---
--- Destroys this animation player and stops it from working.
---
function animation_controller:destroy()
    for _, data in pairs(self.animations) do
        data:destroy()
    end
    self.animations = nil
end

return animation_controller