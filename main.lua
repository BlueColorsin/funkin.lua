----------------------
-- Initialize Flora --
----------------------

---
--- @type flora.Flora
---
Flora = require("flora")

--------------------------------------------------
-- Configure Flora settings                     --
--                                              --
-- Most settings are Love2D settings, those are --
-- found in conf.lua in the project root        --
--------------------------------------------------

-- Flora.config.debugMode = true
Flora.config.maxFPS = 0

Flora.config.gameWidth = 1280
Flora.config.gameHeight = 720

Flora.config.initialState = Flora.import("funkin.backend.InitState"):new()

--------------------------------------
-- Start Flora after configuring it --
--------------------------------------

Flora.start()