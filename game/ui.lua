--[[
Ui.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Display win/lose screen. Also start screen

]]--

local Locale = require 'common.system.locale'
local Utils = require 'common.system.utils'

local love = love
local g = love.graphics

local Ui = {}
Ui.__index = Ui


function Ui.create(gameStates)
    local self = setmetatable({}, Ui)

    self.gameStates = gameStates

    return self
end

function Ui:load(tileset)
    -- tileset
    local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()
    -- ENTER
    self.enter =
        { image = tileset, quad = g.newQuad(68, 0, 94, 48, tilesetW, tilesetH) }
    self.enter.image:setFilter('nearest', 'nearest')
    -- ESC
    self.esc =
        { image = tileset, quad = g.newQuad(0, 0, 66, 48, tilesetW, tilesetH) }
    self.esc.image:setFilter('nearest', 'nearest')
    -- Text
    self.yes = { text = g.newText(Utils.getFont("Thintel64"), Locale.text("yes")) }
    self.no = { text = g.newText(Utils.getFont("Thintel64"), Locale.text("no")) }
    self.start1 = { text = g.newText(Utils.getFont("Thintel64"), Locale.text("start1")) }
    self.start2 = {text = g.newText(Utils.getFont("Thintel64"), Locale.text("start2")) }
    self.again = { text = g.newText(Utils.getFont("Thintel64"), Locale.text("again")) }
    self.win = { text = "" }
end

function Ui:draw()
    -- Start of the game
    if self.gameStates.current_state == self.gameStates.STATE_START then
        -- Press
        g.draw(self.start1.text, self.start1.x,  self.start1.y)
        -- ENTER
        local x = self.start1.x + self.start1.text:getWidth() + 10
        g.draw(self.enter.image, self.enter.quad, x, self.start1.y)
        -- to Start
        g.draw(self.start2.text, self.start2.x,  self.start2.y)
    -- End of the game
    elseif self.gameStates.current_state == self.gameStates.STATE_LOSE or
           self.gameStates.current_state == self.gameStates.STATE_WIN then
        -- Win / lose
        g.draw(self.win.text, self.win.x,  self.win.y)
        -- Play again?
        g.draw(self.again.text, self.again.x,  self.again.y)
        -- ENTER
        g.draw(self.enter.image, self.enter.quad, self.xEnter, self.yEnter)
        -- ESC
        g.draw(self.esc.image, self.esc.quad, self.xEsc, self.yEsc)
        -- Yes
        g.draw(self.yes.text, self.yes.x,  self.yes.y)
        -- No
        g.draw(self.no.text, self.no.x,  self.no.y)
    end
end

function Ui:activate()
    local width, height = g.getDimensions()

    if self.gameStates.current_state == self.gameStates.STATE_START then
        local x = self.start1.text:getWidth() + 94 + self.start2.text:getWidth()
        -- Start1
        self.start1.x = (width - x) / 2
        self.start1.y = height / 2
        -- Start2
        self.start2.x = self.start1.x + self.start1.text:getWidth() + 115
        self.start2.y = height / 2
    elseif self.gameStates.current_state == self.gameStates.STATE_LOSE or
           self.gameStates.current_state == self.gameStates.STATE_WIN then
        -- Win
        if self.gameStates.current_state == self.gameStates.STATE_LOSE then
            self.win.text = g.newText(Utils.getFont("Thintel64"), Locale.text("lose"))
        elseif  self.gameStates.current_state == self.gameStates.STATE_WIN then
            self.win.text = g.newText(Utils.getFont("Thintel64"), Locale.text("win"))
        end
        self.win.x = (width - self.win.text:getWidth()) / 2
        self.win.y = height * 0.2
        -- Again
        self.again.x = (width - self.again.text:getWidth()) / 2
        self.again.y = height / 2 - self.again.text:getHeight()
        -- Enter
        self.xEnter = (width / 2 - 125)    -- MID - ENTER - SPACE
        self.yEnter = self.again.y + 58
        -- ESC
        self.xEsc = (width / 2 + 30)    -- MID + SPACE
        self.yEsc = self.yEnter
        -- Yes
        self.yes.x = self.xEnter + (94 - self.yes.text:getWidth()) /2
        self.yes.y = self.yEnter + 48
        -- No
        self.no.x = self.xEsc + self.no.text:getWidth() /2
        self.no.y = self.yes.y
    end
end


return Ui
