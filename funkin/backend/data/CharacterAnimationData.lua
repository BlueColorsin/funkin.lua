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

---
--- @class funkin.backend.data.CharacterAnimationData
---
local CharacterAnimationData = {
    ---
    --- @type string
    ---
    name = nil,

    ---
    --- @type string?
    ---
    prefix = nil,

    ---
    --- @type table<integer>?
    ---
    indices = nil,

    ---
    --- @type number
    ---
    fps = nil,

    ---
    --- @type boolean
    ---
    looped = nil,

    ---
    --- @type table<string, integer>
    ---
    offset = nil
}
return CharacterAnimationData