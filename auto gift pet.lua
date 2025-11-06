-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20gift%20pet.lua"))()

getgenv().Keyyy = "HoangPhuc3636"
getgenv().auto_gift = true -- false nếu chỉ muốn auto accept gift

-- Blacklist pet
getgenv().unvalidToolNames = {
    "Capybara","Ostrich","Griffin","Golden Goose","Dragonfly",
    "Mimic Octopus","Red Fox","French Fry Ferret","Cockatrice","Swan"
}

-- ===== Load data usernames (gom60, gom75) từ repo =====
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
local list_gom60 = NAMES.gom60 or {}  -- danh sách cho block 1
local list_gom75 = NAMES.gom75 or {}  -- danh sách cho block 2

-- ===== Config lấy gift pet (playerlist lấy từ data) =====
getgenv().DataGetTool = {
    {
        name_pet    = nil,      -- nil = gift toàn bộ pet đủ điều kiện trừ blacklist
        min_age     = 60,
        max_age     = 75,
        min_weight  = 2.5,
        unequip_Pet = false,    -- auto pickup pet đủ điều kiện để gift
        limit_pet   = 999,
        kick_after_done = false,
        wait_before_kick = 30,
        playerlist  = list_gom60, -- <== load từ data/gom60
    },
    {
        name_pet    = nil,
        min_age     = 75,
        max_age     = 101,
        min_weight  = 2.5,
        unequip_Pet = false,
        limit_pet   = 999,
        kick_after_done = false,
        wait_before_kick = 30,
        playerlist  = list_gom75, -- <== load từ data/gom75
    }
}

-- Auto accept gift (xoá nếu không cần)
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20accept%20gift.lua"))()
end)

-- Auto gift
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20gift.lua"))()
