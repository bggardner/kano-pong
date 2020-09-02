--[[
bat.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Bat Classes.
There are two subclasses, ManualBat which is controlled by the user and AutoBat which
is computer controlled.

]]--

local Sound = require 'system.sound'

local love = love
local g = love.graphics

local Bat = {}
Bat.__index = Bat


function Bat.create(goal, side)
    -- side: 0 for left, 1 for right
    local self = setmetatable({}, Bat)

    local _, height = g.getDimensions()
    self.size = { x = 12, y = height * 0.08}
    self.start = { x = goal.x, y = (goal.y + goal.length / 2) }
    self.side = side
    if self.side == 1 then
	   self.delta_x = -self.size.x/2
	   self.mirror_x = -self.size.y
    else
	   self.delta_x = self.size.x/2
	   self.mirror_x = self.size.y
    end

    -- static variables
    self.x = goal.x - self.size.x/2
    self.minY = goal.y
    self.maxY = goal.y + goal.length - 10
    -- dynamical variables
    self.y = self.start.y
    self.dy = 0

    -- bat speed
    self.v = 500

    return self
end

function Bat:update(dt)
    local new_y = self.y + self.dy * dt
    if (new_y - self.size.y/2) > self.minY and (new_y + self.size.y/2 < self.maxY) then
	   self.y = new_y
    end
end

function Bat:draw()
   g.rectangle('fill', self.x, self.y-self.size.y/2, self.size.x, self.size.y)
end

function Bat:cross()
end

function Bat:reset()
    self.y = self.start.y
end

function Bat:ball_hit(bx, by, br)
    -- return (is_ball_hitting bat, bat_x_normal, delta_y_ball_to_bat)
    local x = self.start.x
    local y = self.y
    x = x + self.delta_x
    if x < (bx+br) and x > (bx-br) then
       if by < (y + self.size.y/2) and by > (y - self.size.y/2) then
           Sound.hit(self.side * 2)
           return true, self.mirror_x, (by - self.y)
       end
    end
    return false, self.mirror_x, (by - self.y)
end

function Bat:equals(fixture)
    return fixture == self.fixture
end


return Bat
