function love.conf(t)
    t.identity = "funkin.lua"
    t.version = "12.0"
    t.console = false

    t.window.title = "funkin.lua"

    t.window.width = 1152
    t.window.height = 648

    t.window.minwidth = 200
    t.window.minheight = 0

    t.window.resizable = true
    t.window.vsync = false
end