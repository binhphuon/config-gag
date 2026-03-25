repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().key = "PREMIUM-B8C34608"
getgenv().Config = {
    Team = "Marines",
    SelectStatstoadd = {"Melee", "Defense", "Sword"},
    MM = false, -- Valkyrie Helm and Mirror Fractal
    GetYama = true,
    GetTushita = true,
    FarmMasterySword = true,
    GetCDK = true,
    HopCastleRaid = true,
    GetSkullGuitar = true,
    BypassTeleport = true
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/hihiae/36var/refs/heads/main/djtconmemay.lua"))()
