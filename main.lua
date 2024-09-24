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

flora.config.debug_mode = true
flora.config.max_fps = 144
flora.config.game_size:set(1280, 720)
flora.config.initial_screen = flora.import("test"):new()

--------------------------------------
-- Start Flora after configuring it --
--------------------------------------

flora.start()