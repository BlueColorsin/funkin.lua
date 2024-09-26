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
flora.config.max_fps = 0

flora.config.game_width = 1280
flora.config.game_height = 720

flora.config.initial_state = flora.import("funkin.backend.init_state"):new()

--------------------------------------
-- Start Flora after configuring it --
--------------------------------------

flora.start()