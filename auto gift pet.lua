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
local allowedPlayersRarePets = { "ItsglowAlpha2019","ninaBuilderBlade","Th3R3alMik3Titan2007","ITSNORA_Omega","J0siah_Radiant23","ItsGraceTwistMoonbea","taradriftOrbitz","Nexuszoe_plume","NexusgaryZ00mj0lt","ItsKarasparkle64","TheRealLaylaSpecter","ItsKayleeSky","Levi_HICCUP2002","NexusMila_HYPER","EvanStar83","Violet_Flame73","EmilyN3on","EmilyNexusGhost","MrsTwilightInf3rno","NexusJames_SHADY2020","Th3R3alianCod3","ITSSAM_Wraith","FireCrystalCactus","TheRealJackson_Dusk","IsaacFlame98","MrsdreamJelly2006","NexusIsabella_RIDGE","MrsGinaCrystal","QuasarStream","MRSSTARRY_Sorcerer","ItsB3llaQuasarsunny2","GregSt0rmy2012","Vict0ria_Arr0w2011","TheRealAddisonJester","B3ar_shady","EliGr0v32005_YT","Itsl3oVaporTig3r","TheRealhughdreamSkat","MrsKylieHearthhaze20","Ril3y_J3ST3R","ETHAN_sand2013","TheRealTinaSpiritSli","TheRealvale_Wolf","MrsAubreydawn2023","ItsMilaLight2004","Th3R3alMason_Zigzag","Jake_HAZE202167","Ward3nTurb0gl0w2023","StormsproutMoonbeam","TomGhost2019","SarahWizard29","Glider_Mystic","JaydenRumbleSigma","Zayd3nSpirit","TheRealMadisonGhostY","N3xuszo3plum3nook","DriftVoidHunter","reef_Max","ninareefHero2022","Henrymist74","ItsSavannahTinkerGau","h3l3n_Z3ST","TheRealZaydenSkaterD","BrooklynScorch65","NexusSkater_LUCKY","ChloetwistStorm","ITSEVELYN_dream2019","Itshush_Moonbeam","NickVectorEagle2007","kyleSorcererDusk","ScarlettAuroraIvory","TheRealZephyrQuackYT","Itsclair3Ac32005","Itssplashflake","Sparksnack2016","ruth_Echo2020","Hunt3r_candy","ItsdanaBlizzardknoll","NexusThomas_Pulse51","TheRealmirthHalo62","Haz3lzippy2018","andyHunterwhisper200","NexusAvaGlitch","Grace_Dusk202299","NoraPrismXenon","TheRealDawnsunnyHero","EthanWave2024","NexusEllaFlick","w3ndySunris3","ThomasChillDark","SebastiansplashLoom","driftfizzl3","ItsChristopherVaporC","TheRealFrostVoid69","TheRealJill_Miner","NexusCarter_zest","EvanCometDrake2012","PetterZephyr2014","ItsProKaleido","FoxshadyQueen2016","MrsEllieChill","ItsIsabellaZap","JackNebulaSky202418","WILL_Fable2002","IslaOrbit2019","J0hnQuack","MrsComet_Moonbeam","Itszippy_MISTY","KylieBane2016","NexusClaraBeast","Harry_hush70","TheRealJakeNebulaCha","MrsAvery_Prism2011","IslaLegendAqua","TheRealfred_sparkle","OrbitzEmberYT","TheRealPeytongusty","ItsEdwardSpirit","Madis0nEch0201069","QuartzVibe74","LukeLoomYT","NEXUSDANA_Quest","ItsOblivionNight2023","AlphaGaug3","Tangle_Gauge49","ItsGinaBlastHawk","P3tt3rAc3","Henry_CATALYST2017","TheRealCrimson_Quest","TheRealOliviaScorch2","NexusJulia_Enigma39","hughnookTurbo","TheRealIanStream","MrsWilliamJade","ALAN_Stealth2017","NexusIsabellastone50","AndrewVoidOnyx","EdwardGobbleVibe","MrsgustyLuckynook201","gustyBanecloud2017","Aur0raTitan","ItsKatherinePhant0m","TheRealwill_Sunrise","TheRealAmaya_Rider","N3xusGlow_Haz3","CrimsonBane2023","WilliamSigmaKaleidoY","HarryHunterBlizzard2","Faith_SHADOW2004","Cosmo_BeastYT","cloudBearoak","Inkriver2008","hughCyber2021","Th3R3alCart3rIgnit3","GraceKiteAbyss","TheRealscottpawsGlow","NexusHarrysparkleCom","helenAquaFusion","DaveIv0ryRaven","RileyPulseLoom","ITSISAIAH_Turbo","NexusmaryKaleid0","Jill_Meteor77","Itsnatepaws","ElizabethAlphaStormy","ItsWillow_chime","Itslaura_Eagle","JackUltraGobble2007","Owen_Titan2017YT","MrsLevisplash32YT","TheRealThomas_chime","NexusHenryRaven","NexusDancerSilver11","N0ra_B3ast2005","TheRealZacharyTiger2","ScorchTitanGalaxy","DaveRavenIce","MrsRiftpawsHawk97_YT","BenStarlighttwist","TheRealEllaHalo2007","Mrstaraember","TheRealPetesparkle","MrsgraceTwilightThun","ITSSAMANTHA_Tangle20","Vort3xV3nom68","MrsZoe_sand","TinaFlareGlimmer","XeroLegendGrove2023","LuminosStormyflick","TheRealZayden_SHADOW","wendyYonderfizzle201","G3org3OrbitOpal2011","nateflick2015","QuackVectorzippy","TheRealNancyZephyrqu","NexusFlareHaze","garydreamCatalyst","EthanYonderQuartz","IanKnight28","ItsLeviFlicker","paul_Whisper36","Bella_Storm2019","ItsZayden_RADIANCE","ItsRadiantcandyBacon","ItsFireSurgeCosmo200","TheRealLunaFlame_YT","Sparkly_Titan","ScarlettTempestbloom","NexusSophia_twirl","Rosetwirl2003","andy_Radiance72","K3nN3on","RUMBLE_P0wer93","EzraSigmaChill","NexusOwenVenom","NexusBenEmerald","PlayzWill0wC0met43","KnacksplashGam3r","HollyDewEpic","vaporZap78","Kaylee_Paladin2021","EvanLusterSparkly","Ros3Glow39","ruthdreamCraft2022","SamFalcon13","ScorchInk","LeahParagon2006","MrsNathanChaseWhispe","NexusAddisonnook2012","MrsBellalake","TheRealOwenBlaze57","Ella_Glow33","TheRealSkylarZest","MILA_Neon2008","EvelynbubbleCactus","MrsRil3y_N3ON2016","Charles_Hero2004","TinaLegendYT","MrsSilverDawn","MrsTwilightMeteorRum","TheRealJoseph_Ultra","NexusChaosSurge2014","MrsmarkFlicker","chrisFlame201369","TheRealEmerald_Orbit","MRSELISE_Blaze","Moon_Noodle2003","ItsPeteVortex_YT","Itsshadeember201543","TheRealJamesBounce","ItsWolfflick","Gabriel_Hearth2006","PaisleyG0ldenTitan","MrsZachary_plume","THEREALDANA_Crystal2","BethXenonfrosty2019","NexusKenNinja2005","Th3R3alN3bulaStarry","NexusDew_Flicker2023","gl33_j3t","NexusChristopherbubb","FireL00m","MrssethByteQuartz","MrsZaydenC0met2007","JakeTalongleam","dreamG0bble","ItsSpecterTempest","TheRealEllaUmber","TheRealninaSapphire9","NexusNickAurora2022","NexusPaisleyBoulder2","rach3l_Zoom","LeviGlimmer2007","GraysonAquaPulseYT","AveryC0sm02010","ItsianMiner2003","ItsNibbleDrake","TheRealHarryNoodle69","FusionGamerFlick","MrsruthDawnDoodle","TheRealjack_Rift","Levi_th0rn","AbyssC0m3t","MrsEvanAlpha","ChillFizzy27","ItsNickf3rn","ItsFrankZeroash2020","KYL3_Flick2009","Th3R3albubbl3J3lly","ItsMaxLava45","LunaLusterMeadow","Ultraash76","ItsMilaDriftQuartz","TheRealruthbubble","NEXUSVIOLET_Chaos","NancyflickAqua","TheRealAuroraSizzle","TheRealadamSkater","MrsNibbleL00mst0ne20" }
local allowedPlayersAge20to30 = {"hM3k0MKDy7", "FDKvsFRyij", "1WrGPT99YZ", "lGN5HV0QRB", "RyWplxgwTF", "1LuKdYEXJj", "Z3HyDCmZ9e", "vSspBIeNHJ", "WJjYjRfnkQ", "WMZ1OD65K7", "K5vWsY3T3i", "MYcE9AeZjR", "1sfVp3BSp4", "WYelAHLDod", "On2xv7crL5", "bvh4Ezbz2o", "9DB1IpuODq", "ppyWlJrAfe", "C4M1DKJoJL", "mcZVNZYbDR", "ELLCUqli5E", "tS7i6Pc7pI", "ui5rWCH6GN", "UK0ySLbwZ8", "pLgQfcyTJS", "q0SgNQOJTk", "mbsR41zocp", "ruFv2yeI3x", "XbuOzhgpIW", "1rMnQDFIxX", "9pPiDbjusO", "D7GEIZuG2r", "QtVIMjVpec", "UDQKXEpX6N", "UEDEJJvUot", "mVARj4hNJ0", "XBmNvrKsyL"}
local allowedPlayersAge30to45 = {"PRXhixwCDI", "Zfe10TgPKW", "Bw8otUtRLl", "saAZkbeyCk", "fScGRKPwUG", "AtVY8wsUgP", "knaru5AWAs", "5UKL1EkSks", "vM9hPRnkzj", "5kolW3SWUr", "oHQIYCe7eP", "7Aa37sVTsu", "Dn9Ct0OAiL", "4RGfdYAltc", "b5PLbiqdJX", "XDca9fj1gC", "KDemIXsgNA", "TnyaJUVOte", "gTWtFbfidU", "J698IrGWV2", "TebpO8uCxk", "GoaRAHQfiW", "AIX1jNlnSo", "Cc3FyP0Enh", "lZp005RMti", "loWSSV04rk", "tGI7T9RFFZ", "ZOmCCAEXHK", "dfaY7tE76n", "zLIHqL7onc", "3lzjAmwJZ0", "VIi1Kl7xSk", "0jGILtD144", "4hPAPXYbcV", "iqJYlpVrf0", "57XSmISzxX", "j11I9eBaRp", "gsObh7uAyw", "dgdRNCpv5o", "k1pNz7AyuJ", "1FYGyyCWBm", "7McATQtIi1", "heAvEu2DvD", "fzIwnbE0pV", "9T0UmScG4q", "ZGscgiiVfT", "HZGWQpSDaT", "MZr6PvHtvN", "wBYM0PhmfY", "tZicPO0wDF", "93WjOJWvz0", "JQctJbM9yc", "YojN4Hldcc", "RuIsuT6vZw", "srdaQY9xFl", "eewtU59xwO", "KfstW25FVy", "MeBH9RTyPS", "5TBrsFw9y3", "nzPIHYpfEj", "vG7ZRMY6tG", "4bpdExTOm6", "rhjAZ1vgoG", "tLZsenRFbc", "1hye03zaEX", "fxfKG1oVGq", "kjubHCPNez", "Cz6vbsSJLy", "rtKKXFC37a", "yD2niHVsiq", "oOnHdWLSKc", "4I1XMLOw6X", "WUr8koRY9r", "jQe8Piczue", "W4IvJwrESv", "kru0qtzUet", "uALzoYmcnT", "2pYupwESAO", "74KzYidOk0", "fptTVJUK2q", "VrBEfY2x74", "bciJ5zU6d2", "8baWWXzqqP", "zxiDbYWBPO", "zpX0zIIxle", "AEOXWnbo1M", "FKQrKBmMxg", "jDLQJkhRqt", "H4jYw9Puns", "KGcf8Q1Yal", "HjCeyW4R2C", "i7TtRYzK0u", "OBCNnhTWva", "GEZ04VGlPU", "Cpi9ItMxhN", "t1Q5X6uH1C", "ZLBtBFHwlN", "KvCHw7D44i", "oIyCUSUh07", "CQzPWClDxL", "HsijrufGSL", "jRfIbhglpN", "2lDj2bzt8f", "X7scGQXxQx", "KGkR6UYJss", "vnaiHiDVML", "TcHNjTxKAF", "Ijvpt8UmVF", "IJkl3r7Iy2"}
local allowedPlayersAge45to60 = {"fHmRDxU2uD", "4j3AisiMiW", "k8cyvab2Zz", "AkOqxE06qU", "Lx5s9IAuHX", "t7jPIl8UNe", "kX1cW8BhRE", "aRqwkNpGSV", "KruFKmxIrK", "FDQr6sZ89s", "7LIJyDgLSe", "Ix27CDG5t8", "uSLXosRiud", "NEX6giptpK", "vlPqtHKQno", "TKQSCREhqw", "a8UmICaCFD", "zUFfhiLiQg", "tWsnWFZP6l", "FpvsR1ENu0", "V3r03hcdvL", "Sy7A3xtyAa", "7zPYdC31Kx", "6U2y2VMBor", "HkUyLc6DoH", "hB1he32z6a", "UzopT2l9ta", "2uDIG2gV10", "drwXomtHyY", "ljoQGdhbd3", "gkx6KI3myb", "tIEc9kk4ss", "gjegyy1G3R", "gUdH20fN25", "FHoZCA0v79", "2fgdqkEw3N", "s6XKtwTKGc", "HjUyNuWtHc", "g7uKQEdPy7", "AaZReYirbm", "rfMrLVZQ9U", "7EZgQmwBPE", "0tbABe930u", "Y8VEXrkrbi", "njGN2TP47X", "m4uRWL12GM", "1Jqf8kNRXg", "pq9VJwXyCd", "hCEibZOyPY", "pXG1Rmfums", "TL3umzNVNU", "mMChnUgtnQ", "ZIF9RqvavO", "Gb3CC40SXP", "i5VS29r6SH", "i9YlA9pjIQ", "hZnIfKGpqI", "61KozZPf22", "U9l1jkqYMN", "seaNfHR5JG", "N62WMbiyXs", "0VSvFcQnht", "BAAOWzXQ3p", "xEhCQ1WgFg", "L8frIAc1P7", "VmkzBpXVOn", "lX0aqoLJ5H", "MRE3gMsBHq", "aaHTbOS3CZ", "jn85KUQvfj", "q76Oj1AeI5", "aXoQUB3IpD", "3dJh1aJ3Ai", "ejIiqGYgeZ", "hiIxioqv6E", "tBnCtItRVY", "uSs9xOjZaR", "2csVZKd5dD", "A7jVQfbONO", "eM9stioRfc", "ATeDN4P9O2", "BdXJKxQKz1", "2H1tjVQ4cM", "pZvdR4VEbS", "R7RMQguZH5", "D23wg3Qdv4", "fRCgbgxrgx", "Nm6JWj8eSI", "NgbnpyAU0O", "1t4UZ6unzi", "d2TTCt6vcT", "se7cAOkgN9", "OD2yhjVWvF", "qAzokUCXCl", "gSlCE2eJIi", "5t6mYyEaQE", "mYDdPEEIG2", "ZBj5mec6gV", "IvdOYkLXiS", "Zilv1kD8Kf", "lLhWA4kzFI", "9KQlS0ew7P", "nNy0r98nNp", "eoUzpEkyEy", "yjUu47D8QF", "8zhFer1Pkz", "0ozQwDGbE5", "eFOU3rX66q", "sBp8EILe2R"}
local allowedPlayersAge60to75 = {"gy2p1c4dv0", "A5Pk3D76uP", "8Ve8grQGEz", "LIWNXeSbVu", "ZOOOLtvnYE", "tgCq5kh1kv", "iZNhYeWVDD", "ubfhHIqL23", "F6PYwc6sNE", "9rM6yEcWmk", "A3OUQR2FAc", "OUnQyIhDpq", "fQCjfaA7DK", "6z4cpQ92wf", "QtzcRuul8G", "V48k3x57ia", "vFe241UpEn", "rIkWdaNjq6", "qNIS9wCTvW", "ovmuH3bvNz", "4UoAagkIAP", "VbV9CkW6PA", "BnQi2goSY6", "rwXSJaXAho", "T1Aqz41Q5C", "iligaf2dIV", "Zr0peOTSA1", "jVJww60QvS", "fDdHGLMMEu", "SqoA0ZKwJ8", "udTlA44lZU", "yQ0XMv0Pkk", "zmCfgrLDlE", "iczOdiniyR", "c3kv96zk2z", "FSvrSJbZTn", "3DRYSgrJnj", "o36ohXmo3U", "QNgKgjepUM", "NiNdvkATpH", "jIcR050c38", "PCgbNOky1o", "3xDyC9QZTy", "Ckim5mFvoq", "iZoH80BJn8", "wWEddWlxd6", "RSK4nyBdti", "nQNs1GlGVP", "6T9gc25FlY", "nhOG8NxHMX", "XWdfnBWoNY", "QkMLMsBkHN", "GVhhtFarmY", "4OGEhUOdg3", "3QudW4T00m", "Ge5Wi7G7Ok", "S1rvXrTV3L", "ngLeC1uRnN", "OXgiBpNQDl", "m3hdmR0gmD", "0zAMybpW8E", "4gIlmQLW1b", "Za3Y0sZTSB", "0MHW6U2dPY", "CfD5L45Sx2", "McbdxBIXG8", "eKv9dIOqE9", "P9G8rrYCjH", "bYCCzLCXKQ", "KPBrthgRn9", "eJIfVbeoB2", "E83xdBJwYi", "9d3iz0tZyp", "t7E2BuToTF", "KXylgVLohR", "jYDKBRlyR2", "kvxtbX9Ww2", "7jSf2Kop0i", "yHcWeVkb5C", "3wYCzxUWva", "g1lpr3iDNt", "lwC4ays3WX", "zCYa1QnkTZ", "Cydwm5D5Dh", "yoPZ4YsvnC", "vKsw6mz2Gv", "IlPE7DNYyw", "Hufh9cxBkI", "1v53rHyrYa", "kIIVaJ4zMr", "vcwldjWl3W", "x3TCe21Yf7", "Vh0zDOWWes", "72uGVPLRdb", "VUctqsA5gL", "Na74av8ksZ", "v8mmt2XepQ", "ZuF3M8iWLB", "CjLbiWFloY", "620ouaZgkA", "OzdxoeexJb", "jveoXUmspJ", "46V1XrxmRO", "xhdb1G0tdo", "ahYLC8qihx", "FYuARq0elJ", "V5YSLcZmpy", "DA0wiA7HJF","Gr3taClaudia60", "DANA_Brenda90", "AlmaAlic386", "SotaDavidBarbara89", "N0b0ruAmberH0lly", "Zhu_Dorothy50", "IngridAnn37", "Gareth_EBBA", "BarryArielGavin", "CarmenElsaElias", "EarlBrianna89", "FaithHaz3l", "HunterCarl0s2016", "NaFrances2015", "ChengAbbyClaudia", "EriDominic92", "XinEricaGilb3rt", "C3ciliaEsm3Ari", "H3l3n_BR3TT44", "NatsukiBarbara", "WeiBriannaCara", "HowardEliD3bra", "DaikiChristopherIgor", "Carl0sChas32011", "IgorEli2024", "G3raldDallas2010", "Bail3yGid30n", "H0llyDiana", "IdaHughAlic32024", "R0ngAustin", "Helen_Edmund", "YueHerbert2009", "AM3LIA_B3njamin", "DallasDeirdre2024", "Asuka_Cal3b", "AyumiElizabeth2005", "FengHannah2011", "TaoDebra", "Gr3ta_H3NRY201344", "DannyBeauAbby2008", "AaronEliDee", "B3thH3nryGrac3", "Chris_H3L3N", "ShengHenry74", "EdmundFredIgor", "KotaroAlice201712", "MarikoDanielle", "DaisukeAnnEric", "Franc3s_Boris", "ShuEb0ny", "HerbertEl0iseChelsea", "CarlosIris52", "Sachik0_Cheryl", "KiyoshiChristinaBenn", "Ch3rylHug02017", "Yong_Freya", "GilbertEsmeAngelica", "H0ngGavin", "FengHugo", "Anth0nyCharles", "RikuAng3lica", "Fumik0BarryFall0n", "KIYOMI_Carlos2016", "Clair3Dani3l", "EricaColin60", "Ning_Barry2022", "G3n3vi3v3Gar3th", "KeikoHazelEmma", "FrankAngelicaDonna", "Shizuka_GRAHAM", "D0ris_Gar3th29", "QiangB0yd", "DeeBarryDallas", "MichikoCasey22", "HuaGrantGenevieve202", "ElsaIsabel66", "DeeGary2012", "CaseyHowardDan201320", "YiChas32014", "IngridCherylIsaac", "Alic3_Ava", "EliBlakeGary2010", "RikuDanny2002", "DeanIsaacErin2007", "DaleEli2017", "HitoshiAnthonyEdwin", "EliseDaleBeau", "DouglasGeorgia2014", "AvaCaleb25", "DanaEmilyAlice", "Dani3lBarry", "DI3G0_D3an2015", "ERI_Andr3a", "MasakoHeather2014", "FaithBr3nt2005", "BorisDoris98", "Felix_Caleb50", "DorisDaphne45", "RONG_Daisy", "NaCatherine2002",
    "Hop3Hugo2003", "GaryIanCameron", "GloriaHenry2023", "Heather_Harry", "Natsumi_Brian2018", "EsmeEdmundChelsea", "SakuraElisa2003", "Amb3rAdam201890", "BradDominicAnn", "AkiraDi3go", "EdgarAm3lia", "NATSUKI_Daisy202277", "ElijahAndr3a", "HarukiHerbert2009", "FumiyaHeather54", "LinGilbertBoris", "Hir0_Al3xandra49", "Qia0_Danielle51", "EriBlairDeirdre2017", "SakuraBail3y201652", "Jing_Fallon2013", "CarrieGraham56", "FR3DDI3_D3bra", "Shiori_Frances", "Shi0riHeather", "IreneHugh2007", "Fallon_Ch3ls3a2019", "AshleyAdam2002", "Takumi_DAPHN3", "YueDebra2002", "Diane_Alexandra54", "Kiy0shi_D0ris", "SotaIsab3lCh3ls3a", "W3iCarol22", "ShioriArthurDarius20", "C0lin_Elsa2019", "ChadEloiseFiona", "Fall0nCaleb", "EriChaseAngela", "QiangElena", "ANDREA_Anth0ny", "Arnold_Carm3n", "Catherine_DEREK", "AlanDorisGloria", "GangDan2007", "NatsumiElijah85", "LingAmelia2016", "FaithGavin65", "SakuraDeirdre2002", "MarikoBrian", "D3braElain3", "DaltonAmy2006", "Ka0riDaniel", "GraceCarla2008", "FangGeraldDawn15", "AlanGrantCh3ls3a", "DeannaEdwardHelen", "IgorChelsea2004", "Br3ttCarm3n57", "FelixBradAmelia", "Kotaro_Dalton", "HitoshiAbby45", "EricaCharl0tt361", "AvaChristina82", "ZhongAbbyEarl", "Dorothy_Barry", "DaleFreddieGene", "Sh3ngEaston", "Hunt3r_Ava", "EricEli2007", "BorisChrisIris", "XiaCatherine", "HeatherDaniel201085", "KAZUKI_Grant21", "ArielIsaacD0uglas", "Takumi_Isab3l", "FumiyaDorothy", "FangFelixGilbert", "EricElla2022", "Ry0Deirdre2011", "K3ikoH3ath3rFrancis", "HerbertFrancisElias2", "ChristinaDanaCarla20", "Qiu_Elois3", "AmberCharlesHelen", "XiaoElaine2018", "Fall0n_Freddie", "WeiIrene2014", "ElliotIanEddie", "ChaseErinH0ward98", "DerekBriannaEmma", "AyumiChadGreta", "Beau_Axel46", "BiancaAnnaGail", "Gideon_Cody62", "LONG_Ernest2024", "Xia0_D0r0thy", "C3liaAng3licaElijah", "KazukiFred2016", "KentaBrian2011",
    "DeirdreChase2010", "ArnoldFrancesCecilia", "ERICA_Gw3n47", "Kiy0miDavid47", "Edgar_FRANK41", "Ian_Diane2015", "ANNA_D3clan88", "Hotaru_Gary2020", "ShigeruAngela", "Sakura_FREDDIE", "Ashl3yAng3la2011", "Fumiya_Carrie2008", "Kozu3H3idi", "NorikoHughImogen", "JingEdwinDiego", "Natsuki_Brett2018", "CharlieGenevieve", "D0ris_GWEN", "YiArn0ldB0ris", "QiaoCecilia91", "Rong_Dominic", "WeiHeidi2011", "AmyHazelCody", "Wu_Amanda", "CaseyEbony2007", "AnnFreyaCelia", "Masat0Genevieve", "SotaDamon2011", "H3rb3rtChas376", "NaCaraEdward", "Xia0_Ge0rgia2016", "FrankGwenChristopher", "AiErin2015", "ShengH0wardCharlie", "David_Christina", "Hir0shiH0pe46", "EbbaHughDaphne2010", "B3au_Brad", "LeiBrenda200216", "KozueChelsea2017", "SoraCharles2002", "MaoAndrea2023", "LingEaston201535", "BobElaineEdith", "AkiraIrisEli", "DaisukeFrancis", "Zhi_Elias2003", "Br3tt_Blair2011", "Esm3Ell3n", "HughCharlieAriel", "Akira_Genevieve", "KenshinFiona10", "FALLON_Amy2021", "HaileyHar0ldFreddie", "Keiko_Carol29", "Dalt0nDam0n", "KiyomiBrianDawn", "L3iHarold", "G3orgiaCharlott366", "Kozu3Earl43", "HARUTO_G3rtrud32009", "Howard_CHAD2015", "NaBrent2019", "NoboruBaileyFreddie", "CaseyAmandaBoris", "EdgarBail3y2010", "Eddie_Erica", "L3iG3rtrud3", "AlanEmma2019", "BeauElsa2019", "Esm3Diana2015", "HiroshiAshley", "B3ttyDi3go", "GeneDanielle2005", "BoydArthur2013", "Hir0Frank2022", "DominicCarrieGabriel", "Arn0ldHenry64", "Dieg0_Catherine", "BobDale2014", "Brian_Alma", "C3liaDian3", "DeeCharles2014", "DeannaAudrey62", "Ig0rGrahamBianca", "EdgarFionaAshley", "Fr3dCharli3", "Daphn3DorothyD3anna", "BELLA_Hunter34", "Ir3n3Ern3stG3n3vi3v3", "AbbyBobGrace", "ChikaAmanda39", "IrisDianeAustin", "B3nn3ttBrand0n", "Noboru_Easton", "AnitaElliot2016", "SatsukiElsa2012", "Sachiko_Elias", "AiAnnAmelia", "H0taruBrett2006",
    "RinaH3rb3rtBrianna", "Wen_CALVIN2018", "Hua_Dallas2005", "NingDeclan54", "Ch3ls3a_Ari72", "S0taAudrey68", "Edgar_ALAN49", "GregIreneBrandon", "Ry0_Arn0ld2009", "Bianca_GRACE2002", "HongAid3n2022", "Na0mi_Chas3", "Ax3l_Ashl3y", "Ann_Harold2002", "Mao_Gideon", "Sachik0Fr3ya", "FanIrisEdward2010", "ShinjiDawnFrancis", "SakuraDian3", "MasakoG3raldDarius", "Ch3ngIan", "RenAlan2021", "HughBianca2002", "TakumiCasey2014", "DANIEL_Alexandra2020", "Cas3y_D3anna", "AmberD0minic2022", "Saki_HANNAH", "Dominic_Daphne82", "Masato_Darius", "NatsumiChase", "Eli_Dale2020", "EmmaFionaBrent", "KazukiDallas2006", "DouglasEllenChloe", "GeneEdmundFrank", "CodyDeanChristina83", "BaoGabrielGreta", "MaoH3l3n91", "DEBRA_Hugo", "D3braDaphn3Ingrid", "ShioriHarold2010", "Kiyoshi_ERNEST", "Hope_David2009", "P3ng_Hugo", "AyakaDaisyCaleb", "Hugo_Chris2017", "Sachik0Erica", "RongErinDaisy", "Ha0_Faith", "Lin_Beau", "AriEaston2013", "Austin_Calvin12", "JunBecky2016", "Danny_El3anor", "SACHIK0_David2023", "Shizuka_Elias202044", "DaikiHaileyAngelica", "HugoEddieHope85", "DeanFrancis2004", "B3thAid3n", "MasashiIreneDeirdre", "Anth0ny_Carmen", "Cara_Cas3y2019", "JieDanielHenry", "IngridEarlHope", "DanDominic200497", "Ig0rDani3ll3C3lia", "Dani3lEdwardAri3l", "CeliaEdmund54", "Blair_B0nnie", "BriannaHugoIan", "NaomiEric2017", "Mao_Edith2019", "YanDanielleCaleb", "QiaoDamon2004", "JingHoward2019", "NatsumiDanny2007", "BrettCasey2003", "QiuCaleb201385", "ChristopherFaithAudr", "HUNT3R_Alic3", "DaoDaphneCasey", "AvaErinHenry", "Ma0_Henry", "EsmeEmmaEdith", "GabrielDannyGene", "FelixBecky38", "Gerald_Blake61", "Hope_Chloe2019", "BlairFrankDee", "ShanBail3y43", "AVA_Fallon", "WuIngrid52", "HannahAmber49", "AnnaBonnie95", "ShiDariaHeidi", "JieBrendaDiana", "Ming_Graham2016", "ShiDaleErin89",
    "DanHannah43", "Fr3ddi3Eli2013", "Qia0Dian3", "Daiki_Ingrid", "EDITH_Amy95", "BeckyIdaHolly", "SHAN_Edmund2018", "AngelicaBecky", "Lin_AMANDA2018", "Hua_Dominic", "Gu0IanBecky", "CodyDallas2009", "FallonAri201051", "D3annaG3orgia", "AiB3cky", "ImogenDarius2018", "IRIS_Blak3", "ELLEN_Dam0n", "B0Amber201511", "DaisyDouglasC3lia", "HopeBethAmy", "Gr3gD0uglas", "Charli3Calvin", "AngelicaElise71", "ShanArthurCharlott3", "Fumiya_Charlie", "NoboruEddi3Ang3lica", "Kaori_Edith", "AnnAlma", "ClaireAri202321", "BRIANNA_Irene2010", "HiroshiAlexandraAnge", "ErnestFredEbba2022", "Mari_DANA54", "Earl_Gertrude", "HuiElsa83", "R0ngChrisEbba81", "B3NJAMIN_Gr3ta", "JieHannah45", "Hua_Dalton", "Keiko_Brianna", "IrisDanaDean", "CalvinG3rtrud3", "DariaDana2013", "D3annaBr3nt", "LeiFrankFrancis51", "EdgarFreddie2009", "AnitaAmb3rAaron", "H3IDI_East0n", "DaikiDianeCatherine", "D3clan_G3rald", "DaisyIda2017", "Wei_Imogen", "EmilyHelenImogen", "HuiElsa22", "Ch3ls3aAnthony202230", "DanielleHelen", "DeannaEdgarElsa", "DianaDonna2016", "EDMUND_C0lin", "Qiu_Ian", "MASATO_Eleanor", "KIYOMI_Hope90", "ElaineAshley2021", "DebraDamon11", "ClaireAnitaDanny", "HenryBlair2012", "Harold_Dal3", "CeliaCharl0tte", "EastonDavid67", "Gerald_C0dy", "CassandraF3lix", "DeannaEdmundChristop", "Dal3EdithElisa", "YueGraceGary2005", "FI0NA_Cara", "EbonyEdith2005", "Ying_Emily2022", "Rina_Freddie2021", "DaoBrendaFelix", "Dallas_Blair2020", "BaoD3clan", "DianeDawn2006", "Anita_Angelica2014", "AyakaHughC3lia", "ChadEastonElaine", "Gang_Gwen", "EloiseElisa98", "HitoshiDouglas2015", "SoraEl3na2019", "Sheng_AVA66", "MAO_Helen2009", "HughArthurBlake", "WeiIrisGl0ria", "Aid3n_Fr3ddi3", "B3llaEbony2005", "FrancisEaston2018", "SotaEbba2007", "Gw3nB3au", "AkiraHarryFrank",
} 
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
    "ItsHero_quill", "a2SlcVQK6x", "HX19QidGdd", "spnBJW9jmt", "kP27wT6OB7", "6qHI60mmcc", "6CTz6FN0vi", "unfxYgm1oG", "8s2jsq74m3", "DfM3J62CiR", "WxKhtBML9R", "b1lEiwQSmH", "Bfs99ELYIE", "7n7RGZcT9c", "TD3zoBHkLB", "OvcoFruivB", "kLqDj7Xy2r", "uidfGnixij", "4rWnPotx1K", "byVDwxDRBp", "9IATaNwfEX", "0tFS5qqfRF", "10VvBufOsv", "uE2lNabOE1", "Fwk6MVDdKO", "0tXiUn7h49", "c99izqn6k0", "gM6i8ksEoa", "zXZTwVEp71", "poU0yRg3aE", "U3WPFpHk15", "IZHiaE3Qxj", "3aiE7TnGan", "Yi9lfv5w2G", "N8Db2xgT74", "iuT76kvI1C", "HpbKbozrME", "eO4Ii9ZRBT", "LZfKrLwVyx", "lBopwGiXnD", "iYBM4bxQcC", "jHVDoRjefG", "0iZThGQHUr", "P9KNyW2pTn", "xZvEjRSQFT", "txUScjqLng", "1wFiIKGVqH", "1JuXuExN2b", "IbSkqS9lPc", "1BzygrFssA", "HySjMHi4Sd", "K6rUIMaEZ3", "FTURs1BefP", "G3xnk0zsM9", "CmDEQyoDCQ", "77QXdLAylg", "2Qe0SauMYA", "KtPb2z3Pa9", "qqAkU7P2uC", "Orj0jEzFCb", "FREsJ2tQSC", "SAuSp1ZklL", "iIwiWNIT1j", "mtzEejfu44", "2apk0x7YZQ", "6OI27mjma9", "iR93bNRx4o", "9lw1GOpG54", "QWnulqiGqr", "pjUbxLrCnC", "5M37WnJ2WS", "9imGhsF0VC", "0zwALumNsn", "yvhwaZVWZJ", "Q5gNGlbCN5", "nqTf8zG22g", "b6GFPv1dzE",
    "Eyrxz4u17C", "h2oKsFUfYB", "fJioQJz3fD", "RpG1Oj1ENZ", "oOkeJN9s6L", "oNMq8XpCJx", "6DEhjhYoR2", "hhAeXQHzdA", "kLAZCYlXRZ", "s44geJGVco", "rKfKXMXyhW", "VSs3BOKW0M", "eEYjgkNYJf", "v4RrPhrXy4", "AluiFqmdoJ", "boNEAvjCns", "447sAUZjWf", "CIl4vwVVgp", "U28CWCq7nP", "AHMTsSwB1j", "5Zc62HVl6c", "Yif7mxwNjs", "tuXbojE58Z", "oCpogGFnwE", "0l5O2Hp8pu", "sKjCFYQIAz", "I04khE8tmy", "bfcHYyaujW", "23PKs7SRJ7", "5WczFAfzrA", "2MeGahYErL", "80Cp6zIADs", "JdE0VxpBX7", "VTV624wc4h", "dgMH8C3gac", "JzH8IhN24k", "p4QVKsgr2t", "vnqDQdPP6G", "tvuY4pqFW2", "Tp02BtDt98",
    "gNxZYWKcDk", "gNwAs6rM0t", "I9KtJDoCVw", "cZpUdW0yMx", "u1JXqn6pP7", "TdBl6ZjTlO", "40EvQKGAQC", "MLqrDSDOw4", "A3ocUJ7Owa", "R5ZlkNhtam", "OPVhlC5cLa", "y6UUgOnClg", "BGLZCHMu3Y", "fc3dH7Jf43", "hH14Dvx5bK", "rqiSun9OAi", "2soU1WB3dD", "DzHDV6hbZk", "jbVQQmEb0P", "hcpZ3p6SbS", "ySi9xb9fkT", "hSHnvHElr2", "vWG3npohHb", "2uXW0uhKqR", "jMsMp8A93J", "IkC7xn2kPP", "KDfbYCWwjq", "heIwNjmbBh", "mYoGd7Wo77", "1Lx69XeqwI", "86IcvBKiv9", "BtwsZSZPWS", "DomuPd8uk9", "7rGpXEch3I", "wqLlMsG4Be", "51rtzLU5jE", "p4FI4OR93k", "T7ufqxfu81", "wGBoblzy4k", "TLSIHFD37w",
    "uBDa4ezDEc", "qOi2ILl7xD", "1PP9wDyi0I", "tVGxGF98lx", "h163vUuuoe", "Mm0prSn0Ln", "FunudYIPM1", "3dmkqUM2hN", "CYEpZ2F1Dm", "PPCncRAXg5", "ATNO7MY42U", "9ob8qBPPlC", "q7VBh0a3yM", "UBaRRiZcK3", "xd7ilcLA4H", "oADUJT2lDs", "x2EG3MA8GX", "8VyEM2nTLa", "1xsDWzdrAc", "RDLuBk1PH9", "wIsk4FiIDm", "OKoYkctAu9", "BFx61ZnHgY", "tXB8UYj2HD", "1Q25OBeoCz", "FEqOupbhnE", "49Dgl5TQol", "vF7XS2IvNJ", "mhiU9prQSU", "PnLvBlvvZX", "EdyrsXWReC", "pQ8cKG22pI", "6vRKYypAFc", "Kyepud7pif", "yPvxfMhuND", "ihJgB9QpN5", "W92MbGaHsk", "ybXVVl9CNF", "ETBDKdqKzf", "KthymSDee0",
    "2bRZQGCIV9", "WNdhbSpFoR", "Ohl47nJ1Ev", "I6vcZPlVFW", "sG4zo4DBmO", "ww13oqMCTm", "5dP9kocL1c", "IhduOG5qE4", "Oekb28eLP0", "vfZVUxPvnK", "UWYQhUWEl0", "syL3qJoFjx", "PvlHlzXO7W", "34xUe2sv2a", "AkNPzWkKot", "0GfYkEI72M", "gUnRsTvse1", "y334PUOolC", "6yuCaUqaKz", "5XnjtHA3Ii", "BP38uKSb1F", "MWGG4VaCZw", "Zq8tVqFKHZ", "T7uEtOQ6nF", "NtiyudRdP6", "MMuFDpTGCq", "wJ61jrPqJm", "ea5c8p6Z6e", "V9zP9wzkMp", "oZtVWVRx1G", "9fMFPdcoHY", "UJeQhJZsAL", "maW7iwRVPP", "7nn8GTpcoL", "VmHEFQI1zk", "FWKFFdXHtm", "ypbuGS33vd", "KxhDm2IHSY", "GoWR7t32Mw", "v3ABnWz2m9",
}

-- Danh sách pet không được chọn
local unvalidToolNames = {"Capybara", "Ostrich"}  -- ví dụ

local RarePets = {"Dragonfly", "Mimic"}

-- Kiểm tra pet có thuộc RarePets không
local function isRarePet(petName)
    if not petName then return false end
    local lname = petName:lower()
    for _, rare in ipairs(RarePets) do
        if rare and rare ~= "" and lname:find(rare:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Helper: kiểm tra substring trong petName (case-insensitive, plain find)
local function isUnvalidPet(petName)
    if not petName then return false end
    local lname = petName:lower()
    for _, bad in ipairs(unvalidToolNames) do
        if bad and bad ~= "" and lname:find(bad:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Helper: parse tên tool theo định dạng {Name} [{kg} KG] [Age {age}]
-- Trả về: petName (string), kg (number), age (number) hoặc nil nếu không đúng format
local function parsePetFromName(name)
    if not name then return nil end
    local lname = name:lower()

    -- linh hoạt: cho phép số thập phân cho KG, match 'kg' không phân biệt hoa/thường
    local kgStr  = lname:match("%[(%d+%.?%d*)%s*kg%]")   -- ex: "[5 KG]" hoặc "[5.5 kg]"
    local ageStr = lname:match("age%s*:?%s*(%d+)")       -- ex: "Age 12" hoặc "Age:12"

    if not (kgStr and ageStr) then
        return nil
    end

    -- petName = phần trước dấu '[' đầu tiên, trim khoảng trắng
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")

    return petName, tonumber(kgStr), tonumber(ageStr)
end

-- Hàm chính: lấy tool đầu tiên hợp lệ trong range [ageMin, ageMax)
local function getTool(ageMin, ageMax, onlyRare)
    for _, tool in ipairs(Players.LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, kg, age = parsePetFromName(tool.Name)

            print(("[DEBUG] Tool check: %s | Parsed petName: %s | KG: %s | Age: %s")
                  :format(tool.Name, tostring(petName), tostring(kg), tostring(age)))

            if not petName then
                warn("[DEBUG] ❌ Không phải định dạng pet (bỏ qua):", tool.Name)
            else
                if onlyRare then
                    -- chỉ nhận rare pets
                    if isRarePet(petName) and age and age >= ageMin and age < ageMax then
                        print(("[DEBUG] ✅ Tool rare hợp lệ: %s (Age %d) trong [%d, %d)"):format(tool.Name, age, ageMin, ageMax))
                        return tool
                    end
                else
                    -- logic cũ: bỏ blacklist
                    if isUnvalidPet(petName) then
                        warn(("[DEBUG] ❌ Pet '%s' nằm trong blacklist -> bỏ qua"):format(petName))
                    else
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
    end

    print("[DEBUG] ❌ Không tìm thấy tool hợp lệ trong Backpack cho range", ageMin, ageMax, " onlyRare:", onlyRare)
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
        if table.find(allowedPlayersRarePets, player.Name) then
            tool = getTool(1, 100, true)
        elseif table.find(allowedPlayersAge20to30, player.Name) then
            tool = getTool(20, 30, false)
        elseif table.find(allowedPlayersAge30to45, player.Name) then
            tool = getTool(30, 45, false)
        elseif table.find(allowedPlayersAge45to60, player.Name) then
            tool = getTool(45, 60, false)
        elseif table.find(allowedPlayersAge60to75, player.Name) then
            tool = getTool(60, 75, false)
        elseif table.find(allowedPlayersAge75Plus, player.Name) then
            tool = getTool(75, 101, false)  -- Age >= 75
        else
            -- Nếu không thỏa điều kiện nào thì continue vòng lặp
            continue
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
    task.wait(2) -- Delay giữa mỗi lần kiểm tra (có thể điều chỉnh)
    giftPetsToAllowedPlayers()
end
