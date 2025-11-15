-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer
local HttpService     = game:GetService("HttpService")

-- Modules
local PetsService     = require(ReplicatedStore.Modules.PetServices.PetsService)


-- =========================
-- LƯU / TẢI DỮ LIỆU GIFT UUID + VERIFIED2
-- =========================
local GIFT_FILE   = "gift_records.json"
-- GiftData[name] = { uuids = {...}, confirmed = number, verified2 = boolean }
local GiftData    = {}
local GiftPending = {}  -- { [playerName] = in_flight_count }
local firstSeen = {}   -- [playerName] = os.clock()

local function loadGiftData()
    if not (isfile and isfile(GIFT_FILE)) then return {} end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(GIFT_FILE))
    end)
    if ok and type(data) == "table" then
        for name, entry in pairs(data) do
            if type(entry) ~= "table" then
                data[name] = {uuids = {}, confirmed = 0, verified2 = false}
            else
                entry.uuids     = entry.uuids or {}
                entry.confirmed = tonumber(entry.confirmed or #entry.uuids) or 0
                entry.verified2 = not not entry.verified2
            end
        end
        return data
    else
        warn("[gift] ⚠️ Lỗi đọc gift_records.json, khởi tạo lại.")
        return {}
    end
end

local function saveGiftData()
    if not writefile then return end
    local ok, res = pcall(function()
        writefile(GIFT_FILE, HttpService:JSONEncode(GiftData))
    end)
    if not ok then
        warn("[gift] ⚠️ Ghi file gift_records.json lỗi:", res)
    end
end

GiftData = loadGiftData()

local function getGiftedCountFor(name)
    local entry = GiftData[name]
    if not entry then return 0 end
    return #(entry.uuids or {})
end

local function setVerified2(name, v)
    GiftData[name] = GiftData[name] or {uuids = {}, confirmed = 0, verified2 = false}
    GiftData[name].verified2 = not not v
    saveGiftData()
end

local function isVerified2(name)
    return GiftData[name] and GiftData[name].verified2 == true
end

local function addGiftedUUID(name, uuid)
    if not (name and uuid) then return end
    GiftData[name] = GiftData[name] or { uuids = {}, confirmed = 0, verified2 = false }
    local entry = GiftData[name]
    if not table.find(entry.uuids, uuid) then
        table.insert(entry.uuids, uuid)
        entry.confirmed = #entry.uuids
        saveGiftData()
    end
end

local function getPendingFor(name) return GiftPending[name] or 0 end
local function addPending(name, n) GiftPending[name] = getPendingFor(name) + (n or 1) end
local function subPending(name, n) GiftPending[name] = math.max(getPendingFor(name) - (n or 1), 0) end

-- =========================
-- HELPERS
-- =========================
local function parsePetFromName(name)
    if not name then return nil end
    local lname = name:lower()
    local kgStr  = lname:match("%[(%d+%.?%d*)%s*kg%]")
    local ageStr = lname:match("age%s*:?%s*(%d+)")
    if not kgStr then return nil end
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")
    return petName, tonumber(kgStr), ageStr and tonumber(ageStr) or nil
end

local function isUnvalidPet(petName)
    if not petName then return false end
    local lname = petName:lower()
    for _, bad in ipairs(unvalidToolNames) do
        if lname:find(bad:lower(), 1, true) then return true end
    end
    return false
end

local function qualifiesByCfg(petName, kg, age, cfg)
    if not petName or not kg then return false end
    if cfg.name_pet then
        if not petName:lower():find(cfg.name_pet:lower(), 1, true) then return false end
    else
        if isUnvalidPet(petName) then return false end
    end
    if cfg.min_weight and kg < cfg.min_weight then return false end
    if age == nil then
        -- nếu không đọc được age: chỉ pass khi đang unequip_Pet (giữ nguyên rule cũ của bạn)
        return cfg.unequip_Pet == true
    end
    return (age >= (cfg.min_age or -1)) and (age < (cfg.max_age or math.huge))
end

local function getActivePetScrollingFrame()
    local activeUI = player.PlayerGui:WaitForChild("ActivePetUI", 5)
    if not activeUI then return nil end
    local ok, scrolling = pcall(function()
        return activeUI:WaitForChild("Frame")
                       :WaitForChild("Main")
                       :WaitForChild("PetDisplay")
                       :WaitForChild("ScrollingFrame")
    end)
    return (ok and scrolling) and scrolling or nil
end

local function unequipPetsByConfig(cfg)
    if not cfg.unequip_Pet then return end
    local scrolling = getActivePetScrollingFrame()
    if not scrolling then return end
    local function findLabel(frame, name) return frame:FindFirstChild(name, true) end

    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if not (petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$")) then continue end
        local nameLabel = findLabel(petFrame, "PET_TYPE")
        local ageLabel  = findLabel(petFrame, "PET_AGE")
        local wtLabel   = findLabel(petFrame, "PET_WEIGHT")

        local petType = nameLabel and nameLabel.Text or nil
        local age     = ageLabel and tonumber(ageLabel.Text:match("(%d+)")) or nil
        local weight  = nil
        if wtLabel and wtLabel.Text then
            local w = wtLabel.Text:match("(%d+%.?%d*)%s*[Kk][Gg]")
            weight = w and tonumber(w) or nil
        end
        if not petType then continue end

        local nameOK   = (cfg.name_pet == nil) or petType:lower():find(cfg.name_pet:lower(), 1, true)
        local weightOK = (not cfg.min_weight) or (weight and weight >= cfg.min_weight) or (weight == nil)
        local ageOK
        if age == nil then ageOK = cfg.unequip_Pet else ageOK = (age >= cfg.min_age and age < cfg.max_age) end

        if nameOK and ageOK and weightOK then
            pcall(function() PetsService:UnequipPet(petFrame.Name) end)
        end
    end
end

local function findBackpackToolByUUID(uuid)
    if not uuid then return nil end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local tUuid = tool:GetAttribute("PET_UUID")
            if tUuid == uuid then return tool end
        end
    end
    return nil
end

local function isPetInBackpack(uuid)
    return findBackpackToolByUUID(uuid) ~= nil
end

-- Đếm trong Backpack của target xem có bao nhiêu pet thỏa cfg
local function countQualifiedInPlayerBackpack(targetPlayer, cfg)
    if not (targetPlayer and targetPlayer:IsDescendantOf(Players)) then return 0 end
    local bp = targetPlayer:FindFirstChild("Backpack")
    if not bp then return 0 end
    local cnt = 0
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, kg, age = parsePetFromName(tool.Name)
            if qualifiesByCfg(petName, kg, age, cfg) then
                cnt += 1
            end
        end
    end
    return cnt
end

-- Đếm số tool có PET_UUID trong backpack (chính mình) để kick watcher
local function countMyBackpackPetsByUUID()
    local n = 0
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("PET_UUID") then
            n += 1
        end
    end
    return n
end

-- Chờ xác nhận biến mất (gift thành công khi UUID biến khỏi backpack của mình)
local function waitGiftConfirmed(uuid, timeoutSec)
    local t0 = os.clock()
    timeoutSec = timeoutSec or 45
    while os.clock() - t0 < timeoutSec do
        if not findBackpackToolByUUID(uuid) then
            return true
        end
        task.wait(0.5)
    end
    return false
end

local function getTool(name_pet, min_age, max_age, min_weight, unequip_Pet)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, kg, age = parsePetFromName(tool.Name)
            if petName and kg then
                local nameOK   = (not name_pet) or petName:lower():find(name_pet:lower(), 1, true)
                local weightOK = (not min_weight) or (kg >= min_weight)
                local ageOK
                if age == nil then ageOK = unequip_Pet else ageOK = (age >= min_age and age < max_age) end
                if (name_pet or not isUnvalidPet(petName)) and nameOK and ageOK and weightOK then
                    return tool
                end
            end
        end
    end
    return nil
end

local function giftPetToPlayer(targetPlayerName)
    local args = { "GivePet", Players:WaitForChild(targetPlayerName) }
    ReplicatedStore.GameEvents.PetGiftingService:FireServer(unpack(args))
end

-- =========================
-- KHI LOAD XONG: XÁC MINH LẠI CÁC UUID CŨ & LAYER-2 NẾU NGƯỜI ĐÓ ONLINE
-- =========================
task.spawn(function()
    task.wait(3)
    print("🔄 Kiểm tra lại UUID + layer-2 cho người đang online...")
    local changed = false
    for name, entry in pairs(GiftData) do
        if typeof(entry) == "table" then
            entry.uuids     = entry.uuids or {}
            entry.confirmed = tonumber(entry.confirmed or #entry.uuids) or 0
            entry.verified2 = not not entry.verified2
            local target = Players:FindFirstChild(name)
            if target then
                -- Cập nhật confirmed (loại UUID vẫn còn trong backpack của mình)
                local before = #entry.uuids
                local validList = {}
                for _, uuid in ipairs(entry.uuids) do
                    if not isPetInBackpack(uuid) then
                        table.insert(validList, uuid)
                    else
                        print(("⚠️ %s: UUID %s vẫn còn trong backpack (gift chưa thành công, loại).")
                            :format(name, uuid))
                    end
                end
                entry.uuids = validList
                entry.confirmed = #validList

                -- Với mỗi block cfg có playerlist chứa name → check layer-2
                for _, cfg in ipairs(DataGetTool) do
                    local limit = tonumber(cfg.limit_pet) or math.huge
                    if cfg.playerlist and table.find(cfg.playerlist, name) then
                        local have = countQualifiedInPlayerBackpack(target, cfg)
                        if have >= limit then
                            if not entry.verified2 then
                                entry.verified2 = true
                                print(("🟢 Layer-2 OK cho %s (%d/%d)."):format(name, have, limit))
                            end
                        else
                            if entry.verified2 then
                                print(("🟡 Layer-2 reset %s (chỉ có %d/%d)."):format(name, have, limit))
                            end
                            entry.verified2 = false
                        end
                    end
                end

                if (#validList ~= before) or changed then
                    changed = true
                end
            end
        end
    end
    if changed then saveGiftData() end
    print("✅ Hoàn tất kiểm tra khởi động.")
end)

-- =========================
-- NHẬN DIỆN “NGƯỜI NHẬN” & KICK WATCHER
-- =========================
local function startKickWatcher(waitSec)
    task.spawn(function()
        local poll = tonumber(waitSec) or 20
        local baseline = countMyBackpackPetsByUUID()
        local hasEverIncreased = false
        while true do
            task.wait(poll)
            local cur = countMyBackpackPetsByUUID()
            if cur > baseline then
                hasEverIncreased = true
                baseline = cur
                print(("[kick_after_done] 📈 PET_UUID count increased to %d"):format(cur))
            elseif cur == baseline then
                if hasEverIncreased then
                    player:Kick(("Không nhận được pet nào trong %ds dừng lại ở %d"):format(poll, cur))
                    return
                else
                    print(("[kick_after_done] ⏳ Waiting for first increase... (current=%d)"):format(cur))
                end
            else
                baseline = cur
                print(("[kick_after_done] 📉 PET_UUID count decreased to %d (no kick)."):format(cur))
            end
        end
    end)
end

local isReceiver = false
do
    for _, cfg in ipairs(DataGetTool) do
        if cfg.playerlist and table.find(cfg.playerlist, player.Name) then
            isReceiver = true
            if cfg.kick_after_done then
                startKickWatcher(tonumber(cfg.wait_before_kick) or 20)
            end
        end
    end
end

if isReceiver then
    print("🟢 Receiver mode: chỉ chạy kick_after_done watcher(s), không auto gift.")
    return
end

-- =========================
-- Vòng lặp chính (Auto Gift) với 3 phase
-- =========================
while true do
    task.wait(0.5)
    if not auto_gift then
        task.wait(3600)
        continue
    end

    for _, cfg in ipairs(DataGetTool) do
        if cfg.unequip_Pet then
            unequipPetsByConfig(cfg)
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if not (cfg.playerlist and table.find(cfg.playerlist, p.Name)) then
                continue
            end

            local limit        = tonumber(cfg.limit_pet) or math.huge
            local giftedSoFar  = getGiftedCountFor(p.Name)
            local pendingSoFar = getPendingFor(p.Name)

            -- Nếu đã khóa layer-2 rồi thì bỏ qua luôn cho nhẹ
            if isVerified2(p.Name) then
                -- print(("[skip] %s đã verified2, bỏ qua."):format(p.Name))
                continue
            end

            if not firstSeen[p.Name] then
                firstSeen[p.Name] = true
                print("⏳ Đợi 10s cho " .. p.Name .. " load đầy đủ...")
                task.wait(10)
            end

            -- LAYER-2 CỨNG: nếu backpack người nhận đã đủ thì khóa luôn, không cần phase
            local qualifiedNow = countQualifiedInPlayerBackpack(p, cfg)
            if qualifiedNow >= limit then
                if not isVerified2(p.Name) then
                    print(("🟢 %s đã đủ pet thỏa cấu hình (%d/%d). Ghi nhận layer-2."):format(
                        p.Name, qualifiedNow, limit))
                    setVerified2(p.Name, true)
                end
                continue
            end

            -- =====================
            -- PHASE 1: BƠM GIFT CHO ĐỦ LIMIT THEO SỔ SÁCH
            -- Chỉ quan tâm gifted + pending, KHÔNG dựa vào have để gift bù
            -- =====================
            if giftedSoFar + pendingSoFar < limit then
                local tool = getTool(cfg.name_pet, cfg.min_age, cfg.max_age, cfg.min_weight, cfg.unequip_Pet)
                if tool then
                    -- check lại nhanh layer-2 tránh race trong lúc lấy tool
                    qualifiedNow = countQualifiedInPlayerBackpack(p, cfg)
                    if qualifiedNow >= limit then
                        if not isVerified2(p.Name) then
                            print(("🟢 %s đã đủ ngay trước khi gửi (%d/%d) → ghi nhận layer-2."):format(
                                p.Name, qualifiedNow, limit))
                            setVerified2(p.Name, true)
                        end
                        continue
                    end

                    local uuid = tool:GetAttribute("PET_UUID")
                    if not uuid then
                        warn("[gift] Tool thiếu PET_UUID, bỏ qua: ", tool.Name)
                        continue
                    end

                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        pcall(function() hum:EquipTool(tool) end)
                    end

                    addPending(p.Name, 1)
                    giftPetToPlayer(p.Name)

                    task.spawn(function(targetName, petUUID, limitForName, cfgLocal)
                        local okDisappear = waitGiftConfirmed(petUUID, 45)
                        if okDisappear then
                            addGiftedUUID(targetName, petUUID)
                            print(("[limit] ✅ %s: %d/%s (gift confirmed)"):format(
                                targetName, getGiftedCountFor(targetName), tostring(limitForName)))

                            -- Sau khi confirm, kiểm tra layer-2 lần nữa (chỉ set flag, không gift)
                            local targetPlr = Players:FindFirstChild(targetName)
                            if targetPlr then
                                local have2 = countQualifiedInPlayerBackpack(targetPlr, cfgLocal)
                                if have2 >= (tonumber(cfgLocal.limit_pet) or math.huge) then
                                    if not isVerified2(targetName) then
                                        print(("🟢 Layer-2 đạt sau confirm cho %s (%d/%d) → khóa."):format(
                                            targetName, have2, tonumber(cfgLocal.limit_pet) or math.huge))
                                        setVerified2(targetName, true)
                                    end
                                end
                            end
                        else
                            warn(("[limit] ⏳ %s: Chưa xác nhận pet biến mất (không cộng số lượng)."):format(targetName))
                        end
                        subPending(targetName, 1)
                    end, p.Name, uuid, limit, cfg)
                else
                    -- Không tìm thấy tool hợp lệ cho p, bỏ qua vòng này
                    -- warn("[autoPickup] Không tìm thấy tool hợp lệ cho", p.Name)
                end

                -- Sau khi xử lý Phase 1 (dù có gift hay không), move on sang player tiếp theo
                continue
            end

            -- =====================
            -- PHASE 2: ĐÃ ĐỦ THEO SỔ SÁCH NHƯNG CÒN PENDING
            -- → CHỈ CHỜ XÁC NHẬN, KHÔNG GIFT, KHÔNG LAYER-2
            -- =====================
            if pendingSoFar > 0 then
                -- print(("[wait] %s đang có %d pending, chờ confirm xong rồi mới layer-2."):format(
                --     p.Name, pendingSoFar))
                continue
            end

            -- =====================
            -- PHASE 3: gifted + pending >= limit VÀ pending = 0
            -- Lúc này mới check layer-2 thật sự để khóa hoặc gift bù ở vòng sau
            -- =====================
            local have = countQualifiedInPlayerBackpack(p, cfg)
            if have >= limit then
                print(("[L2] 🟢 %s đủ %d/%d, khóa layer-2."):format(p.Name, have, limit))
                setVerified2(p.Name, true)
                continue
            else
                local need = math.max(limit - have, 0)
                print(("[L2] 🟡 %s chỉ có %d/%d, thiếu %d. Những vòng sau sẽ gift bù (khi gifted+pending < limit).")
                    :format(p.Name, have, limit, need))
                -- Không chỉnh GiftData ở đây.
                -- Khi có gift fail hoặc các vòng sau, gifted+pending sẽ < limit → Phase 1 tự động gift bù.
            end
        end
    end
end

