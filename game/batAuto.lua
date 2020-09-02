 --[[
batAuto.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Behavior is based on ball position:
     - Move towards ball if it is within 'sight' distance (horizontally)
     - Otherwise stop
]]--

local Bat = require 'game.bat'

local BatAuto = {}
BatAuto.__index = BatAuto

local love = love
local g = love.graphics

setmetatable(BatAuto, Bat)

function BatAuto.create(start)
   local self = Bat.create(start, 0)
   setmetatable(self, BatAuto)

   local width, _ = g.getDimensions()
   self.sight = width/4
   self:cross()

   return self
end

function BatAuto:autoUpdate(ballx, bally)
    local x = self.start.x
    local y = self.y
    -- delta calculation to smooth movement close to
    -- target
    local delta = math.abs(y - bally)
    if delta >= self.size.y/2 then
    delta = self.v
    end

    if math.abs(ballx - x) < self.sightLen then
    if y < bally then
        self.dy = math.min(delta*8, self.v)

    else
        self.dy = - math.min(delta*8, self.v)
    end

    else
    self. dy = 0
   end
end

function BatAuto:cross()
    self.sightLen = self.sight + self.sight * math.random()
end

return BatAuto
