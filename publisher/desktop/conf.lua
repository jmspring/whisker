-- examples/desktop_runtime/conf.lua
-- LÖVE2D configuration file for Whisker Desktop Runtime

function love.conf(t)
    -- Window settings
    t.window.title = "Whisker Interactive Fiction"
    t.window.icon = nil
    t.window.width = 1280
    t.window.height = 720
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.depth = nil
    t.window.stencil = nil
    t.window.display = 1
    t.window.highdpi = false
    t.window.usedpiscale = true
    t.window.x = nil
    t.window.y = nil

    -- Module settings
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true

    -- Identity and version
    t.identity = "whisker"
    t.appendidentity = false
    t.version = "11.3"
    t.console = false
    t.accelerometerjoystick = false
    t.externalstorage = false
    t.gammacorrect = false

    -- Release settings
    t.releases = {
        title = "Whisker Interactive Fiction",
        package = nil,
        loveVersion = "11.3",
        version = "1.0",
        author = "Whisker Team",
        email = nil,
        description = "A desktop interactive fiction player",
        homepage = nil,
        identifier = "com.whisker.player",
        excludeFileList = {},
        releaseDirectory = "releases"
    }
end