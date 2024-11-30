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

local gfx = love.graphics
local window = love.window

local peakMemUsage = 0.0

local fpsFonts = {
    big = gfx.newFont("assets/fonts/montserrat/semibold.ttf", 16, "light"),
    small = gfx.newFont("assets/fonts/montserrat/semibold.ttf", 12, "light")
}

local function drawFPSText(x, y, text, font, color, alpha)
    for i = 1, 4 do
        gfx.setColor(0, 0, 0, color.a * alpha)
        gfx.print(text, font, x + (i * 0.5), y + (i * 0.5))
    end
    gfx.setColor(color.r, color.g, color.b, color.a * alpha)
    gfx.print(text, font, x, y)
    gfx.setColor(1, 1, 1, 1)
end

local function draw()
    local focused = window.hasFocus()
    local cap = (focused and (Engine.vsync and Native.getMonitorRefreshRate() or Engine.targetFPS) or 10)

    local currentFPS = Engine.getCurrentFPS()
    local currentTPS = Engine.getCurrentTPS()

    local memUsage = Native.getProcessMemory()
    if memUsage > peakMemUsage then
        peakMemUsage = memUsage
    end
    local fpsColor = Color.WHITE
    if cap > 0 and currentFPS < math.floor(cap * 0.5) then
        fpsColor = Color.RED
    end
    local fpsText = tostring(currentFPS)
    local smallFPSText = "FPS"
    drawFPSText(10, 3, fpsText, fpsFonts.big, fpsColor, 1)

    local smallFPSTextX = 10 + fpsFonts.big:getWidth(fpsText) + 5
    drawFPSText(smallFPSTextX, 7, smallFPSText, fpsFonts.small, fpsColor, 1)

    local smallTPSText = " / " .. currentTPS .. " TPS"
    drawFPSText(smallFPSTextX + fpsFonts.small:getWidth(smallFPSText), 7, smallTPSText, fpsFonts.small, fpsColor, 0.5)

    local memText = math.humanizeBytes(memUsage)
    local memPeakText = " / " .. math.humanizeBytes(peakMemUsage)

    drawFPSText(10, 22, memText, fpsFonts.small, fpsColor, 1)
    drawFPSText(10 + fpsFonts.small:getWidth(memText), 22, memPeakText, fpsFonts.small, fpsColor, 0.5)
end

---
--- @class funkin.backend.StatsDisplay
---
local StatsDisplay = {}

function StatsDisplay.init()
    Engine.postDraw:connect(draw)
end

return StatsDisplay