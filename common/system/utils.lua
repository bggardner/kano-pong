--[[
utils.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

]]--

local love = love
local g = love.graphics

local Utils = {}
local username

-- Fonts
local fonts = {}
local FONT_THINTEL64 = "Thintel64"
local FONT_THINTEL128 = "Thintel128"

-- local function forward declaration
local loadUsername

function Utils.load()
    -- init random
    math.randomseed(os.time())
    math.random()
    -- fonts
    -- FONT_THINTEL16
    local font = g.newFont("common/res/fonts/Thintel.ttf", 64)
    font:setFilter('linear', 'linear', 0)
    fonts[FONT_THINTEL64] = font
    -- FONT_THINTEL32
    font = g.newFont("common/res/fonts/Thintel.ttf", 128)
    font:setFilter('linear', 'linear', 0)
    fonts[FONT_THINTEL128] = font
    -- Username
    username, _ = loadUsername()
end

-- Math ---------------------------------------------------------------------------------

function Utils.sign(x)
    if x < 0 then
       return -1
    else
       return 1
    end
end

-- Font ---------------------------------------------------------------------------------

function Utils.setFont(name)
    g.setFont(fonts[name])
end

function Utils.getFont(font)
    return fonts[font]
end

function Utils.getTextLength(name, text)
    return fonts[name]:getWidth(text)
end

function Utils.getTextHeight(name, text)
    return fonts[name]:getHeight(text)
end

-- System -------------------------------------------------------------------------------

function Utils.fileExists(path)
    local file = io.open(path, 'r')
    if file then
        io.close(file)
        return true
    end
    return false
end

function Utils.launchCmd(cmd)
    if love.system.getOS() ~= 'Linux' then
        print("ERROR: Will not exec '" .. cmd .. "' on this platform.")  -- DEBUG_TAG
        return nil
    end
    --
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    return result
end

-- Get pi overscan. Should return zeros on non-pi
function Utils.getOverscan()
    local output = Utils.launchCmd("/usr/bin/overscan")
    local res = {bottom = 0, top = 0, left = 0, right = 0}
    if not output then
        return res
    else
        local t, b, l, r = string.match(output,"(%d+) (%d+) (%d+) (%d+)")
        if b==nil or t==nil or l==nil or r==nil then
            return res
        end
        res = {bottom = b, top = t, left = l, right = r}

        return res
    end
end

-- Tracker ------------------------------------------------------------------------------

function Utils.trackSessionStart(name)
    if not Utils.fileExists('/usr/bin/kano-tracker-ctl') then
        print('Tracking tool not found!')
        return
    end
    os.execute("kano-tracker-ctl session start \"" .. name .. "\"  $PPID &")
end

function Utils.trackSessionEnd(name)
    if not Utils.fileExists('/usr/bin/kano-tracker-ctl') then
        print('Tracking tool not found!')
        return
    end
    os.execute("kano-tracker-ctl session end \"" .. name .. "\"  $PPID &")
end

function Utils.trackData(name, key, value)
    if not Utils.fileExists('/usr/bin/kano-tracker-ctl') then
        print('Tracking tool not found!')
        return
    end
    if type(value) == 'number' then
        os.execute(
            "kano-tracker-ctl data " .. name .. " '{\"" .. key .. "\": " .. value ..
            "}' &"
        )
    elseif type(value) == 'string' then
        os.execute(
            "kano-tracker-ctl data " .. name .. " '{\"" .. key .. "\": \"" .. value ..
            "\"}' &"
        )
    else
        print('Utils: trackData: Data type ' .. type(value) .. ' not supported!')
    end
end

function Utils.trackAction(name)
    if not Utils.fileExists('/usr/bin/kano-tracker-ctl') then
        print('Tracking tool not found!')
        return
    end
    os.execute('kano-tracker-ctl action "' .. name .. '" &')
end

-- Profile ------------------------------------------------------------------------------

function Utils.profileSaveAppStateVariable(key, value)
    if not Utils.fileExists('/usr/bin/kano-tracker-ctl') then
        print('Tracking tool not found!')
        return
    end
    if type(value) == 'number' then
        os.execute(
            'kano-profile-cli save_app_state_variable love-minigames ' .. key .. ' ' ..
            value
        )
    elseif type(value) == 'string' then
        os.execute(
            "kano-profile-cli save_app_state_variable love-minigames " .. key .. " \"" ..
            value .. "\""
        )
    else
        print(
            'Utils: profileSaveAppStateVariable: Data type ' .. type(value) ..
            ' not supported!'
        )
    end
end

function Utils.getMinigamesVariable(variable)
    local homedir = os.getenv("HOME")
    local value = Utils.launchCmd(
        'jq .' .. variable .. ' ' ..
        homedir .. '/.kanoprofile/apps/love-minigames/state.json'
    )
    return tonumber(value) or 0
end

function Utils.getUsername()
    return username
end

-- Private ------------------------------------------------------------------------------

-- Returns username and if logged in to Kano World or not
function loadUsername()
    local homedir = os.getenv("HOME")
    local path = homedir .. '/.kanoprofile/profile/profile.json'

    if not Utils.fileExists(path) then
        print("ERROR: Kano profile file not found. Location: " .. path)  -- DEBUG_TAG
        return nil, false
    end

    -- Kano World user name
    local cmd = "jq .kanoworld_username "..path
    local handle = io.popen(cmd)
    username = handle:read("*a")
    -- remove special characters (quotes)
    username = username:gsub('%W','')
    handle:close()
    if username ~= "null" then
        return username, true
    end
    -- Linux user name
    cmd = "jq .username_linux "..path
    handle = io.popen(cmd)
    username = handle:read("*a")
    -- remove special characters (quotes)
    username = username:gsub('%W','')
    handle:close()
    if username ~= "null" then
        return username, false
    end
    -- return default option
    return nil, false
end


return Utils
