--[[
gameStates.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Manages all the states in the game
]]--

local GameManager = require 'game.gameManager'
local Ui = require 'game.ui'
local Overscan = require 'common.system.overscan'
local Utils = require 'common.system.utils'

local love = love
local g = love.graphics

local GameStates = {}
GameStates.__index = GameStates

local gameIsPaused = false
local width, height = g.getDimensions()


function GameStates.create()
    local self = setmetatable({}, GameStates)

    -- Constant state
    self.STATE_START = 1
    self.STATE_INGAME = 2
    self.STATE_WIN = 3
    self.STATE_LOSE = 4
    -- Create states
    self.current_state = nil
    self.gameManager = GameManager.create()
    self.ui = Ui.create(self)

    return self
end

function GameStates:load()
    Overscan:adjust()
    --
    local topbar = 30
    -- allow space for esc icon
    g.translate(0, topbar)
    g.scale(1.0,(height-topbar)/height)
    g.push()
    --
    local tileset = g.newImage("/res/images/pong-sheet.png")
    self.gameManager:load(tileset)
    self.ui:load(tileset)
    --
    self:changeState(self.STATE_START)
    -- collect garbage after loading all the assets in the game
    collectgarbage('collect')
end

function GameStates:save()
    self.gameManager:save()
end

function GameStates:update(dt)
    if self.current_state == self.STATE_INGAME then
	   self.gameManager:update(dt, self)
    end
end

function GameStates:draw()
    self.gameManager:draw()
    if self.current_state ~= self.INGAME then
	   self.ui:draw()
    end
end

function GameStates:changeState(state)
    self.current_state = state

    if state == self.STATE_START then
        self.gameManager:init(self)
    end
    self.ui:activate()
end

function GameStates:save()
    local goalsFor, goalsAgainst = self.gameManager:getScore()
    -- Save the score if we have finished the match
    if goalsFor == 3 or goalsAgainst == 3 then
        local result = tostring(goalsFor)..','..tostring(goalsAgainst)
        local key = "pong_result"
        Utils.profileSaveAppStateVariable(key, result)
    end
end

-- Input --------------------------------------------------------------------------------

function GameStates:keyReleased(key)
    -- Play the game
    if self.current_state == self.STATE_INGAME then
        self.gameManager:keyReleased(key)
        if key == 'escape' then
            love.event.quit()
        end
    -- Start the game
    elseif self.current_state == self.STATE_START and key == 'return' then
        self:changeState(self.STATE_INGAME)
    -- End game
    else
        -- Play again
        if key == 'return' then
            self:changeState(self.STATE_INGAME)
            self.gameManager:init(self)
            Utils.trackAction('lua-pong-playagain')
        elseif key == 'escape' then
            love.event.quit()
        end
    end
end

function GameStates:keyPressed(key)
    if self.current_state == self.STATE_INGAME then
        self.gameManager:keyPressed(key)
    end
end


return GameStates
