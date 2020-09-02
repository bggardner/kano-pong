--[[
locale.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

Localisation manager
]]--


local love = love
local f = love.filesystem


local Locale = {}

local path = 'res/locales'
local fileName = 'lang.lua'
local currentLocale = 'en'
local localization = nil


function Locale.load()
    local filepath = path..'/'..currentLocale..'/'..fileName
    if f.exists(filepath) then
        localization = f.load(filepath)()
    else                                              -- DEBUG_TAG_START
        print("ERROR: " .. filepath .. " not found")  -- DEBUG_TAG_END
    end
end

function Locale.setLocalization(locale)
    currentLocale = locale
    Locale.load()
end

function Locale.text(key)
    return localization[key] or ""
end

function Locale.textWithArg(key, ...)
    -- replace flags $1, $2, etc with corresponding arguments
    local text = localization[key] or ""
    local n = select('#', ...)  -- number of arguments
    for i = 1, n do
        local a = select(i, ...)
        text = string.gsub(text, "$" .. i, a)
    end
    return text
end

function Locale.currentLocale()
    return localization
end


return Locale
