-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20gift%20pet.lua"))()

getgenv().Keyyy = "HoangPhuc3636"

getgenv().auto_gift = true --false nếu như chỉ muốn auto accept gift

-- Blacklist pet
getgenv().unvalidToolNames = {"Capybara", "Ostrich", "Griffin", "Golden Goose", "Dragonfly", "Mimic Octopus", "Red Fox", "French Fry Ferret", "Cockatrice", "Swan"}

-- Config lấy gift pet
getgenv().DataGetTool = {
    {
        name_pet    = "Ostrich",  -- nil = gift toàn bộ pet đủ điều kiện trừ pet trong blacklist (unvalidToolNames), chủ yếu gom pet age
        min_age     = 1,
        max_age     = 101,
        min_weight  = 8.0,           
        unequip_Pet = true, -- auto pickup pet đủ điều kiện để gift
        playerlist  = {"XxTigerBlockxX87", "SABER_Ven0m47", "Gh0stDuckJelly", "XxV0rtex_Pr0xX2009", "LiamR0cketPh0enix", "Ultra_Ice43", "NoahVort3x2006", "Builder_Bane31", "Pho3nixSonic2002", "LuckyStreamPrimal202", "XxAbigailBanexX24", "Z00mEpicDrift", "SebastianStreamFrost", "Pho3nixStr3am2008", "Gh0stEch0V0rtex"}
    }
}

-- Auto accept gift, xóa nếu muốn
task.spawn(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20accept%20gift.lua"))()
end)

-- Auto gift
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20gift.lua"))()
