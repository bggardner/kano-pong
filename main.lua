--[[
main.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Main file

To execute:
cd build/
./package.sh -r
]]--

local Utils = require 'common.system.utils'
local Locale = require 'common.system.locale'
local GameStates = require 'game.gameStates'
local Sound = require 'system.sound'

local love = love
local g = love.graphics
local a = love.audio

local gameStates

-- local variables
local MAX_FRAMETIME = 1/30 -- 30 fps
local MIN_FRAMETIME = 1/60 -- 60 fps

function love.load(_)
    -- System
    love.mouse.setVisible(false)
    g.setBackgroundColor(0, 0, 0)
    g.setDefaultFilter("nearest", "nearest")
    Utils.load()
    -- localization
    Locale:load()
    -- Create gameStates
    gameStates = GameStates:create()
    gameStates:load()
    -- Sounds
    Sound.load()
end

function love.update(dt)
    gameStates:update(dt)
end

function love.draw()
    gameStates:draw()
end

function love.run()

    Utils.trackAction('lua-pong-start')
    Utils.trackSessionStart('lua-pong')

    if love.load then
        love.load(arg)
    end
    local acc = 0

    -- Main loop time
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e, i, b, c, d in love.event.poll() do
                if e == "quit" then
                    love.quit()
                    return
                end
                love.handlers[e](i, b, c, d)
            end
        end

        -- calculate time
        love.timer.step()
        local dt = love.timer.getDelta()
        dt = math.min(dt, MAX_FRAMETIME)
        acc = acc + dt

        while acc >= MIN_FRAMETIME do
            love.update(MIN_FRAMETIME)
            acc = acc - MIN_FRAMETIME
        end

        -- Update screen
        g.clear()
        love.draw()

        g.present()
        -- Sleeps 10ms after each udpate. By doing this,
        -- CPU time is made available for other processes,
        -- and your OS will love you for it.
        love.timer.sleep(0.001)
    end
end

function love.quit()
    if a then
        a.stop()
    end
    -- save gameStates
    gameStates:save()
    -- Stop tracking
    Utils.trackSessionEnd('lua-pong')
end

-- Input --------------------------------------------------------------------------------

function love.keypressed(key)
    gameStates:keyPressed(key)
end

function love.keyreleased(key)
    gameStates:keyReleased(key)
end
