----------------------
-- Initialize Flora --
----------------------

---
--- @type flora
---
flora = require("flora")

--------------------------------------------------
-- Configure Flora settings                     --
--                                              --
-- Most settings are Love2D settings, those are --
-- found in conf.lua in the project root        --
--------------------------------------------------

-- flora.config.debugMode = true
flora.config.maxFPS = 0

flora.config.gameWidth = 1280
flora.config.gameHeight = 720

flora.config.initialState = flora.import("funkin.backend.InitState"):new()

--------------------------------------
-- Start Flora after configuring it --
--------------------------------------

flora.start()