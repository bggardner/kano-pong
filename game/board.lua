--[[
board.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Board object

]]--

local Utils = require 'common.system.utils'
local Locale = require 'common.system.locale'


local love = love
local g = love.graphics

local Board = {}
Board.__index = Board


function Board.create()
    local self = setmetatable({}, Board)

    local width, height = g.getDimensions()
    self.lineWidth = 6
    -- board
    self.width = width * 0.6            -- 80% of the window width
    self.height = height * 0.6          -- 80% of the window width
    self.x = (width - self.width) / 2   -- centred in the middle
    self.y = height * 0.1               -- 10% of the window height
    -- middle line
    self.middleWidth = self.lineWidth
    self.middleHeight = self.height * 0.05
    self.numLines = (self.height / self.middleHeight) / 2
    self.middleX = (width - self.middleWidth) / 2

    return self
end

function Board:load(tileset)
    -- tileset
    local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()
    -- Opponent portrait
    local text = g.newText(Utils.getFont("Thintel64"), Locale.text("Gregory"))
    self.opponent =
        { image = tileset, quad = g.newQuad(164, 0, 80, 80, tilesetW, tilesetH),
          x = self.x, y = self.y + self.height + 10 }
    self.opponent.image:setFilter('nearest', 'nearest')
    self.opponentName =
        { text = text, x = self.x + 80 + 5, y = self.opponent.y }
    -- User portrait
    -- load file from ~/.local/share/love/kanoPong
    local img
    if love.filesystem.getInfo("res/images/avatar.png") then
        img = g.newImage("res/images/avatar.png")
    end
    local quad
    local scale
    local tileS = 32
    if not img then
        -- Custom avatar could not be found
        img = tileset
        quad = g.newQuad(246, 0, 80, 80, tilesetW, tilesetH)
        scale = 1
    else
        tilesetW, tilesetH = img:getWidth(), img:getHeight()
        -- get first tile from the tileset and crop
        quad = g.newQuad(1 + tileS * 0.1, 1, tileS * 0.7, tileS * 0.67, tilesetW, tilesetH)
        scale = 3.6
    end
    self.user =
        { image = img, quad = quad,
          x = self.x + self.width - 80, y = self.opponent.y - 5, scale = scale }
    self.user.image:setFilter('nearest', 'nearest')
    local name = Utils.getUsername() or Locale.text("me")
    text = g.newText(Utils.getFont("Thintel64"), name)
    self.userName =
        { text = text,
          x = self.user.x - text:getWidth() - 10, y = self.user.y }
    -- Check if name is too long
    local width, _ = g.getDimensions()
    if (self.userName.x < (width / 2) + 30) then
        self.userName.text:set(string.sub(name, 1, 5) .. "...")
        self.userName.x = self.user.x - text:getWidth() - 10
    end
    -- Score
    self.score = g.newText(Utils.getFont("Thintel128"), "")
end

function Board:draw()
    local red, green, blue, alpha = g.getColor()
    local lineW = g.getLineWidth()

    g.setLineWidth(self.lineWidth)
    -- board
    g.rectangle('line', self.x, self.y, self.width, self.height)
    -- middle line
    g.setColor(120, 120, 120)
    local y = self.y + self.lineWidth
    for _=1, self.numLines do
        g.rectangle('fill', self.middleX, y, self.middleWidth, self.middleHeight)
        y = y + (self.middleHeight * 2)
    end
    g.setColor(red, green, blue, alpha)

    -- Opponent
    g.draw(self.opponent.image, self.opponent.quad, self.opponent.x, self.opponent.y)
    g.draw(self.opponentName.text, self.opponentName.x, self.opponentName.y)
    -- User
    g.draw(self.user.image, self.user.quad, self.user.x, self.user.y,
           0, self.user.scale, self.user.scale)
    g.draw(self.userName.text, self.userName.x, self.userName.y)

    -- score
    g.draw(self.score, self.scoreX, self.scoreY)

    -- resetting graphics
    g.setColor(red, green, blue, alpha)
    g.setLineWidth(lineW)
end

function Board:setScore(player1, player2)
    self.score:set(player1 .. " : " .. player2)
    local width, _ = g.getDimensions()
    self.scoreX = (width - self.score:getWidth())/2
    self.scoreY = self.y + self.height
end

function Board:getGoalLeft()
    local x = self.x + self.lineWidth
    local y = self.y + self.lineWidth
    return {x = x, y = y, length = self.height}
end

function Board:getGoalRight()
    local x = self.x + self.width - self.lineWidth
    local y = self.y + self.lineWidth
    return {x = x, y = y, length = self.height}
end

return Board
