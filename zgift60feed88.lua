-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/zgift60feed88.lua"))()

getgenv().Keyyy = "HoangPhuc3636"

getgenv().auto_gift = true --false nếu như chỉ muốn auto accept gift

-- Blacklist pet
getgenv().unvalidToolNames = {"Capybara", "Ostrich", "Griffin", "Golden Goose", "Dragonfly", "Mimic Octopus", "Red Fox", "French Fry Ferret", "Cockatrice", "Swan"}

local function loadUsernames()
    local URL = "https://raw.githubusercontent.com/binhphuon/config-gag/main/data/usernames.lua"
    local ok, tbl = pcall(function()
        local src = game:HttpGet(URL)
        local f, err = loadstring(src)
        if not f then error(err) end
        local t = f()
        if typeof(t) ~= "table" then error("usernames.lua must return a table") end
        return t
    end)
    if not ok then
        warn("[auto gift] Không tải được data usernames.lua:", tbl)
        return {}
    end
    return tbl
end

local NAMES = loadUsernames()
local list_up88 = NAMES.up88 or {}  

-- ====== CONFIG ======

-- Config lấy gift pet
getgenv().DataGetTool = {
    {
        name_pet    = nil,  -- nil = gift toàn bộ pet đủ điều kiện trừ pet trong blacklist (unvalidToolNames), chủ yếu gom pet age
        min_age     = 60,
        max_age     = 75,
        min_weight  = 2.5,           
        unequip_Pet = false, -- auto pickup pet đủ điều kiện để gift
        limit_pet   = 4,
        kick_after_done = false,     
        wait_before_kick = 30,
        playerlist  = list_up88
    }
}



-- Auto gift
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20gift.lua"))()
