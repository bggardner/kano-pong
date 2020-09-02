 --[[
batUser.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Deals with keyboard control
]]--

local Bat = require 'game.bat'

local batUser = {}
batUser.__index = batUser

setmetatable(batUser, Bat)

function batUser.create(start)
    local self = Bat.create(start, 1)
    setmetatable(self, batUser)

    return self
end

-- Input --------------------------------------------------------------------------------

function batUser:keyReleased(key)
    if key == self.lastKey then
        self.dy = 0
    end
end

function batUser:keyPressed(key)
    if key == 'up' then
        self.dy = -self.v
    elseif key == 'down' then
        self.dy = self.v
    end
    self.lastKey = key
end

return batUser
