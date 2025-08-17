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
local allowedPlayersAge20to30 = { "Player1", "Player2" }
local allowedPlayersAge30to45 = { "Player3", "Player4" }
local allowedPlayersAge45to60 = { "Player5", "Player6" }
local allowedPlayersAge60to75 = { "Player7", "Player8" }
local allowedPlayersAge75Plus = {
  "BP_Gamer03", "ShengCarmen", "Mrsdazzle_Fusion", "THEREALADAM_cloud201", "NexusdeanLight2023YT", 
  "NEXUSCHARLES_Rogue", "MrsChloeGlimmerEcho", "ItsLuke_Luster201172", "NexusTina_Gauge24", 
  "janeZoomcrisp", "TheRealWilliam_quill", "Paisleybrook75", "ItsKenWhirl2008", "z0eth0rnHiccup", 
  "Emilymist2019", "OwenTalon201194", "TheRealjetwhirl", "NexusGriffinWhirlTwi", 
  "NexusBenjaminZero", "ItsPenelopeshade", "ItsivyFusionelm", "MateoSkaterglow", 
  "Th3R3alGiannaRush91", "N3xusb3thLight", "NexusEmilyZephyr", "Itsmary_Jester", 
  "gary_lake", "TheRealTinaWaveTinke", "ian_Tempest2019", "Wave_Halo", "S0phiaM00nbeam", 
  "NexusLandonMeteor53", "JadeShad0w", "ItsCosmoBoulder", "NexusBeastLight", 
  "SamuelridgeHyper", "DanielZoomTitan2007", "natesplash202369", "LilyH3r0", "gleam_Whirl", 
  "MrsElilakeIce2014", "NexusPaisleyGlow", "nateDawn2009", "JacksonGaugeBacon", 
  "EvanLavaGauge201092", "HollyJoltcove", "Audreyember2002", "NexushelenCraft2015", 
  "NoahLegendgusty2019", "ChristopherStealthfl", "MrsNathan_Titan", "CalebPixel_YT", 
  "BoulderDuck", "Jamesquill2016", "MrsvaleAqua58", "Lumin0sNebula"
}

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
    task.wait(5) -- Delay giữa mỗi lần kiểm tra (có thể điều chỉnh)
    giftPetsToAllowedPlayers()
end
