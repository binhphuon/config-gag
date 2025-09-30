-- Danh sách username cho sẵn
local allowedPlayers = {"TuminelloA6","lhtd132","viLu0ngNguyet","HVuFzJOTcG","zS74tmXNMx","FZhRg0l1rA","K8tMJXatb9","W2anqbNOg0","izOm85vQd1","VFTuiTN0R0","XxGlitchDuckxX28","LunaArrowFlam3","rkTZP7Kjbz","UKPG8MGvso","GiangKich2020","oisx77HPJ3","T9Eh2bFehe","YDKqzesD7x","YPEH5yjd2G","FsWy4CXrk9","Luna_Pulse96","FuryHawkAlpha2024","XxElijahCha0sRiftxX","Harper_King32","JaxonRiftZap2018","Ic3CircuitHaz3","XxLionHeroQueenxX","Levi_Ice18","XxMate0BuilderxXYT","Xx_DawnMasterThunder","StormyHazeNinja","HunterCookie202223","FlickCookieNeon","Wyatt_Glitch48","GamerIce2016_YT","XxBuilderSonicLegend","Chl0e_RIFT200227","WillowZeroVenom2017","Flick_Fury2017","Xx_EvelynBuilderGlit","RileyMinerPrism63","InfernoZoomBlade","IceAcePro2012","AsherGigaOmega","V0rtexR0gue2005","RileySkater202210","Linhkha2011","thi3n_tinh","lVkjTmR8tX","mxvIeqIJIN","Uy3ncuclac","oQEoiW4SOh","0oTxmHZ4OY","9N6lnndCj3","TheRealChamYeu2007","qOt8PlGTtV","CnFJwd5HQk","h7sNt0IXzb","T4IigEP8x1","hi2iNogg60","UMPeawaNJ9","04NobF9pxW","49JIoosOSw","LDO1o17ZTr","okJFAr9D23","zUUQNuXRVm","oElcPi3yUz","daVEcbnOr6","quanCongSen","gM2iD0wrrb","Bao_dungYT","XxBlock_FlashxX2003","Charl0tt3Arr0w27","XxZ00mIceRiftxX","DriftTiger202339","Glitch_Bac0n39","DawnLavaRocket","FlashKnightMax2013","Vip3r_QU33N201665","XxVortexIceDuckxX","XxPower_RocketxX2009","Gamer_TURBO2016","XxAva_C0dexX2018","CodeGolden23","PhoenixHeroPanda18","Gabri3lPho3nix2009","Sab3r_Dark2002","PhoenixViper87","XxMicha3lClawPrismxX","ZoomFlick88","AsherCircuitMystic","Slime_Panda85","Aqua_Fusi0n2009","StarBaconHawk","BlizzardCrazePlayz20","SavannahCyb3rBac0n","Eli_Craz359","LavaWraithGalaxy2002","XxJayd3nVip3rxX","SAVANNAH_Raven200968","XxFlickNe0nxX","NoraNovaDrift","XxEagl3Rid3rCrystalx","S0phia_Z00m2007","HannahBlizzardKnight","P0wer_Giga23","Turb0S0nicStealth202","PowerFrostTiger2011","M00nBeast11YT","Ice_Vortex18","Elli3Fr0stCraft2009","HenryCha0sPixel"}

local player = game.Players.LocalPlayer
local username = player.Name

-- Hàm kiểm tra có trong list không
local function isAllowed(name)
    for _, allowedName in ipairs(allowedPlayers) do
        if name == allowedName then
            return true
        end
    end
    return false
end

-- Kiểm tra và in kết quả
if isAllowed(username) then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/kaitun%20ostrich.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/kaitun%203nn.lua"))()
end
