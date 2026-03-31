--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/kt%20mck.lua"))()
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
task.wait(10)
task.spawn(function()
    while true do
        getgenv().key = "PREMIUM-ED76FE0C"
        getgenv().Config = {
            Team = "Pirates",
            SelectStatstoadd = {"Melee", "Defense", "Sword"},
            MM = false,
            GetYama = true,
            GetTushita = true,
            FarmMasterySword = true,
            GetCDK = true,
            HopCastleRaid = true,
            GetSkullGuitar = true,
            BypassTeleport = true
        }
        task.wait(10)
    end
end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/hihiae/36var/refs/heads/main/djtconmemay.lua"))()
