-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/kaitun%203nn.lua"))()
-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local name   = player.Name

-- Bảng data mapping playerlist -> key
local DataKey = {
    {
        key        = "188afaa25b87293efdd96289",
        playerlist = {"238012ewitkhaha","427946tifkhaha","dott33041khaha","adolp009","TuminelloA6","lhtd132","viLu0ngNguyet","HVuFzJOTcG","zS74tmXNMx","FZhRg0l1rA","K8tMJXatb9","W2anqbNOg0","izOm85vQd1","VFTuiTN0R0","XxGlitchDuckxX28","LunaArrowFlam3","rkTZP7Kjbz","UKPG8MGvso","GiangKich2020","oisx77HPJ3","T9Eh2bFehe","YDKqzesD7x","YPEH5yjd2G","FsWy4CXrk9","Luna_Pulse96","FuryHawkAlpha2024","XxElijahCha0sRiftxX","Harper_King32","JaxonRiftZap2018","Ic3CircuitHaz3","XxLionHeroQueenxX","Levi_Ice18","XxMate0BuilderxXYT","Xx_DawnMasterThunder","StormyHazeNinja","HunterCookie202223","FlickCookieNeon","Wyatt_Glitch48","GamerIce2016_YT","XxBuilderSonicLegend","Chl0e_RIFT200227","WillowZeroVenom2017","Flick_Fury2017","Xx_EvelynBuilderGlit","RileyMinerPrism63","InfernoZoomBlade","IceAcePro2012","AsherGigaOmega","V0rtexR0gue2005","RileySkater202210"}
    },
    {
        key        = "643a49e3695603026d6d0c99",
        playerlist = {"Linhkha2011","thi3n_tinh","lVkjTmR8tX","mxvIeqIJIN","Uy3ncuclac","oQEoiW4SOh","0oTxmHZ4OY","9N6lnndCj3","TheRealChamYeu2007","qOt8PlGTtV","CnFJwd5HQk","h7sNt0IXzb","T4IigEP8x1","hi2iNogg60","UMPeawaNJ9","49JIoosOSw","04NobF9pxW","LDO1o17ZTr","okJFAr9D23","zUUQNuXRVm","oElcPi3yUz","quanCongSen","gM2iD0wrrb","daVEcbnOr6","Bao_dungYT","XxBlock_FlashxX2003","Charl0tt3Arr0w27","XxZ00mIceRiftxX","DriftTiger202339","Glitch_Bac0n39","DawnLavaRocket","FlashKnightMax2013","Vip3r_QU33N201665","XxVortexIceDuckxX","XxPower_RocketxX2009","Gamer_TURBO2016","XxAva_C0dexX2018","CodeGolden23","PhoenixHeroPanda18","Gabri3lPho3nix2009","Sab3r_Dark2002","PhoenixViper87","XxMicha3lClawPrismxX","ZoomFlick88","AsherCircuitMystic","Slime_Panda85","Aqua_Fusi0n2009","StarBaconHawk","BlizzardCrazePlayz20","SavannahCyb3rBac0n"}
    },
    {
        key        = "1a66548414f7a73c3ee4af16",
        playerlist = {"Eli_Craz359","LavaWraithGalaxy2002","XxJayd3nVip3rxX","SAVANNAH_Raven200968","XxFlickNe0nxX","NoraNovaDrift","XxEagl3Rid3rCrystalx","S0phia_Z00m2007","HannahBlizzardKnight","P0wer_Giga23","Turb0S0nicStealth202","PowerFrostTiger2011","M00nBeast11YT","Ice_Vortex18","Elli3Fr0stCraft2009","HenryCha0sPixel","IsabellaBlade97","Om3ga_King2017","SparkDriftCyber20197","MagicIceAce","William_B3AST200348","GoldenVoidKnight2003","MaxLegendMagic2004","JackVenomPulse","VoidTurboMast3r","Pow3rSab3r2021","EchoGigaTurbo2005","HannahStarryBacon","XxFusionPulseSkaterx","Xx_PaisleyJellyInfer","JAX0N_Li0n68","EliFrost201227","XXOLIVER_BlastxX42","OliviaZoomBeast","ProDrift200322","G0LDEN_Builder28","Bl0ckH3r0Prism","DancerToxicBlaze","Om3gaQu33n30","GamerSkyP0wer2002","PixelNinja201874","XxBrooklynByteLightx","Eli_Flash17","R0gue_Flick2013","AubreyMasterNinja201","RavenTurboLava2011","GamerMagicBane2021","DancerNinja82","XxPowerWolfxX73","Hunt3rGalaxyStormy10","HyperGolden200635"}
    },
    {
        key        = "07b2b8e74b6f4592baea1c12",
        playerlist = {"ThunderZeroCode2023","UltraG0ldenBeast","MasonRider27","Henry_W0LF2017","G0lden_Panda2008","HunterAlphaVortex","Fusi0nSt0rmy2004","BYT3_Hawk2011","Golden_Chill80","XxDragonBeastxX2022","Void_Galaxy2008","XxHazeIcexX2014","XxWraithLuckyRocketx","Carter_Pulse87","CIRCUIT_Flick2008","FusionHaze75","HeroBlastQueen2023","Craze_Light36","ProRiderBlast","FlickChaosBlizzard","FoxFury72","GraysonSparkly70","Lucky_P0WER16","CraftBl0ckBuild3r","Amelia_Orbit69","EllieCodeHawk","XxMat3oDanc3rZ3roxX","PixelPanda200924","XxMoonQu33nxX2002","PixelHyper33","FuryMaster200412","Qu33nMast3rPix3lat3d","Xx_AddisonUltraSaber","XxGhostGamerEchoxX20","BlizzardRaven2022","AceMysticNinja200967","XxLightRogu3xXYT","GabrielClawLight2015","CrazeBlastPulse54","C0deSlimeNe0n202496","RiderSpark2019YT","HawkSparkly22","Danc3rMax32","PulseBeastBlizzard60","EchoAquaSilv3r","XxBrooklynChaseMysti","DarkNeonBuilder2020","VictoriaStreamFury","Bac0nBlaze2018","Byt3Ban3Wraith2002","XxMasterOrbitxX65"}
    },
    {
        key        = "e699665474fd83c8cd85dc23",
        playerlist = {"GhostRogueGlitch2024","DancerKingIce","PixelMoonSilver20028","XX_BrooklynnHazeFlas","EzraBlastLegend","ElijahGalaxyMagic201","Charl0tt3_Ac32022","SlimePowerPixel","ChaseFlickHaze","Ik6rbevBPQ","shutcutch4","sharibrodellr0","rip_miklaskynhe","prussellbarreykhaha","BUqq8d9Jzy","ZSy6ZY89ug","kQo58l0BOW","Wpdn8tMh72","bY5OCxYtse","ojEzP4twfV","k6OFwkQlJv","jtWXigxDtS","FGzNCe2Fnl","rAw26wJ3wc","JSR5B7fpG6","lTiiBV9GjY","SdTAbeYiQp","aMKCOT1kNM","HZlC6a80cP","DriftGamerRadiant","Q1mn6c4TXy","SQqfAhTOFv","IplSGgZoUL","yJCMsd5xr0","Gg74NnOssZ","cj70oFRzOy","8mMvrF03BD","JFJNoxXVyT","8Dr4znrqq6","qHc7M8QCST","kCSi5mPdmJ","jw3Og4wq70","EYJPNxXcQS","KqicKWZXnL","ecLNxYEWsk","mqOLkYUp5s","nrUgHTM1d4","yDDUntDQXD","1JPfmkTBLq","eWN2SoAHsI"}
    },
    {
        key        = "2af5b4611186ad29c095777b",
        playerlist = {"KZZiiUzWLT","0OT0L9BflO","LlG01tCTRB","b15sd50qCR","aPLD23Fqxs","r0GQbBdN0y","ZdRoDhZdHq","sxoSYG94uH","VksQDcbHjs","TRVSbPT1Gf","MK19ijsCgo","CITzdFgHr7","01eAdVcBpa","LAlRqPPbpl","e783KrVq3X","hAIsLUYRQQ","forestcorw6","lhtd133","lhtd135","lhtd136","EDk1x0XQBl","NovaFlashCookie","MrsHang_Dung2020","SEEONeoweP","mAv7BAn0gj","tq2cMXEind","RJJHzcMyDb","ZrteXioWpd","wlqTULfZut","FLYVFpD9Jp","0VFsrGlRKl","Nexuslamtan2006","yKlgUq5aOd","xHBlxrhivC","Nguphugiap","gEVjYFM7pm","dinhnhan200442","FlickDragon200726","vanJiWuFIe","KYkq9cAJRm"}
    }
}

-- Hàm check tên có trong list không
local function inList(n, list)
    for _, v in ipairs(list) do
        if v == n then
            return true
        end
    end
    return false
end

-- Gán Key
for _, data in ipairs(DataKey) do
    if inList(name, data.playerlist) then
        getgenv().Key = data.key
        break
    end
end

-- Nếu không có thì set mặc định
if not getgenv().Key then
    getgenv().Key = "default_key"
end

print("Tên:", name, "=> Key:", getgenv().Key)

getgenv().Config = {
	["Select Pet Gift"] = {

	},
	["Select Pet Dont Delete"] = {
		["Brontosaurus"] = true,
		["Blood Owl"] = true,
		["Moon Cat"] = true,
		["T-rex"] = true,
		["French Fry Ferret"] = true,
		["Honey Bee"] = true,
		["Capybara"] = true,
		["Dilophosaurus"] = true,
		["Red Fox"] = true,
		["Fennec Fox"] = true,
		["Corrupted Kitsune"] = true,
		["Mimic Octopus"] = true,
		["Kitsune"] = true,
		["Chicken Zombie"] = true,
		["Spinosaurus"] = true,
		["Disco Bee"] = true,
		["Queen Bee"] = true,
		["Butterfly"] = true,
		["Dragonfly"] = true,
		["Raccoon"] = true,
		["Dog"] = true,
		["Echo Frog"] = true,
		["Starfish"] = true,
		["Night Owl"] = true,
		["Ostrich"] = true,
		["Peacock"] = true,
		["Scarlet Macaw"] = true,
		["Bunny"] = true,
		["Golden Lab"] = true
	},
	["Auto Rejoin"] = false,
	["Auto Cook Custom"] = false,
	["Auto Cook based on the Food requested by the NPC"] = true,
	["Use Save Position"] = true,
	["Auto Quest Prehistoric"] = false,
	["Select Rarity Pet Give Dinosaur"] = {
		["Rare"] = true
	},
	["Select Item Shop Merchant"] = {
		["Iconic Gnome Crate"] = true,
		["Sugar Apple"] = true,
		["Night Staff"] = true,
		["Kiwi Seed"] = true,
		["Bell Pepper Seed"] = true,
		["Pitcher Plant"] = true,
		["Classic Gnome Crate"] = true,
		["Bee Egg"] = true,
		["Avocado Seed"] = true,
		["Green Apple Seed"] = true,
		["Banana Seed"] = true,
		["Mutation Spray Verdant"] = true,
		["Common Gnome Crate"] = true,
		["Flower Seed Pack"] = true,
		["Mutation Spray Windstruck"] = true,
		["Pear Seed"] = true,
		["Mutation Spray Wet"] = true,
		["Feijoa Seed"] = true,
		["Loquat Seed"] = true,
		["Cantaloupe Seed"] = true,
		["Pineapple Seed"] = true,
		["Honey Sprinkler"] = true,
		["Prickly Pear Seed"] = true,
		["Mutation Spray Cloudtouched"] = true,
		["Star Caller"] = true,
		["Watermelon seed"] = true,
		["Farmers Gnome Crate"] = true
	},
	["Amount Set Idle"] = 100,
	["ESP Farm Player Other"] = false,
	["Save Position"] = {
		[1] = -21.071319580078125,
		[2] = -47.994476318359375,
		[3] = 0.3135833740234375
	},
	["Start ESP EGG"] = false,
	["Auto Load Script"] = true,
	["Auto Delete Sprinkler"] = false,
	["Auto Collect Egg"] = true,
	["Select Gear Use"] = "Godly Sprinkler",
	["Auto Delete Plant"] = true,
	["Start Boost"] = false,
	["Auto Buy Egg"] = true,
	["Auto Delete Fruit"] = false,
	["Auto Craft"] = false,
	["Auto Sell"] = true,
	["Boost Fps"] = true,
	["Select Egg Plant"] = {
		["Bug Egg"] = true,
		["Common Summer Egg"] = true,
		["Dinosaur Egg"] = true,
		["Paradise Egg"] = true,
		["Gourmet Egg"] = true,
		["Primal Egg"] = true,
		["Night Egg"] = true,
		["Zen Egg"] = true,
		["Fall Egg"] = true,
		["Enchanted Egg"] = true,
		["Sprout Egg"] = true,
		["Gourmet Egg"] = true,
		["Anti Bee Egg"] = true
	},
	["Auto Delete Pet"] = false,
	["Webhook Profile"] = false,
	["Buy All Seed"] = true,
	["Auto Mutation Pet"] = false,
	["Auto Plant Egg"] = true,
	["Time Delay Set Idle"] = 0.1,
	["Auto Give Pollinated For Onett"] = true,
	["Select Sprinkler Delete"] = {
		["Godly Sprinkler"] = true
	},
	["Auto Plant Seed"] = false,
	["Ping Discord"] = false,
	["Delete Notification"] = false,
	["Select UUID Pet"] = {},
	["Auto Collect"] = false,
	["Auto Set Idle Pet"] = true,
	["Auto Gift"] = false,
	["Auto Buy Shop Honey"] = true,
	["Auto Buy Gear"] = true,
	["Auto Accept Gift"] = true,
	["Buy All Gear"] = true,
	["Fix Auto Gift In Delta"] = false,
	["Select Seed Plant"] = {
		["Pumpkin Seed"] = true,
		["Beanstalk Seed"] = true
	},
	["Auto Use Gear"] = true,
	["Spam Join"] = false,
	["Start ESP"] = true,
	["Time Delay Gift"] = 1,
	["Webhook Collect Egg"] = true,
	["Auto Buy Shop Merchant"] = true,
	["Input Url Webhook"] = "https://discord.com/api/webhooks/1389864976491221064/lyhW_TJiq1-r_wJxqgGwJdipIKrA5e5s676YDzDpZps23MwX5FdSU-am3hVPJIzxF_nY",
	["Auto Buy Seed"] = true,
	["Ignore Variant or Mutation"] = false,
	["Auto Use Boost XP Or Boost Passive Pet"] = true,
	["Boost FPS"] = true,
	["Input Slot Sell"] = 199,
	["Auto Feed Pet"] = true,
	["Select Name Plant Delete"] = {
		["Tomato"] = true,
		["Bamboo"] = true,
["Coconut"] = true,
["Mushroom"] = true,
["Glowthorn"] = true,
["Tomato"] = true,
["Pumpkin"] = true,
["Pepper"] = true,
["Cacao"] = true,
["Apple"] = true,
["Romanesco"] = true,
["Elder Strawberry"] = true,
["Burning Bud"] = true,
["Giant Pinecone"] = true,
["Corn"] = true,
["Sugar Apple"] = true,
["Ember Lily"] = true,
["Dragon Fruit"] = true,
["Sunbulb"] = true,
["Orange Tulip"] = true,
["Blueberry"] = true,
["Watermelon"] = true,
["Mango"] = true,
["Cactus"] = true,
["Strawberry"] = true,
["Beanstalk"] = true,
["Lightshoot"] = true,
["Grape"] = true,
["Daffodil"] = true
	},
	["Buy All Egg"] = true,
	["Auto Collect Pollinated if Have"] = true,
	["Select Item Shop Honey"] = {
		["Flower Seed Pack"] = true,
		["Bee Egg"] = true
	},
	["Auto Stack Idle Pet"] = false,
	["Save Position Plant Seed"] = {
		[1] = -21.62548828125,
		[2] = -47.994476318359375,
		[3] = -5.645530700683594
	}
}

-- Load script chính
loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
