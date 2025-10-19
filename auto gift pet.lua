-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20gift%20pet.lua"))()

getgenv().Keyyy = "IronWolf89"

getgenv().auto_gift = true --false nếu như chỉ muốn auto accept gift

-- Blacklist pet
getgenv().unvalidToolNames = {"Capybara", "Ostrich", "Griffin", "Golden Goose", "Dragonfly", "Mimic Octopus", "Red Fox", "French Fry Ferret", "Cockatrice", "Swan"}

-- Config lấy gift pet
getgenv().DataGetTool = {
    {
        name_pet    = nil,  -- nil = gift toàn bộ pet đủ điều kiện trừ pet trong blacklist (unvalidToolNames), chủ yếu gom pet age
        min_age     = 75,
        max_age     = 101,
        min_weight  = 0.5,           
        unequip_Pet = true, -- auto pickup pet đủ điều kiện để gift
        playerlist  = {"gNxZYWKcDk","fJioQJz3fD","q7VBh0a3yM","80Cp6zIADs","ihJgB9QpN5","p4QVKsgr2t","CYEpZ2F1Dm","40EvQKGAQC","sKjCFYQIAz","FEqOupbhnE","nqTf8zG22g","I9KtJDoCVw","boNEAvjCns","tXB8UYj2HD","x2EG3MA8GX","UWYQhUWEl0","pjUbxLrCnC","KDfbYCWwjq","rKfKXMXyhW","u1JXqn6pP7","VTV624wc4h","pQ8cKG22pI","TLSIHFD37w","0zwALumNsn","49Dgl5TQol","1xsDWzdrAc","IkC7xn2kPP","mhiU9prQSU","ATNO7MY42U","xd7ilcLA4H","b6GFPv1dzE","5dP9kocL1c","PnLvBlvvZX","bfcHYyaujW","447sAUZjWf","tuXbojE58Z","vnqDQdPP6G","PPCncRAXg5","dgMH8C3gac","oADUJT2lDs","3dmkqUM2hN","oCpogGFnwE","yPvxfMhuND","vF7XS2IvNJ","VSs3BOKW0M","0l5O2Hp8pu","gNwAs6rM0t","23PKs7SRJ7","eEYjgkNYJf","CIl4vwVVgp","WNdhbSpFoR","A3ocUJ7Owa","Eyrxz4u17C","ETBDKdqKzf","EdyrsXWReC","wIsk4FiIDm","9ob8qBPPlC","AluiFqmdoJ","ybXVVl9CNF","ww13oqMCTm","JdE0VxpBX7","R5ZlkNhtam","h2oKsFUfYB","tVGxGF98lx","W92MbGaHsk","5M37WnJ2WS","s44geJGVco","5WczFAfzrA","Tp02BtDt98","Kyepud7pif","JzH8IhN24k","Ohl47nJ1Ev","v4RrPhrXy4","vfZVUxPvnK","sG4zo4DBmO","1PP9wDyi0I","cZpUdW0yMx","2MeGahYErL","U28CWCq7nP","I6vcZPlVFW","StormyCrystalCyber20","XxKingNinjaxX200278","Zo3Void2024","VoidHunterStorm2014","Owen_Skater200392","BaneBlazeStarry","XxAlpha_SkaterxX32","PaisleyPlayz15","HyperFlick12","BlazeQueenPhoenix200","SilverThunderStarry2","LoganBan3Drift","5XnjtHA3Ii","XxLaylaRiftxX40","Al3xand3rWraithH3ro9","RileyPlayzCrystal200","EliShadow91","XxMiaDawnLuckyxX2017","Builder_Dawn12","Thund3rEch02023","RiftStorm10","NoraDragonBeast84","NightGalaxyHaz32006","Ethan_Light200756","XxFr0stBlastC00kiexX","XxBaneHawkxX2002","DawnStealthPanda2019","Vortex_CRAZE38","L3g3ndFox37","CrazeZero96","Ph0enixC0dePixel","Oliv3rPix3lB3ast","Xx_FusionNeonInferno","RiftBlizzardMystic20","NightCyb3r64","JackPuls374","LionSkyEcho_YT","PixelHunterBear2019","FrostGolden201293","StreamTiger2022_YT","CharlotteStormLion95","LunaCircuitHawk"}
    }
}

-- Auto accept gift, xóa nếu muốn
task.spawn(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20accept%20gift.lua"))()
end)

-- Auto gift
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20gift.lua"))()
