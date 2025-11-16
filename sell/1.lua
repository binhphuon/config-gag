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
local firstSeen   = {}  -- [playerName] = true nếu đã delay lần đầu

-- Kế hoạch gift: AssignedGifts[playerName][uuid] = { startTime, lastSend }
local AssignedGifts = {}
local PENDING_RETRY_INTERVAL = 5 -- giây giữa các lần gửi lại pet đang trong plan

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

local function ensureEntry(name)
    GiftData[name] = GiftData[name] or {uuids = {}, confirmed = 0, verified2 = false}
    local e = GiftData[name]
    e.uuids     = e.uuids or {}
    e.confirmed = tonumber(e.confirmed or #e.uuids) or 0
    e.verified2 = not not e.verified2
    return e
end

local function setVerified2(name, v)
    local e = ensureEntry(name)
    e.verified2 = not not v
    saveGiftData()
end

local function isVerified2(name)
    return GiftData[name] and GiftData[name].verified2 == true
end

local function addGiftedUUID(name, uuid)
    if not (name and uuid) then return end
    local e = ensureEntry(name)
    if not table.find(e.uuids, uuid) then
        table.insert(e.uuids, uuid)
        e.confirmed = #e.uuids
        saveGiftData()
    end
end

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
        -- nếu không đọc được age: chỉ pass khi đang unequip_Pet (rule cũ)
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
    timeoutSec = timeoutSec or 120
    while os.clock() - t0 < timeoutSec do
        if not findBackpackToolByUUID(uuid) then
            return true
        end
        task.wait(0.5)
    end
    return false
end

local function giftPetToPlayer(targetPlayerName)
    local args = { "GivePet", Players:WaitForChild(targetPlayerName) }
    ReplicatedStore.GameEvents.PetGiftingService:FireServer(unpack(args))
end

-- =========================
-- TRACK MỖI UUID TRONG PLAN
-- =========================
local function trackUUID(targetName, uuid, cfgLocal, limitForName)
    task.spawn(function()
        local okDisappear = waitGiftConfirmed(uuid, 120)
        if okDisappear then
            addGiftedUUID(targetName, uuid)
            print(("[limit] ✅ %s: %d/%s (gift confirmed)")
                :format(targetName, getGiftedCountFor(targetName), tostring(limitForName)))

            -- Sau khi confirm, kiểm tra layer-2 (khóa nếu đã đủ)
            local targetPlr = Players:FindFirstChild(targetName)
            if targetPlr then
                local have2 = countQualifiedInPlayerBackpack(targetPlr, cfgLocal)
                local limitCfg = tonumber(cfgLocal.limit_pet) or math.huge
                if have2 >= limitCfg then
                    if not isVerified2(targetName) then
                        print(("🟢 Layer-2 đạt sau confirm cho %s (%d/%d) → khóa.")
                            :format(targetName, have2, limitCfg))
                        setVerified2(targetName, true)
                    end
                end
            end
        else
            warn(("[limit] ⏳ %s: UUID %s timeout, không xác nhận pet biến mất.")
                :format(targetName, tostring(uuid)))
        end

        -- Dù sao cũng xóa khỏi plan
        local m = AssignedGifts[targetName]
        if m then
            m[uuid] = nil
            if next(m) == nil then
                AssignedGifts[targetName] = nil
            end
        end
    end)
end

-- =========================
-- KHI LOAD XONG: DỌN FILE CŨ & LAYER-2 NẾU NGƯỜI ĐÓ ONLINE
-- =========================
task.spawn(function()
    task.wait(3)
    print("🔄 Kiểm tra lại UUID cũ + layer-2 cho người đang online...")
    local changed = false
    for name, entry in pairs(GiftData) do
        if typeof(entry) == "table" then
            ensureEntry(name)
            local target = Players:FindFirstChild(name)
            if target then
                -- Loại các UUID vẫn còn trong backpack của mình (gift fail từ trước)
                local before = #entry.uuids
                local validList = {}
                for _, uuid in ipairs(entry.uuids) do
                    if not isPetInBackpack(uuid) then
                        table.insert(validList, uuid)
                    else
                        print(("⚠️ %s: UUID %s vẫn còn trong backpack (gift chưa thành công trước đó, loại).")
                            :format(name, uuid))
                    end
                end
                entry.uuids = validList
                entry.confirmed = #validList
                if #validList ~= before then
                    changed = true
                end

                -- Check layer-2 theo Backpack hiện tại
                for _, cfg in ipairs(DataGetTool) do
                    local limit = tonumber(cfg.limit_pet) or math.huge
                    if cfg.playerlist and table.find(cfg.playerlist, name) then
                        local have = countQualifiedInPlayerBackpack(target, cfg)
                        if have >= limit then
                            if not entry.verified2 then
                                entry.verified2 = true
                                print(("🟢 Layer-2 OK cho %s (%d/%d)."):format(name, have, limit))
                                changed = true
                            end
                        else
                            if entry.verified2 then
                                print(("🟡 Layer-2 reset %s (chỉ có %d/%d)."):format(name, have, limit))
                                entry.verified2 = false
                                changed = true
                            end
                        end
                    end
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
-- Vòng lặp chính (Auto Gift) – dựa trên kế hoạch UUID
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

            local limit         = tonumber(cfg.limit_pet) or math.huge
            local giftedLifetime = getGiftedCountFor(p.Name)
            local assignedMap   = AssignedGifts[p.Name]

            if isVerified2(p.Name) then
                -- Người này đã khóa layer-2 → khỏi tính
                AssignedGifts[p.Name] = nil
                continue
            end

            -- Lần đầu gặp player trong config → delay 10s cho load Backpack/UI
            if not firstSeen[p.Name] then
                firstSeen[p.Name] = true
                print(("⏳ Đợi 10s cho %s load đầy đủ..."):format(p.Name))
                task.wait(10)
            end

            -- Gom lại kế hoạch hiện tại: chỉ giữ UUID nào tool còn trong backpack
            local assignedCount = 0
            if assignedMap then
                for uuid, info in pairs(assignedMap) do
                    if not findBackpackToolByUUID(uuid) then
                        assignedMap[uuid] = nil
                    else
                        assignedCount += 1
                    end
                end
                if next(assignedMap) == nil then
                    AssignedGifts[p.Name] = nil
                    assignedMap = nil
                end
            end

            -- Số pet hiện có bên người nhận (chỉ để log & layer-2)
            local haveNow = countQualifiedInPlayerBackpack(p, cfg)

            -- Nếu lifetime gifted đã >= limit → không assign thêm UUID mới.
            local effectiveGifted = math.min(giftedLifetime, limit)

            -- Số slot còn có thể tạo plan mới, bị chặn bởi cả limit lẫn nhu cầu hiện tại
            local maxByCap      = limit - (effectiveGifted + assignedCount)
            local maxByBackpack = limit - (haveNow + assignedCount)
            local canAssignNew  = math.max(math.min(maxByCap, maxByBackpack), 0)

            if canAssignNew > 0 then
                print(("[PLAN] 📋 %s: have=%d, gifted=%d, assigned=%d, limit=%d → có thể chọn thêm %d UUID.")
                    :format(p.Name, haveNow, giftedLifetime, assignedCount, limit, canAssignNew))
                AssignedGifts[p.Name] = AssignedGifts[p.Name] or {}
                assignedMap = AssignedGifts[p.Name]

                -- Chọn thêm đúng canAssignNew UUID đủ điều kiện trong backpack mình
                for _, tool in ipairs(player.Backpack:GetChildren()) do
                    if canAssignNew <= 0 then break end
                    if tool:IsA("Tool") then
                        local petName, kg, age = parsePetFromName(tool.Name)
                        if petName and kg and qualifiesByCfg(petName, kg, age, cfg) then
                            local uuid = tool:GetAttribute("PET_UUID")
                            if uuid and not assignedMap[uuid] then
                                assignedMap[uuid] = {
                                    startTime = os.clock(),
                                    lastSend  = 0,
                                }

                                -- Gửi lần đầu
                                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    pcall(function() hum:EquipTool(tool) end)
                                end
                                giftPetToPlayer(p.Name)
                                assignedMap[uuid].lastSend = os.clock()

                                print(("[send] ✉️ Lần đầu gửi %s (%s) cho %s.")
                                    :format(tool.Name, tostring(uuid), p.Name))

                                -- Bật thread theo dõi confirm cho UUID này
                                trackUUID(p.Name, uuid, cfg, limit)

                                canAssignNew -= 1
                                assignedCount += 1
                            end
                        end
                    end
                end
            end

            -- Bước spam lại: chỉ gửi lại các UUID đã có trong plan
            assignedMap = AssignedGifts[p.Name]
            if assignedMap then
                for uuid, info in pairs(assignedMap) do
                    local tool = findBackpackToolByUUID(uuid)
                    if not tool then
                        -- Tool đã biến → thread trackUUID sẽ dọn
                        assignedMap[uuid] = nil
                    else
                        local now  = os.clock()
                        local last = info.lastSend or 0
                        if now - last >= PENDING_RETRY_INTERVAL then
                            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                            if hum then
                                pcall(function() hum:EquipTool(tool) end)
                            end
                            giftPetToPlayer(p.Name)
                            info.lastSend = now

                            local elapsed   = now - info.startTime
                            local remaining = math.max(0, 120 - elapsed)
                            print(("[retry] 🔁 Gửi lại pet %s (%s) cho %s | đã chờ %.1fs, còn %.1fs timeout")
                                :format(tool.Name, tostring(uuid), p.Name, elapsed, remaining))
                        end
                    end
                end
                if next(assignedMap) == nil then
                    AssignedGifts[p.Name] = nil
                end
            end

            -- Layer-2 hard check: nếu giờ đã đủ limit trong backpack → khóa
            local haveAfter = countQualifiedInPlayerBackpack(p, cfg)
            if haveAfter >= limit and not isVerified2(p.Name) then
                print(("[L2] 🟢 %s hiện có %d/%d → khóa layer-2.")
                    :format(p.Name, haveAfter, limit))
                setVerified2(p.Name, true)
                AssignedGifts[p.Name] = nil
            end
        end
    end
end
