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
local TARGETS = {
    "XxMicha3lClawPrismxX"
}
local AMOUNT_SHECKLES         = 36045000000000
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

local function sendTradeRequest(targetPlayer)
    TradeEvents.SendRequest:FireServer(targetPlayer)
    print(("[B1] 📤 Đã gửi trade tới %s"):format(targetPlayer.Name))
end

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

    sendTradeRequest(targetPlayer)

    local rep = waitForTradeWith(targetPlayer, MAKE_TRADE_TIMEOUT)
    if not rep then
        warn("⏳ Hết thời gian chờ mở trade với:", targetName)
        return
    end

    setShecklesSafe(AMOUNT_SHECKLES)

    -- Lặp Accept/Confirm
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

-- MAIN LOOP
task.spawn(function()
    while true do
        for _, name in ipairs(TARGETS) do
            -- chỉ gọi nếu chưa hoàn tất
            if not CompletedTargets[name] then
                doTradeTo(name)
                task.wait(SEND_COOLDOWN)
            end
        end
        task.wait(8)
    end
end)
