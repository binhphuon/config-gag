--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/autobt.lua"))()
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 
getgenv().tmconfig = {
    key = "",
    team = "Pirates", -- "Pirates" "Marines"
    hpTimeout = 15,
    targetTimeout = 10,
    lowHealth = 4000,
    safeHealth = 4500,
    code = "",
    useSkill = false, -- only x f gas fruit
    equipPaleScarf = false,
    webhookurl = "",
    webhookEnable = false,
    webhookSendMinutes = 5,
    attackSpeed = 0.0001,
    mode = 2,
    fat = 10, -- 1 = normal UI, 10 = minimal UI 
    sea = 3,
    region = "Singapore",
    trans = false, -- auto press V t rex 
    bltween = true, 
    speedcf = 0.000000001, 
    bpsit = true, 
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kuro2112/sorip/refs/heads/main/supanika-obfuscated.lua"))()
