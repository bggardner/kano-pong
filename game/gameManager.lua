--[[
gameManager.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Overall game logic

]]--

local BatAuto = require 'game.batAuto'
local BatUser = require 'game.batUser'
local Ball = require 'game.ball'
local Board = require 'game.board'
local Sound = require 'system.sound'
local Utils = require 'common.system.utils'

local love = love
local g = love.graphics

local GameManager = {}
GameManager.__index = GameManager

-- local variables
local max_score = 3
local score_wait = 0

function GameManager.create()
    local self = setmetatable({}, GameManager)

    self.board = Board.create()

     -- Position of the bats
    local leftGoal = self.board:getGoalLeft()
    leftGoal.x = leftGoal.x + 10
    local rightGoal = self.board:getGoalRight()
    rightGoal.x = rightGoal.x - 10

    -- create all objects
    self.bat_1 = BatAuto.create(leftGoal)
    self.bat_2 = BatUser.create(rightGoal)
    self.ball = Ball.create(leftGoal, rightGoal)
    -- score
    self.score = {player1 = 0, player2 = 0}

    return self
end

function GameManager:load(tileset)
    self.escImage =
    { image = g.newImage("common/res/images/esc-exit.png"),
      x = 30, y = 30}

    self.board:load(tileset)
end

function GameManager:init()
    self.score = {player1 = 0, player2 = 0}
    self.board:setScore(self.score.player1, self.score.player2)
end

function GameManager:update(dt, gameStates)

    local function bat_reset()
        -- callback to reset bat once per side
        -- simplifies bounce logic
        self.bat_1:cross()
        self.bat_2:cross()
    end
    self.ball:update(dt, self.bat_1, self.bat_2, bat_reset)

    -- bat dynamics update
    self.bat_1:update(dt)
    self.bat_2:update(dt)

    -- bat control: only bat1, bat2 is controlled by keys
    local bx, by = self.ball:getPos()
    self.bat_1:autoUpdate(bx, by)
    -- score
    self:score_update(dt, gameStates)
end

function GameManager:draw()
    -- board
    self.board:draw()
    -- objects
    self.bat_1:draw()
    self.bat_2:draw()
    self.ball:draw()
    -- Esc
    g.draw(self.escImage.image, self.escImage.x, self.escImage.y, 0, 2, 2)
end

function GameManager:score_update(dt, gameStates)
    -- Also resets ball position
    -- reset ball after pause
    if score_wait > 0 then
        score_wait = score_wait - dt
        if score_wait <= 0 then
            self.ball:reset()
            self.bat_1:reset()
            self.bat_2:reset()
        end
    else
        -- check for scoring
        local res = self.ball:offScreen()
        if res < 0 then
            self.score.player2 = self.score.player2 + 1
            score_wait = 1
            Sound.score()
        elseif res > 0 then
            self.score.player1 = self.score.player1 + 1
            score_wait = 1
            Sound.score()
        end
        self.board:setScore(self.score.player1, self.score.player2)
    end

    -- Check for end of game
    if self.score.player1 >= max_score then
        gameStates:changeState(gameStates.STATE_LOSE)
        Utils.trackAction('lua-pong-playerlose')
    end
    if self.score.player2 >= max_score then
        Sound.win()
        gameStates:changeState(gameStates.STATE_WIN)
        Utils.trackAction('lua-pong-playerwins')
    end
end

function GameManager:getScore()
    return self.score.player1, self.score.player2
end

-- Input --------------------------------------------------------------------------------

function GameManager:keyPressed(key)
   self.bat_2:keyPressed(key)
end

function GameManager:keyReleased(key)
   self.bat_2:keyReleased(key)
end


return GameManager
