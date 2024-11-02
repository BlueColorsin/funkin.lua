-- Allow console output to be shown immediately
io.stdout:setvbuf("no")

-- [ CORE IMPORTS ] --

ChipCore = require("chip") --- @type chip.Core
ChipCore.init({
    width = 1280,
    height = 720,
    targetFPS = 144,
    initialScene = require("funkin.backend.InitState"):new()
})