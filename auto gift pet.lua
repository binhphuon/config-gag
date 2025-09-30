getgenv().Keyyy = "NovaQ47"

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
        playerlist  = {"BP_Gamer03","P9KNyW2pTn","iR93bNRx4o","6OI27mjma9","9lw1GOpG54","2apk0x7YZQ","0iZThGQHUr","FunudYIPM1","iIwiWNIT1j","Mm0prSn0Ln","uBDa4ezDEc","FREsJ2tQSC","G3xnk0zsM9","FTURs1BefP","jHVDoRjefG","lBopwGiXnD","86IcvBKiv9","DomuPd8uk9","eO4Ii9ZRBT","iYBM4bxQcC","77QXdLAylg","xZvEjRSQFT","qqAkU7P2uC","1BzygrFssA","ySi9xb9fkT","Orj0jEzFCb","syL3qJoFjx","Q5gNGlbCN5","6DEhjhYoR2","I04khE8tmy","BFx61ZnHgY","Yif7mxwNjs","8VyEM2nTLa","RDLuBk1PH9","qOi2ILl7xD","KtPb2z3Pa9","kLAZCYlXRZ","wqLlMsG4Be","tvuY4pqFW2","IhduOG5qE4","KthymSDee0","oNMq8XpCJx","5Zc62HVl6c","OKoYkctAu9","h163vUuuoe","6vRKYypAFc","2bRZQGCIV9","UBaRRiZcK3","AHMTsSwB1j","1Q25OBeoCz","Oekb28eLP0","yvhwaZVWZJ","MLqrDSDOw4","TdBl6ZjTlO","mtzEejfu44","hhAeXQHzdA","RpG1Oj1ENZ","oOkeJN9s6L","gNxZYWKcDk","fJioQJz3fD","q7VBh0a3yM","80Cp6zIADs","ihJgB9QpN5","p4QVKsgr2t","CYEpZ2F1Dm","40EvQKGAQC","sKjCFYQIAz","FEqOupbhnE","nqTf8zG22g","I9KtJDoCVw","boNEAvjCns","tXB8UYj2HD","x2EG3MA8GX","UWYQhUWEl0","pjUbxLrCnC","KDfbYCWwjq","rKfKXMXyhW","u1JXqn6pP7","VTV624wc4h","pQ8cKG22pI","TLSIHFD37w","0zwALumNsn","49Dgl5TQol","1xsDWzdrAc","IkC7xn2kPP","mhiU9prQSU","ATNO7MY42U","xd7ilcLA4H","b6GFPv1dzE","5dP9kocL1c","PnLvBlvvZX","bfcHYyaujW","447sAUZjWf","tuXbojE58Z","vnqDQdPP6G","PPCncRAXg5","dgMH8C3gac","oADUJT2lDs","3dmkqUM2hN","oCpogGFnwE","yPvxfMhuND","vF7XS2IvNJ","VSs3BOKW0M","0l5O2Hp8pu","gNwAs6rM0t","23PKs7SRJ7","eEYjgkNYJf","CIl4vwVVgp","WNdhbSpFoR","A3ocUJ7Owa","Eyrxz4u17C","ETBDKdqKzf","EdyrsXWReC","wIsk4FiIDm","9ob8qBPPlC","AluiFqmdoJ","ybXVVl9CNF","ww13oqMCTm","JdE0VxpBX7","R5ZlkNhtam","h2oKsFUfYB","tVGxGF98lx","W92MbGaHsk","5M37WnJ2WS","s44geJGVco","5WczFAfzrA","Tp02BtDt98","Kyepud7pif","JzH8IhN24k","Ohl47nJ1Ev","v4RrPhrXy4","vfZVUxPvnK","sG4zo4DBmO","1PP9wDyi0I","cZpUdW0yMx","2MeGahYErL","U28CWCq7nP","I6vcZPlVFW"} -- Những acc sẽ được gift loại pet này, thêm bao nhiêu cũng được
    },
    {
        name_pet    = nil, 
        min_age     = 60,
        max_age     = 75,
        min_weight  = 0.5,           
        unequip_Pet = false,
        playerlist  = {"PvlHlzXO7W","34xUe2sv2a","AkNPzWkKot","0GfYkEI72M","MMuFDpTGCq","wJ61jrPqJm","T7ufqxfu81","51rtzLU5jE","wGBoblzy4k","gUnRsTvse1","y334PUOolC","6yuCaUqaKz","5XnjtHA3Ii","BP38uKSb1F","MWGG4VaCZw","Zq8tVqFKHZ","T7uEtOQ6nF","NtiyudRdP6","XxLaylaRiftxX40","XxZoomStarryCraz3xX","DawnDarkWolf201429","MiaSparkGamer","BlazeGamerCrystalYT","CircuitMagic15","FlickFoxAce","Haz3Danc3rEpic2023","XXICE_FuryxX45","AriaRocketFlash","Aid3nPix3l84_YT","RileyPlayzCrystal200","EvelynStarCookie","DawnOrbitStream20061","XxMaxVoidxX22","XxToxicSlimeStormxX2","EmmaBacon59","Grays0nKnightS0nic","XxSkaterF0xAcexX","CrystalMasterPrimal2","JaydenR0cketEch0","BaconMoon70","AriaTig3rSkat3r","EagleStream202045","Gabri3lCraz3Chas3202","LoganHawkGlitch","OwenViperLegend","XxVictoriaMagicDawnx","XxAmeliaDancerxX19","ULTRADANC3R2022_YT","ZoomMoon2006_YT","HazeStormy2012YT","LeviFusion20YT","MoonBlockCookie20119","Scarlett_Master73","LightShadowGalaxy92","Skat3rFlick2024","N0ahFr0stSparkly","Grayson_Playz49","TurboSkyChaos16","DuckNovaFusion","BanePlayz200646","XxLeviPulseHunterxX","ShadowEpicStormy","LoganBan3Drift","XxJaydenThunderFoxxX","XX_LuckyThund3rOrbit","Galaxy_Pixelated90","XxSonic_SilverxX2020","XX_WilliamCraftOmega","HazeLuckyPhoenix","RocketNinjaTurbo2014","JackPuls374","WraithL3g3ndGalaxy20","IceWolfSaber_YT","XxLionDuckArrowxX201","ROGU3_Light14","XxEv3lynZoomRiftxX","XxDuckMasterxX99","MysticV0rtex92","V0rtex_Blast2006YT","XxAidenStormyxX2015","ToxicMin3rGold3nYT","EliShadow91","XxMiaDawnLuckyxX2017","Builder_Dawn12","XxLavaVoidxX55","JacksonQu33nV3nom65","WolfBlad3Lucky","IceLuckyPrism","StreamLionLucky","Xx_Danc3rSparklyPix3","LionHero201519","FrostStormQueen","HazelPowerCookie","QueenPrismNe0n","NinjaInf3rn0Flash","XxFlashBanexX54","XxElli3SonicChaosxX","C00kieStreamPulse","AddisonBlaze29","FoxAquaHunter2003","GamerMysticNova2019","Al3xand3rWraithH3ro9","AsherPrimal91","Addis0nInf3rn02003","GlitchCyber24","PixelGhost200852","MysticDawn73","Abigail_Duck52","JellyLavaPixel52","XxPrimalV3n0mPh03nix","Fusi0nLight51","BuilderUltra85YT","Ven0mArr0wPr0202426","Rid3rSparklyNova_YT","Flame_Claw2012","Pix3lBlizzardDark201","DuckBlastFr0st2019","C00ki3Ninja89","Sonic_Stream200615","XxBrooklynnZapxX2003","JacksonRavenCraze200","PowerVoidHaze","BuilderMysticSky2014","PHO3NIX_Turbo200986","XxNoahCircuitByt3xX2","EmmaRocketLuckyYT","Xx_AlexanderGamerBac","Bl0ck_RAVEN79","XxAid3nRav3nxX35","DriftTigerMagic35","VoidFlick201685","Bac0nKnight83","XxBladeMasterGlitchx","Xx_AlphaPixelatedFla","BrooklynDriftSaber20","StormyCrystalCyber20","XxKingNinjaxX200278","Zo3Void2024","LionSkyEcho_YT","PixelHunterBear2019","FrostGolden201293","StreamTiger2022_YT","CharlotteStormLion95","LunaCircuitHawk","Thund3rEch02023","RiftStorm10","NoraDragonBeast84","NightGalaxyHaz32006","Ethan_Light200756","XxFr0stBlastC00kiexX","XxBaneHawkxX2002","DawnStealthPanda2019","Vortex_CRAZE38","L3g3ndFox37","CrazeZero96","Ph0enixC0dePixel","Oliv3rPix3lB3ast","Xx_FusionNeonInferno","RiftBlizzardMystic20","NightCyb3r64","VoidHunterStorm2014","Owen_Skater200392","BaneBlazeStarry","XxAlpha_SkaterxX32","PaisleyPlayz15","HyperFlick12","BlazeQueenPhoenix200","SilverThunderStarry2"}
    },
    {
        name_pet    = "Dragonfly", 
        min_age     = 1,
        max_age     = 100,
        min_weight  = 0.5,           
        unequip_Pet = true,
        playerlist  = {"DzHDV6hbZk","jbVQQmEb0P"}
    },
    {
        name_pet    = "Swan", 
        min_age     = 1,
        max_age     = 100,
        min_weight  = 0.5,           
        unequip_Pet = true,
        playerlist  = {"KxhDm2IHSY","oZtVWVRx1G","ea5c8p6Z6e","V9zP9wzkMp"}
    },
    {
        name_pet    = "Cockatrice", 
        min_age     = 1,
        max_age     = 100,
        min_weight  = 0.5,           
        unequip_Pet = true,
        playerlist  = {"7nn8GTpcoL","VmHEFQI1zk","FWKFFdXHtm"}
    },
    {
        name_pet    = "Golden Goose", 
        min_age     = 1,
        max_age     = 100,
        min_weight  = 0.5,           
        unequip_Pet = true,
        playerlist  = {"y6UUgOnClg","BGLZCHMu3Y","fc3dH7Jf43"}
    },
    {
        name_pet    = "Griffin", 
        min_age     = 1,
        max_age     = 100,
        min_weight  = 0.5,           
        unequip_Pet = true,
        playerlist  = {"GoWR7t32Mw","v3ABnWz2m9","OPVhlC5cLa","ypbuGS33vd"}
    },
    {
        name_pet    = "Red Fox", 
        min_age     = 1,
        max_age     = 100,
        min_weight  = 0.5,           
        unequip_Pet = true,
        playerlist  = {"rqiSun9OAi","2soU1WB3dD"}
    }
}

-- Auto accept gift, xóa nếu muốn
task.spawn(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20accept%20gift.lua"))()
end)

-- Auto gift
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20gift.lua"))()
