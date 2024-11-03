Chip = require("chip") --- @type chip.Chip
Chip.init({
    gameWidth = 1280,
    gameHeight = 720,
    targetFPS = 0,
    initialScene = require("funkin.backend.InitState"):new()
})