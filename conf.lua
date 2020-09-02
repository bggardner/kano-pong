--[[
conf.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This is the game configuration file specific to LÖVE 2D.
]]--


function love.conf(t)
    -- The name of the save directory (string)
    t.identity = "kanoPong"
    -- The LÖVE version this game was made for (string)
    t.version = "0.10.0"
    -- Attach a console (boolean, Windows only)
    t.console = false
    -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.accelerometerjoystick = false
    -- Enable gamma-correct rendering, when supported by the system (boolean)
    t.gammacorrect = false
    -- The window title (string)
    t.window.title = "Kano Pong"
    -- Filepath to an image to use as the window's icon (string)
    t.window.icon = nil
    -- The window width (number)
    t.window.width = 800
    -- The window height (number)
    t.window.height = 600
    -- Remove all border visuals from the window (boolean)
    t.window.borderless = false
    -- Let the window be user-resizable (boolean)
    t.window.resizable = false
    -- Minimum window width if the window is resizable (number)
    t.window.minwidth = 1
    -- Minimum window height if the window is resizable (number)
    t.window.minheight = 1
    -- Enable fullscreen (boolean)
    t.window.fullscreen = true
    -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.fullscreentype = "desktop"
    -- Enable vertical sync (boolean)
    t.window.vsync = true
    -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.msaa = 0
    -- Index of the monitor to show the window in (number)
    t.window.display = 0
    -- Enable high-dpi mode for the window on a Retina display (boolean)
    t.window.highdpi = false
    -- The x-coordinate of the window's position in the specified display (number)
    t.window.x = nil
    -- The y-coordinate of the window's position in the specified display (number)
    t.window.y = nil

    -- Enabled LÖVE 2D modules (boolean)
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true  -- Disabling it will result 0 delta time in love.update
    t.modules.window = true

    -- Disabled LÖVE 2D modules (boolean)
    t.modules.physics = false
    t.modules.joystick = false
    t.modules.thread = false
    t.modules.touch = false
    t.modules.video = false
end
