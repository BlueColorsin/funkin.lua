function love.conf(t)
    t.identity = "funkin.lua"
    t.version = "12.0"
    t.console = false

    t.gammacorrect = false
    
	t.highdpi = false
    t.usedpiscale = false

    t.window.title = "funkin.lua"

    t.window.width = 1280
    t.window.height = 720

    t.window.minwidth = 200
    t.window.minheight = 0

    t.window.resizable = true
    t.window.vsync = false

    t.renderers = {"metal", "opengl"} -- NOTE: vulkan instantly crashes, so do NOT use it!!
end