--[[
sound.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

]]--

local love = love
local a = love.audio

local Sound = {}
local scoreSound
local wallSound
local winSound
local hitSounds = {}

local sound_path = "res/sounds/"

function Sound.load()
    -- hits
    hitSounds[1] = a.newSource(sound_path.."Pong-Hit0.wav", "static")
    hitSounds[2] = a.newSource(sound_path.."Pong-Hit1.wav", "static")
    hitSounds[3] = a.newSource(sound_path.."Pong-Hit2.wav", "static")
    hitSounds[4] = a.newSource(sound_path.."Pong-Hit3.wav", "static")
    wallSound = a.newSource(sound_path.."Pong-WallHit.wav", "static")
    -- sfx
    scoreSound = a.newSource(sound_path.."Pong-Score.wav", "static")
    winSound = a.newSource(sound_path.."Pong-Win.wav", "static")
end

function Sound.hit()
    local hit = hitSounds[(math.random(4))]
    a.play(hit)
end

function Sound.wallhit()
    a.play(wallSound)
end

function Sound.score()
    a.play(scoreSound)
end

function Sound.win()
    a.play(winSound)
end


return Sound
