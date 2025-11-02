-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20send%20money%20via%20trade.lua"))()

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TradeEvents       = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("TradeEvents")

-- Controllers / Enums
local TradingController     = require(ReplicatedStorage.Modules.TradeControllers.TradingController)
local InventoryServiceEnums = require(ReplicatedStorage.Data.EnumRegistry.InventoryServiceEnums)
local ItemTypeEnums         = require(ReplicatedStorage.Data.EnumRegistry.ItemTypeEnums)

-- ====== CONFIG ======
local TARGETS = {"B0nnie_Elijah", "YunBrand0n38", "DaleGrace50", "Cath3rin3H0lly", "FallonGwenFelix", "GrantEliseDanny", "Sakura_Amber2022", "Sachik0AmeliaH0lly", "SatsukiChadCecilia53", "Hannah_Frances2009", "GwenAmberAbby2003", "AmberArnold2002", "Dee_Grant41", "Daisuke_Brandon2005", "ShengHazelAlma", "MasakoBrenda33", "F3lixIgor2014", "HughDale2020", "LiEdwin2018", "YongEliseAnn", "ChikaDorothy2009", "SakuraHeidiFallon", "HarukaElisa2008", "FredFaithIan", "EsmeIda96", "DeirdreCarmen2017", "Fl0ra_CAMER0N", "HeidiAbby2014", "HikaruEmmaHenry", "AnnGr3ta2016", "Fallon_Eloise46", "AyumiEmily2003", "YueGwenAaron", "K3ik0Dana", "ShioriIgorBrian", "FumiyaCarlos85", "B0ydCharl0tt392", "DanaGeraldDee", "DeanBoyd201520", "DaoAlice2019", "BlairIrisEric", "XinAnitaBeth24", "AaronDana15", "AyumiGabriel2006", "DariusFaithBianca", "KazukiIsaacEric54", "BettyArthurDeclan44", "ArthurBettyDan201959", "Fred_Aiden2023", "SakiAlan2021", "Chun_DIANE2005", "ShizukaB3lla39", "ShanBrianna2008", "JingEliasAriel", "HarukaB3nn3tt65", "QingFred2004", "HarutoClaudia2003", "GailGrantBonnie29", "HenryCatherineChad", "HeidiGilbertErnest", "NatsumiAl3xandraFr3d", "GaryGeraldFrank", "WenHope75", "HAR0LD_Dani3l", "DaphneEaston2011", "ShiGavinEbba", "DanaFred2005", "NorikoAaron2020", "Ling_Eloise2023", "D0minicEmma2015", "B3thG3rald2005", "DAN_Edith2004", "D0uglasCarl0s31", "ElliotEmmaBeth", "GEORGIA_Dee86", "CaseyElisaAmber25", "EarlHazelErnest", "Kai_Anita2016", "JieDaphne2004", "Sachik0Darius86", "Fiona_Ax3l2019", "Tao_Chas32017", "ChikaBrian78", "CatherineBrad2007", "AmberGide0n", "HeatherDale10", "ZhuEddi3", "Fl0raGrantGreg32", "DanaGreg2012", "DouglasGeorgia2019", "M3iCarm3n2013", "Shinji_Heidi2022", "MasatoBonnie2017", "Y0NG_Francis88", "DouglasIgorDarius", "Franc3sAlmaEdmund84", "Keik0Casey39", "FrankBonnie2016", "Long_Freya2002", "ZhiArthurAaron", "DanaIda2015", "ShigeruAmandaIan", "QingGeorgiaCarrie", "SACHIKO_Elsa2015", "JieAustinCameron", "HunterEmmaEloise", "EbbaBarbaraAmy2009", "B3auClair321", "Dam0nEdmundEl3na", "Becky_DAN62", "EmmaDianeFall0n", "BoydCam3ronGilb3rt", "C0dy_CASEY48", "Edward_Earl2020", "FaithAva2017", "XinIrisHailey", "Danny_Gar3th", "CaraDawn2002", "HunterAlmaAlexandra", "Shi_Ava2004", "AlmaGrant2009", "AriDoris73", "Chad_Ebba2020", "H3nryH3ath3r58", "LinDavid2023", "EikoBoris94", "FallonDawnGeorgia", "Dalt0nH0ward2005", "YueAmyDerek", "WuGregAustin", "HarukiAnthonyB3th", "NatsumiDianaDana", "HaoGavin87", "ZhiDannyIsaac2007", "EdwardDeirdreDeclan", "HarryGr3taCal3b", "Da0_Angela2011", "GloriaH3idiD3irdr320", "Harold_Christina2012", "Na0kiIg0r2020", "YunBorisGrant2023", "Zh0ngCasey", "EdmundAva2014", "RyoAnthony2020", "CHRISTOPHER_Cheryl79", "DamonAri2010", "DallasAndrea78", "HarukaEliasFrancis", "Qing_Elaine99", "SoraDean2013", "NorikoCarla41", "DariusDiane200226", "HowardBradBenjamin", "FengCaleb2008", "M3i_ADAM65", "ElsaGideon2008", "Peng_CHARLIE2009", "B0_Carla", "DawnGr3ta200866", "HarukiAnthonyClara", "Kozu3B3tty2022", "HarutoGideonDan", "EbbaFall0n42", "EarlCarlaHugo", "DA0_Graham2022", "Masahir0Dee2012", "Aid3nDominic2010", "Wu_Arnold18", "HiroshiFelix2022", "Edmund_Beau2003", "HARUKA_Gene2013", "DorothyDavid2008", "HongAaronGavin", "B3ttyEll3nDavid", "Esm3_Earl2020", "EarlGareth2020", "EdithH3idi57", "FaithCara2019", "Gene_HAILEY2005", "ElisaAnn26", "Jing_Gilbert2002", "Ka3d3_ELLA74", "XuanElijah82", "DavidDawnGrant94", "Satsuki_Erin2018", "AlmaArthur2019", "YiDawnAva", "BrentFreya30", "BlairIngridDee", "HarukaEddie38", "N0b0ru_Audrey", "AiBianca65", "AbbyFallon2010", "ImogenClaudia60", "HazelIris2015", "RinaGregAiden93", "MasashiElena2006", "HiroshiGertrudeElean", "Daphn3Graham44", "Eric_D3anna2010", "FredHeidi200211", "AsahiBrent2020", "BaoDanaGrant", "ShigeruCharles70", "QiangHeatherEbba", "AN_Andrea48", "CAMERON_Douglas2005", "HitoshiEbony2021", "EdwardChad75", "BarbaraHeather66", "AsahiChloe82", "CarrieBrianArthur201", "HongBlakeHugo2009", "ErnestEbba56", "FanAlmaEl3na", "DannyEli2002", "BradGrahamDallas", "YangB0nni32010", "Brent_Ava2014", "Ayaka_Eb0ny57", "Dam0n_Eb0ny", "AnnaDeanna2011", "DanGareth2010", "RyoDariaErica", "ErinEric2021", "HarukiAmberHeather34", "WEN_Diana2013", "DanDean72", "EdwinAriBail3y", "GilbertFrankAnita", "Zhong_Dan2004", "CherylBrentFrank", "MasahiroAnthony12", "DeanEbony2014", "KazukiDeclan202142", "YiDeirdreCaleb2018", "D3anColinDawn", "ShizukaErnestIgor", "SatsukiBarry2021", "IngridDeclan2002", "EddieDariusGene", "LI_Har0ld2004", "Cara_Ida2007", "FionaAxel2020", "HunterImogen33", "Gar3thEdgar37", "MasatoImogenCassandr", "BlakeDaphne56", "DanGeneAnthony", "ZhiAngelica2006", "B0BeauEast0n", "AsukaD0minicFi0na97", "Elois3Anita", "HitoshiEarl2024", "ShigeruChadElena", "Fall0nIrene2014", "B0BarbaraGwen", "ElijahBecky52", "BR3TT_Elias2009", "D0risHarryFaith2012", "GabrielDanny2004", "XiDavid2015", "CassandraChaseBob", "Adam_Ann2008", "XiFaith2017", "EikoEllen2010", "XiaDannyFrances", "ZhiEliErnest2008", "XiBrettCara", "AnnArthur53", "Bo_Am3lia2004", "H0ward_Beth", "FanCherylIan2004", "HotaruFrankDaniel"}
local AMOUNT_SHECKLES         = 36000000000000
local SEND_COOLDOWN           = 3
local MAKE_TRADE_TIMEOUT      = 30
local PARTNER_ACCEPT_TIMEOUT  = 45
-- =====================

local me = Players.LocalPlayer
local CompletedTargets = {}  -- tên đã trade xong trong session này

local function inList(list, name)
    for _, n in ipairs(list) do if n == name then return true end end
    return false
end

-- ====== Trading Ticket helpers ======
local function isTradingTicket(tool)
    if not (tool and tool:IsA("Tool")) then return false end
    local t = tool:GetAttribute(InventoryServiceEnums.ITEM_TYPE)
    if t and t == ItemTypeEnums["Trading Ticket"] then return true end
    local name = tool.Name or ""
    if name:match("^Trading%s+Ticket%s+x%d+") then return true end
    local lname = name:lower()
    if lname:find("trading") and (lname:find("ticket") or lname:find("tick")) then
        return true
    end
    return false
end

local function getHumanoid()
    local char = me.Character or me.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function getEquippedTradingTicket()
    local char = me.Character or me.CharacterAdded:Wait()
    for _, inst in ipairs(char:GetChildren()) do
        if inst:IsA("Tool") and isTradingTicket(inst) then
            return inst
        end
    end
    return nil
end

local function getBackpackTradingTicket()
    for _, tool in ipairs(me.Backpack:GetChildren()) do
        if tool:IsA("Tool") and isTradingTicket(tool) then
            return tool
        end
    end
    return nil
end

local function ensureTradingTicketEquipped()
    if getEquippedTradingTicket() then return true end
    local inBag = getBackpackTradingTicket()
    if not inBag then
        warn("⚠️ Không tìm thấy Trading Ticket trong Backpack lẫn đang equip.")
        return false
    end
    local hum = getHumanoid()
    if not hum then
        warn("⚠️ Không tìm thấy Humanoid để equip Trading Ticket.")
        return false
    end
    local ok, err = pcall(function() hum:EquipTool(inBag) end)
    if not ok then
        warn("⚠️ Equip Trading Ticket lỗi:", err)
        return false
    end
    task.wait(0.15)
    return getEquippedTradingTicket() ~= nil
end
-- ====================

local function bothAccepted(rep)
    local data = rep and rep:GetData()
    if not data then return false end
    local idxMe = table.find(data.players, me)
    if not idxMe then return false end
    local idxOther = idxMe == 1 and 2 or 1
    local myState    = data.states and data.states[idxMe]
    local otherState = data.states and data.states[idxOther]
    return (myState == "Accepted" or myState == "Confirmed")
       and (otherState == "Accepted" or otherState == "Confirmed")
end

local function driveAcceptAndConfirm()
    task.spawn(function()
        while true do
            pcall(function() TradeEvents.Accept:FireServer() end)
            task.wait(1.0)
            pcall(function() TradeEvents.Confirm:FireServer() end)
            task.wait(2.0)
            if not TradingController.CurrentTradeReplicator then
                break
            end
        end
    end)
end

-- ========== MODE: AUTO-ACCEPT nếu LocalPlayer nằm trong TARGETS ==========
if inList(TARGETS, me.Name) then
    print("🟢 MODE: AUTO-ACCEPT (LocalPlayer có trong TARGETS)")
    TradeEvents.SendRequest.OnClientEvent:Connect(function(uuid, fromPlayer, expireTime)
        task.wait(1)
        pcall(function() TradeEvents.RespondRequest:FireServer(uuid, true) end)
        driveAcceptAndConfirm()
    end)

    task.spawn(function()
        while true do
            task.wait(1.5)
            if TradingController.CurrentTradeReplicator then
                driveAcceptAndConfirm(); break
            end
        end
    end)
    return
end

-- ========== MODE: AUTO-TRADE ==========
print("🟡 MODE: AUTO-TRADE (LocalPlayer không trong TARGETS)")

local function getPlayerByName(name) return Players:FindFirstChild(name) end

-- B1: gửi request
local function sendTradeRequest(targetPlayer)
    TradeEvents.SendRequest:FireServer(targetPlayer)
    print(("[B1] 📤 Đã gửi trade tới %s"):format(targetPlayer.Name))
end

-- Chờ trade mở đúng với target cụ thể
local function waitForTradeWith(targetPlayer, timeoutSec)
    local t0 = time()
    while time() - t0 < (timeoutSec or MAKE_TRADE_TIMEOUT) do
        local rep = TradingController.CurrentTradeReplicator
        if rep then
            local data = rep:GetData()
            if data and data.players then
                local p1, p2 = data.players[1], data.players[2]
                if (p1 == me and p2 == targetPlayer) or (p2 == me and p1 == targetPlayer) then
                    print("[B1] ✅ Trade đã mở với:", targetPlayer.Name)
                    return rep
                end
            end
        end
        task.wait(0.25)
    end
    return nil
end

-- B2: set tiền
local function setShecklesSafe(amount)
    local ok, err = pcall(function()
        TradeEvents.SetSheckles:FireServer(amount)
    end)
    if not ok then
        warn("[B2] SetSheckles lỗi:", err)
        return false
    end
    print(("[B2] 💰 SetSheckles = %s"):format(tostring(amount)))
    return true
end

-- Chờ cả 2 bên Accept
local function waitPartnerAccept(rep, timeoutSec)
    local t0 = time()
    while time() - t0 < (timeoutSec or PARTNER_ACCEPT_TIMEOUT) do
        if bothAccepted(rep) then
            print("[WAIT] 🤝 Cả 2 đã Accept!")
            return true
        end
        pcall(function() TradeEvents.Accept:FireServer() end)
        task.wait(2.0)
    end
    return false
end

-- Chờ trade đóng hẳn
local function waitTradeClosed(timeoutSec)
    local t0 = time()
    while time() - t0 < (timeoutSec or 15) do
        if not TradingController.CurrentTradeReplicator then
            return true
        end
        task.wait(0.25)
    end
    return false
end

local function doTradeTo(targetName)
    -- BỎ QUA nếu đã hoàn tất trước đó
    if CompletedTargets[targetName] then
        print("⏩ Bỏ qua (đã trade xong trước đó):", targetName)
        return
    end

    local targetPlayer = getPlayerByName(targetName)
    if not targetPlayer then
        print("⚠️ Không thấy người chơi trong server:", targetName)
        return
    end

    -- BẮT BUỘC equip Trading Ticket
    if not ensureTradingTicketEquipped() then
        warn("❌ Bỏ qua trade (không equip được Trading Ticket).")
        return
    end

    -- B1
    sendTradeRequest(targetPlayer)

    -- B1.5: chờ trade mở
    local rep = waitForTradeWith(targetPlayer, MAKE_TRADE_TIMEOUT)
    if not rep then
        warn("⏳ Hết thời gian chờ mở trade với:", targetName)
        return
    end

    -- B2
    setShecklesSafe(AMOUNT_SHECKLES)

    -- B3/B4: lặp Accept/Confirm
    driveAcceptAndConfirm()

    -- Chờ đối phương Accept, rồi Confirm lại lần nữa
    local ok = waitPartnerAccept(rep, PARTNER_ACCEPT_TIMEOUT)
    if ok then
        task.wait(0.5)
        pcall(function() TradeEvents.Confirm:FireServer() end)
        -- Chờ trade đóng hẳn → đánh dấu hoàn tất
        if waitTradeClosed(20) then
            CompletedTargets[targetName] = true
            print("✅ ĐÃ HOÀN TẤT trade với:", targetName, "→ sẽ không gửi lại.")
        else
            print("⚠️ Trade chưa đóng sau Confirm (không đánh dấu hoàn tất).")
        end
    else
        warn("⌛ Đối phương không Accept kịp.")
    end
end

-- ====== Chỉ quét người đang ở server và nằm trong TARGETS ======

-- Set tra cứu nhanh O(1)
local TARGET_SET = {}
for _, n in ipairs(TARGETS) do TARGET_SET[n] = true end

local function isTargetInList(name)
    return TARGET_SET[name] == true
end

-- Quét tất cả người đang ở server ngay khi start
local function scanAndTradePresentTargets()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= me and isTargetInList(plr.Name) and not CompletedTargets[plr.Name] then
            doTradeTo(plr.Name)
            task.wait(SEND_COOLDOWN)
        end
    end
end

-- Khi có người vào server, nếu là target thì xử lý ngay
Players.PlayerAdded:Connect(function(plr)
    if plr == me then return end
    if isTargetInList(plr.Name) and not CompletedTargets[plr.Name] then
        -- đợi nhân vật/replicator game ổn định một nhịp
        task.wait(2)
        doTradeTo(plr.Name)
    end
end)

-- Vòng quét nhẹ định kỳ (phòng lỡ lúc PlayerAdded bị miss)
task.spawn(function()
    while true do
        scanAndTradePresentTargets()
        task.wait(8) -- chu kỳ quét
    end
end)
