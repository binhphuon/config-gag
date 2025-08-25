-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services và Player
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer

-- Load các module
local GetFarm      = require(ReplicatedStore.Modules.GetFarm)
local Manhattan2D  = require(ReplicatedStore.Code.Manhattan2D)
local PetsService  = require(ReplicatedStore.Modules.PetServices.PetsService)

-- Danh sách các players cho các nhóm tuổi
local allowedPlayersStarfishs = { "ItsglowAlpha2019","ninaBuilderBlade","Th3R3alMik3Titan2007","ITSNORA_Omega","J0siah_Radiant23","ItsGraceTwistMoonbea","taradriftOrbitz","Nexuszoe_plume","NexusgaryZ00mj0lt","ItsKarasparkle64","TheRealLaylaSpecter","ItsKayleeSky","Levi_HICCUP2002","NexusMila_HYPER","EvanStar83","Violet_Flame73","EmilyN3on","EmilyNexusGhost","MrsTwilightInf3rno","NexusJames_SHADY2020","Th3R3alianCod3","ITSSAM_Wraith","FireCrystalCactus","TheRealJackson_Dusk","IsaacFlame98","MrsdreamJelly2006","NexusIsabella_RIDGE","MrsGinaCrystal","QuasarStream","MRSSTARRY_Sorcerer","ItsB3llaQuasarsunny2","GregSt0rmy2012","Vict0ria_Arr0w2011","TheRealAddisonJester","B3ar_shady","EliGr0v32005_YT","Itsl3oVaporTig3r","TheRealhughdreamSkat","MrsKylieHearthhaze20","Ril3y_J3ST3R","ETHAN_sand2013","TheRealTinaSpiritSli","TheRealvale_Wolf","MrsAubreydawn2023","ItsMilaLight2004","Th3R3alMason_Zigzag","Jake_HAZE202167","Ward3nTurb0gl0w2023","StormsproutMoonbeam","TomGhost2019","SarahWizard29","Glider_Mystic","JaydenRumbleSigma","Zayd3nSpirit","TheRealMadisonGhostY","N3xuszo3plum3nook","DriftVoidHunter","reef_Max","ninareefHero2022","Henrymist74","ItsSavannahTinkerGau","h3l3n_Z3ST","TheRealZaydenSkaterD","BrooklynScorch65","NexusSkater_LUCKY","ChloetwistStorm","ITSEVELYN_dream2019","Itshush_Moonbeam","NickVectorEagle2007","kyleSorcererDusk","ScarlettAuroraIvory","TheRealZephyrQuackYT","Itsclair3Ac32005","Itssplashflake","Sparksnack2016","ruth_Echo2020","Hunt3r_candy","ItsdanaBlizzardknoll","NexusThomas_Pulse51","TheRealmirthHalo62","Haz3lzippy2018","andyHunterwhisper200","NexusAvaGlitch","Grace_Dusk202299","NoraPrismXenon","TheRealDawnsunnyHero","EthanWave2024","NexusEllaFlick","w3ndySunris3","ThomasChillDark","SebastiansplashLoom","driftfizzl3","ItsChristopherVaporC","TheRealFrostVoid69","TheRealJill_Miner","NexusCarter_zest","EvanCometDrake2012","PetterZephyr2014","ItsProKaleido","FoxshadyQueen2016","MrsEllieChill","ItsIsabellaZap","JackNebulaSky202418","WILL_Fable2002","IslaOrbit2019","J0hnQuack","MrsComet_Moonbeam","Itszippy_MISTY","KylieBane2016","NexusClaraBeast","Harry_hush70","TheRealJakeNebulaCha","MrsAvery_Prism2011","IslaLegendAqua","TheRealfred_sparkle","OrbitzEmberYT","TheRealPeytongusty","ItsEdwardSpirit","Madis0nEch0201069","QuartzVibe74","LukeLoomYT","NEXUSDANA_Quest","ItsOblivionNight2023","AlphaGaug3","Tangle_Gauge49","ItsGinaBlastHawk","P3tt3rAc3","Henry_CATALYST2017","TheRealCrimson_Quest","TheRealOliviaScorch2","NexusJulia_Enigma39","hughnookTurbo","TheRealIanStream","MrsWilliamJade","ALAN_Stealth2017","NexusIsabellastone50","AndrewVoidOnyx","EdwardGobbleVibe","MrsgustyLuckynook201","gustyBanecloud2017","Aur0raTitan","ItsKatherinePhant0m","TheRealwill_Sunrise","TheRealAmaya_Rider","N3xusGlow_Haz3","CrimsonBane2023","WilliamSigmaKaleidoY","HarryHunterBlizzard2","Faith_SHADOW2004","Cosmo_BeastYT","cloudBearoak","Inkriver2008","hughCyber2021","Th3R3alCart3rIgnit3","GraceKiteAbyss","TheRealscottpawsGlow","NexusHarrysparkleCom","helenAquaFusion","DaveIv0ryRaven","RileyPulseLoom","ITSISAIAH_Turbo","NexusmaryKaleid0","Jill_Meteor77","Itsnatepaws","ElizabethAlphaStormy","ItsWillow_chime","Itslaura_Eagle","JackUltraGobble2007","Owen_Titan2017YT","MrsLevisplash32YT","TheRealThomas_chime","NexusHenryRaven","NexusDancerSilver11","N0ra_B3ast2005","TheRealZacharyTiger2","ScorchTitanGalaxy","DaveRavenIce","MrsRiftpawsHawk97_YT","BenStarlighttwist","TheRealEllaHalo2007","Mrstaraember","TheRealPetesparkle","MrsgraceTwilightThun","ITSSAMANTHA_Tangle20","Vort3xV3nom68","MrsZoe_sand","TinaFlareGlimmer","XeroLegendGrove2023","LuminosStormyflick","TheRealZayden_SHADOW","wendyYonderfizzle201","G3org3OrbitOpal2011","nateflick2015","QuackVectorzippy","TheRealNancyZephyrqu","NexusFlareHaze","garydreamCatalyst","EthanYonderQuartz","IanKnight28","ItsLeviFlicker","paul_Whisper36","Bella_Storm2019","ItsZayden_RADIANCE","ItsRadiantcandyBacon","ItsFireSurgeCosmo200","TheRealLunaFlame_YT","Sparkly_Titan","ScarlettTempestbloom","NexusSophia_twirl","Rosetwirl2003","andy_Radiance72","K3nN3on","RUMBLE_P0wer93","EzraSigmaChill","NexusOwenVenom","NexusBenEmerald","PlayzWill0wC0met43","KnacksplashGam3r","HollyDewEpic","vaporZap78","Kaylee_Paladin2021","EvanLusterSparkly","Ros3Glow39","ruthdreamCraft2022","SamFalcon13","ScorchInk","LeahParagon2006","MrsNathanChaseWhispe","NexusAddisonnook2012","MrsBellalake","TheRealOwenBlaze57","Ella_Glow33","TheRealSkylarZest","MILA_Neon2008","EvelynbubbleCactus","MrsRil3y_N3ON2016","Charles_Hero2004","TinaLegendYT","MrsSilverDawn","MrsTwilightMeteorRum","TheRealJoseph_Ultra","NexusChaosSurge2014","MrsmarkFlicker","chrisFlame201369","TheRealEmerald_Orbit","MRSELISE_Blaze","Moon_Noodle2003","ItsPeteVortex_YT","Itsshadeember201543","TheRealJamesBounce","ItsWolfflick","Gabriel_Hearth2006","PaisleyG0ldenTitan","MrsZachary_plume","THEREALDANA_Crystal2","BethXenonfrosty2019","NexusKenNinja2005","Th3R3alN3bulaStarry","NexusDew_Flicker2023","gl33_j3t","NexusChristopherbubb","FireL00m","MrssethByteQuartz","MrsZaydenC0met2007","JakeTalongleam","dreamG0bble","ItsSpecterTempest","TheRealEllaUmber","TheRealninaSapphire9","NexusNickAurora2022","NexusPaisleyBoulder2","rach3l_Zoom","LeviGlimmer2007","GraysonAquaPulseYT","AveryC0sm02010","ItsianMiner2003","ItsNibbleDrake","TheRealHarryNoodle69","FusionGamerFlick","MrsruthDawnDoodle","TheRealjack_Rift","Levi_th0rn","AbyssC0m3t","MrsEvanAlpha","ChillFizzy27","ItsNickf3rn","ItsFrankZeroash2020","KYL3_Flick2009","Th3R3albubbl3J3lly","ItsMaxLava45","LunaLusterMeadow","Ultraash76","ItsMilaDriftQuartz","TheRealruthbubble","NEXUSVIOLET_Chaos","NancyflickAqua","TheRealAuroraSizzle","TheRealadamSkater","MrsNibbleL00mst0ne20" }
local allowedPlayersAge20to30 = {"hM3k0MKDy7", "FDKvsFRyij", "1WrGPT99YZ", "lGN5HV0QRB", "RyWplxgwTF", "1LuKdYEXJj", "Z3HyDCmZ9e", "vSspBIeNHJ", "WJjYjRfnkQ", "WMZ1OD65K7", "K5vWsY3T3i", "MYcE9AeZjR", "1sfVp3BSp4", "WYelAHLDod", "On2xv7crL5", "bvh4Ezbz2o", "9DB1IpuODq", "ppyWlJrAfe", "C4M1DKJoJL", "mcZVNZYbDR", "ELLCUqli5E", "tS7i6Pc7pI", "ui5rWCH6GN", "UK0ySLbwZ8", "pLgQfcyTJS", "q0SgNQOJTk", "mbsR41zocp", "ruFv2yeI3x", "XbuOzhgpIW", "1rMnQDFIxX", "9pPiDbjusO", "D7GEIZuG2r", "QtVIMjVpec", "UDQKXEpX6N", "UEDEJJvUot", "mVARj4hNJ0", "XBmNvrKsyL"}
local allowedPlayersAge30to45 = {"PRXhixwCDI", "Zfe10TgPKW", "Bw8otUtRLl", "saAZkbeyCk", "fScGRKPwUG", "AtVY8wsUgP", "knaru5AWAs", "5UKL1EkSks", "vM9hPRnkzj", "5kolW3SWUr", "oHQIYCe7eP", "7Aa37sVTsu", "Dn9Ct0OAiL", "4RGfdYAltc", "b5PLbiqdJX", "XDca9fj1gC", "KDemIXsgNA", "TnyaJUVOte", "gTWtFbfidU", "J698IrGWV2", "TebpO8uCxk", "GoaRAHQfiW", "AIX1jNlnSo", "Cc3FyP0Enh", "lZp005RMti", "loWSSV04rk", "tGI7T9RFFZ", "ZOmCCAEXHK", "dfaY7tE76n", "zLIHqL7onc", "3lzjAmwJZ0", "VIi1Kl7xSk", "0jGILtD144", "4hPAPXYbcV", "iqJYlpVrf0", "57XSmISzxX", "j11I9eBaRp", "gsObh7uAyw", "dgdRNCpv5o", "k1pNz7AyuJ", "1FYGyyCWBm", "7McATQtIi1", "heAvEu2DvD", "fzIwnbE0pV", "9T0UmScG4q", "ZGscgiiVfT", "HZGWQpSDaT", "MZr6PvHtvN", "wBYM0PhmfY", "tZicPO0wDF", "93WjOJWvz0", "JQctJbM9yc", "YojN4Hldcc", "RuIsuT6vZw", "srdaQY9xFl", "eewtU59xwO", "KfstW25FVy", "MeBH9RTyPS", "5TBrsFw9y3", "nzPIHYpfEj", "vG7ZRMY6tG", "4bpdExTOm6", "rhjAZ1vgoG", "tLZsenRFbc", "1hye03zaEX", "fxfKG1oVGq", "kjubHCPNez", "Cz6vbsSJLy", "rtKKXFC37a", "yD2niHVsiq", "oOnHdWLSKc", "4I1XMLOw6X", "WUr8koRY9r", "jQe8Piczue", "W4IvJwrESv", "kru0qtzUet", "uALzoYmcnT", "2pYupwESAO", "74KzYidOk0", "fptTVJUK2q", "VrBEfY2x74", "bciJ5zU6d2", "8baWWXzqqP", "zxiDbYWBPO", "zpX0zIIxle", "AEOXWnbo1M", "FKQrKBmMxg", "jDLQJkhRqt", "H4jYw9Puns", "KGcf8Q1Yal", "HjCeyW4R2C", "i7TtRYzK0u", "OBCNnhTWva", "GEZ04VGlPU", "Cpi9ItMxhN", "t1Q5X6uH1C", "ZLBtBFHwlN", "KvCHw7D44i", "oIyCUSUh07", "CQzPWClDxL", "HsijrufGSL", "jRfIbhglpN", "2lDj2bzt8f", "X7scGQXxQx", "KGkR6UYJss", "vnaiHiDVML", "TcHNjTxKAF", "Ijvpt8UmVF", "IJkl3r7Iy2"}
local allowedPlayersAge45to60 = {"fHmRDxU2uD", "4j3AisiMiW", "k8cyvab2Zz", "AkOqxE06qU", "Lx5s9IAuHX", "t7jPIl8UNe", "kX1cW8BhRE", "aRqwkNpGSV", "KruFKmxIrK", "FDQr6sZ89s", "7LIJyDgLSe", "Ix27CDG5t8", "uSLXosRiud", "NEX6giptpK", "vlPqtHKQno", "TKQSCREhqw", "a8UmICaCFD", "zUFfhiLiQg", "tWsnWFZP6l", "FpvsR1ENu0", "V3r03hcdvL", "Sy7A3xtyAa", "7zPYdC31Kx", "6U2y2VMBor", "HkUyLc6DoH", "hB1he32z6a", "UzopT2l9ta", "2uDIG2gV10", "drwXomtHyY", "ljoQGdhbd3", "gkx6KI3myb", "tIEc9kk4ss", "gjegyy1G3R", "gUdH20fN25", "FHoZCA0v79", "2fgdqkEw3N", "s6XKtwTKGc", "HjUyNuWtHc", "g7uKQEdPy7", "AaZReYirbm", "rfMrLVZQ9U", "7EZgQmwBPE", "0tbABe930u", "Y8VEXrkrbi", "njGN2TP47X", "m4uRWL12GM", "1Jqf8kNRXg", "pq9VJwXyCd", "hCEibZOyPY", "pXG1Rmfums", "TL3umzNVNU", "mMChnUgtnQ", "ZIF9RqvavO", "Gb3CC40SXP", "i5VS29r6SH", "i9YlA9pjIQ", "hZnIfKGpqI", "61KozZPf22", "U9l1jkqYMN", "seaNfHR5JG", "N62WMbiyXs", "0VSvFcQnht", "BAAOWzXQ3p", "xEhCQ1WgFg", "L8frIAc1P7", "VmkzBpXVOn", "lX0aqoLJ5H", "MRE3gMsBHq", "aaHTbOS3CZ", "jn85KUQvfj", "q76Oj1AeI5", "aXoQUB3IpD", "3dJh1aJ3Ai", "ejIiqGYgeZ", "hiIxioqv6E", "tBnCtItRVY", "uSs9xOjZaR", "2csVZKd5dD", "A7jVQfbONO", "eM9stioRfc", "ATeDN4P9O2", "BdXJKxQKz1", "2H1tjVQ4cM", "pZvdR4VEbS", "R7RMQguZH5", "D23wg3Qdv4", "fRCgbgxrgx", "Nm6JWj8eSI", "NgbnpyAU0O", "1t4UZ6unzi", "d2TTCt6vcT", "se7cAOkgN9", "OD2yhjVWvF", "qAzokUCXCl", "gSlCE2eJIi", "5t6mYyEaQE", "mYDdPEEIG2", "ZBj5mec6gV", "IvdOYkLXiS", "Zilv1kD8Kf", "lLhWA4kzFI", "9KQlS0ew7P", "nNy0r98nNp", "eoUzpEkyEy", "yjUu47D8QF", "8zhFer1Pkz", "0ozQwDGbE5", "eFOU3rX66q", "sBp8EILe2R"}
local allowedPlayersAge60to75 = {"gy2p1c4dv0", "A5Pk3D76uP", "8Ve8grQGEz", "LIWNXeSbVu", "ZOOOLtvnYE", "tgCq5kh1kv", "iZNhYeWVDD", "ubfhHIqL23", "F6PYwc6sNE", "9rM6yEcWmk", "A3OUQR2FAc", "OUnQyIhDpq", "fQCjfaA7DK", "6z4cpQ92wf", "QtzcRuul8G", "V48k3x57ia", "vFe241UpEn", "rIkWdaNjq6", "qNIS9wCTvW", "ovmuH3bvNz", "4UoAagkIAP", "VbV9CkW6PA", "BnQi2goSY6", "rwXSJaXAho", "T1Aqz41Q5C", "iligaf2dIV", "Zr0peOTSA1", "jVJww60QvS", "fDdHGLMMEu", "SqoA0ZKwJ8", "udTlA44lZU", "yQ0XMv0Pkk", "zmCfgrLDlE", "iczOdiniyR", "c3kv96zk2z", "FSvrSJbZTn", "3DRYSgrJnj", "o36ohXmo3U", "QNgKgjepUM", "NiNdvkATpH", "jIcR050c38", "PCgbNOky1o", "3xDyC9QZTy", "Ckim5mFvoq", "iZoH80BJn8", "wWEddWlxd6", "RSK4nyBdti", "nQNs1GlGVP", "6T9gc25FlY", "nhOG8NxHMX", "XWdfnBWoNY", "QkMLMsBkHN", "GVhhtFarmY", "4OGEhUOdg3", "3QudW4T00m", "Ge5Wi7G7Ok", "S1rvXrTV3L", "ngLeC1uRnN", "OXgiBpNQDl", "m3hdmR0gmD", "0zAMybpW8E", "4gIlmQLW1b", "Za3Y0sZTSB", "0MHW6U2dPY", "CfD5L45Sx2", "McbdxBIXG8", "eKv9dIOqE9", "P9G8rrYCjH", "bYCCzLCXKQ", "KPBrthgRn9", "eJIfVbeoB2", "E83xdBJwYi", "9d3iz0tZyp", "t7E2BuToTF", "KXylgVLohR", "jYDKBRlyR2", "kvxtbX9Ww2", "7jSf2Kop0i", "yHcWeVkb5C", "3wYCzxUWva", "g1lpr3iDNt", "lwC4ays3WX", "zCYa1QnkTZ", "Cydwm5D5Dh", "yoPZ4YsvnC", "vKsw6mz2Gv", "IlPE7DNYyw", "Hufh9cxBkI", "1v53rHyrYa", "kIIVaJ4zMr", "vcwldjWl3W", "x3TCe21Yf7", "Vh0zDOWWes", "72uGVPLRdb", "VUctqsA5gL", "Na74av8ksZ", "v8mmt2XepQ", "ZuF3M8iWLB", "CjLbiWFloY", "620ouaZgkA", "OzdxoeexJb", "jveoXUmspJ", "46V1XrxmRO", "xhdb1G0tdo", "ahYLC8qihx", "FYuARq0elJ", "V5YSLcZmpy", "DA0wiA7HJF"}
local allowedPlayersAge75Plus = {
  "BP_Gamer03", "TheRealAmayaLavaMagi", "flickCinderFalcon", "HawkUmber92", "JosephVoid2006", "NexusSlimeMystic45",
    "EvanCind3rEmb3r", "ItsQuest_Craft", "quillCatalysttwist", "BethMeadowMystic2019", "ItsNathanIce",
    "TheRealEvanbrook", "TheRealOliviaRumble5", "ZaydenLavaTurbo37", "TheRealandyFrostchim", "ian_Loom2013",
    "MrsIsabellaRift", "NexusCarl_TITAN2023", "Sorc3r3rClawYT", "ItsAndrewPixelZephyr", "ItsDave_Master73",
    "DavidThunderb0lt", "NexusEmeraldPhantom2", "taraFrost202185", "B3njaminBlaz3Z3st", "helenP0wer74",
    "EliseglintStar", "ItsCookieFizzyYT", "ConnorsandVoid2006", "janesnack64", "MRSCHLOE_sprout23",
    "MrsNancyfizzleDrift", "NexusruthFlickwhirl2", "ItsPaladinGriffin200", "ItsAmelia_Dynamo63", "ItshelenIcegleam12",
    "ThomasWobble2022", "Blade_Wave2024", "Wyatt_ridg349", "EllaNebulaBlade", "TheRealEli_Rift2022",
    "Th3R3alCal3bL3g3nd_Y", "TheRealNickStreamSte", "sunny_Quasar2006", "ItsDylan_isl3", "MrsninaPrismOnyx",
    "ItsHero_quill", "a2SlcVQK6x", "HX19QidGdd", "spnBJW9jmt", "kP27wT6OB7", "6qHI60mmcc", "6CTz6FN0vi", "unfxYgm1oG", "8s2jsq74m3", "DfM3J62CiR", "WxKhtBML9R", "b1lEiwQSmH", "Bfs99ELYIE", "7n7RGZcT9c", "TD3zoBHkLB", "OvcoFruivB", "kLqDj7Xy2r", "uidfGnixij", "4rWnPotx1K", "byVDwxDRBp", "9IATaNwfEX", "0tFS5qqfRF", "10VvBufOsv", "uE2lNabOE1", "Fwk6MVDdKO", "0tXiUn7h49", "c99izqn6k0", "gM6i8ksEoa", "zXZTwVEp71", "poU0yRg3aE", "U3WPFpHk15", "IZHiaE3Qxj", "3aiE7TnGan", "Yi9lfv5w2G", "N8Db2xgT74", "iuT76kvI1C", "HpbKbozrME"}

local validToolNames = {"Dog", "Golden Lab", "Bunny", "Starfish"}

-- Hàm lấy tool theo khoảng tuổi, có debug
local function getTool(ageMin, ageMax)
    for _, tool in ipairs(Players.LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, validName in ipairs(validToolNames) do
                if tool.Name:match(validName) then
                    -- Regex bắt Age linh hoạt hơn
                    local age = tonumber(tool.Name:match("Age%s*:?%s*(%d+)"))
                    
                    print(("[DEBUG] Tool check: %s | Parsed Age: %s"):format(tool.Name, tostring(age)))
                    
                    if age and age >= ageMin and age < ageMax then
                        print(("[DEBUG] ✅ Tool hợp lệ: %s (Age %d) trong [%d, %d)"):format(tool.Name, age, ageMin, ageMax))
                        return tool
                    else
                        if not age then
                            warn("[DEBUG] ❌ Không parse được Age từ tool:", tool.Name)
                        else
                            warn(("[DEBUG] ❌ Age %d không nằm trong [%d, %d)"):format(age, ageMin, ageMax))
                        end
                    end
                end
            end
        end
    end
    print("[DEBUG] ❌ Không tìm thấy tool hợp lệ trong Backpack cho range", ageMin, ageMax)
    return nil
end


-- Hàm tặng pet cho người chơi trong danh sách
local function giftPetToPlayer(playerName)
    local args = {
        "GivePet",
        game:GetService("Players"):WaitForChild(playerName)
    }
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer(unpack(args))
    print("🛍️ Tặng pet cho", playerName)
end

-- Hàm kiểm tra và tặng pet cho những người chơi trong danh sách
local function giftPetsToAllowedPlayers()
    -- Duyệt qua tất cả người chơi trong game
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        local tool = nil
        -- Kiểm tra xem tên người chơi có trong các danh sách không
        if table.find(allowedPlayersStarfishs, player.Name) then
            tool = getTool(1, 3)
        elseif table.find(allowedPlayersAge20to30, player.Name) then
            tool = getTool(20, 30)
        elseif table.find(allowedPlayersAge30to45, player.Name) then
            tool = getTool(30, 45)
        elseif table.find(allowedPlayersAge45to60, player.Name) then
            tool = getTool(45, 60)
        elseif table.find(allowedPlayersAge60to75, player.Name) then
            tool = getTool(60, 75)
        elseif table.find(allowedPlayersAge75Plus, player.Name) then
            tool = getTool(75, 101)  -- Age >= 75
        end

        -- Kiểm tra nếu tìm thấy tool hợp lệ
        if tool then
            Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
            -- Gọi hàm gift pet
            giftPetToPlayer(player.Name)
        else
            warn(("[autoPickup] Không tìm thấy tool hợp lệ cho %s"):format(player.Name))
        end
    end
end

-- Vòng lặp chính
while true do
    task.wait(0.5) -- Delay giữa mỗi lần kiểm tra (có thể điều chỉnh)
    giftPetsToAllowedPlayers()
end
