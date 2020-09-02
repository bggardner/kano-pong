--[[
overscan.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Adjust for overscan


]]--

local Utils = require 'common.system.utils'

local love = love
local  Overscan = {}

local overscan = Utils.getOverscan()
local width, height = love.graphics.getDimensions()

function Overscan:adjust()
    love.graphics.translate(overscan.left, overscan.top)    

    love.graphics.scale(
        (width-overscan.left-overscan.right)/width,
        (height-overscan.top-overscan.bottom)/height
    )
    love.graphics.push()
end    

return Overscan
