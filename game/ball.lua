--[[
ball.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Ball class. Implements ball dynamics

]]--

local Sound = require 'system.sound'
local Utils = require 'common.system.utils'
local Vector = require 'libs.vector-light'

local love = love
local g = love.graphics

local Ball = {}
Ball.__index = Ball

function Ball.create(leftGoal, rightGoal)
    local self = setmetatable({}, Ball)

    -- size
    local width, _ = g.getDimensions()
    self.middle = width / 2
    self.radius = width * 0.008 -- 0.08%
    self.segments = 40
    -- start position
    self.start = {x = width/2, y = (leftGoal.y + leftGoal.length / 2)}
    -- start speed
    self.speed = {x = 300, y = 300}
    -- dynamical variables
    self.dx = self.speed.x
    self.dy = self.speed.y
    self.x = self.start.x
    self.y = self.start.y
    -- has the ball bounced this side
    self.bounced = 0
    -- is the ball visible
    self.visible = true
    -- speed increase factor per bounce
    self.increase = 1.1
    -- Board limits
    self.minPos = { x = leftGoal.x, y = leftGoal.y }
    self.maxPos = { x = rightGoal.x, y = rightGoal.y + rightGoal.length - self.radius}
    -- Trail
    self.trail = {}
    self.maxTrail = 10

    return self
end

function Ball:update(dt, bat_1, bat_2, callback)
    local x = self.x
    local y = self.y

    -- Add old position to trail
    if #self.trail == self.maxTrail then
        -- remove first element
        table.remove(self.trail, 1)
    end
    -- insert position at the end
    table.insert(self.trail, #self.trail + 1, {x = self.x, y = self.y} )

    -- check against walls
    --if not (self.dy > 0) and (y - self.radius) <= 0 then
    if not (self.dy > 0) and (y - self.radius) <= self.minPos.y then
        self.dy = - self.dy
        Sound.wallhit()
    --elseif not (self.dy < 0) and (y + self.radius) >= height then
    elseif not (self.dy < 0) and (y + self.radius) >= self.maxPos.y then
        self.dy = - self.dy
        Sound.wallhit()
    end

    -- check against bats:
    -- avoid complications with the end of bats by only allowing one bounce per side
    if self.bounced == 0  then
        local hit1, dx1, dy1 = bat_1:ball_hit(x, y, self.radius)
        local hit2, dx2, dy2 = bat_2:ball_hit(x, y, self.radius)
        local mirrory, mirrorx

        --[[
        On a bat hit, we perform two actions:
            1) reverse ball direction
            2) reflect ball direction about a vector

            if the ball hits the centre of the bat, the vector is normal to the bat so
            this is equivalent to the ball bouncing off the bat.

            If it hits further from the centre, we tweak the y component of this vector
            to allow the player to control the angle a bit.

        ]]--
        if hit1 or hit2 then
            -- rotate based on distance from centre of bat.
            if hit1 then
                mirrorx = dx1 * 2
                mirrory = dy1
            end
            if hit2 then
                mirrorx = dx2 * 2
                mirrory = dy2
            end

            self.dx = - self.dx
            self.dy = - self.dy

            local ndx, ndy = Vector.mirror(self.dx, self.dy, mirrorx, mirrory)

            -- do reflection, but don't modify x component if this would result in the ball
            -- falling through the bat.
            if (Utils.sign(ndx) == Utils.sign(self.dx)) then
                self.dx = ndx
            end
            -- prevent horizontal speed becoming too slow (boring)
            if math.abs(self.dx) < self.speed.x/2 then
                self.dx = Utils.sign(self.dx) * self.speed.x/2
            end

            self.dy = ndy
            self.bounced = 1
            -- add increase of speed
            self.dx = self.dx * self.increase
            self.dy = self.dy * self.increase

        end
    end

    self.x = x + dt * self.dx
    self.y = y + dt * self.dy

    -- update side state
    if Utils.sign(self.x - self.middle) ~= Utils.sign(x - self.middle) then
        callback()
        self.bounced = 0
    end

end

function Ball:draw()
    if self.visible then
        -- trail
        local alpha = 150
        for i=#self.trail, 1, -1  do
            g.setColor(200, 200, 200, alpha)
            g.circle('fill', self.trail[i].x, self.trail[i].y, self.radius, self.segments)
            alpha = alpha - 40
        end
        -- ball
        g.setColor(255, 255, 255)
        g.circle('fill', self.x, self.y, self.radius, self.segments)
    end
end

function Ball:reset()
    local rnd = math.random(4) - 1
    local x = self.speed.x
    local y = self.speed.y

    self.bounced = 0
    self.visible = true

    self.x = self.start.x
    self.y = self.start.y

    if rnd >= 2 then
        x = -x
    end
    rnd = rnd/2
    if rnd > 0 then
        y = -y
    end

    self.dx = x
    self.dy = y
end

function Ball:offScreen()
    -- returns:
    --   -1 : ball off left
    --    0 : ball on screen (any part)
    --    1 : ball off right
    if self.x < self.minPos.x - self.radius then
        self.visible = false
        return -1
    end
    if self.x > self.maxPos.x + self.radius then
        self.visible = false
        return 1
    end
    return 0
end

function Ball:getPos()
    return self.x, self.y
end


return Ball
