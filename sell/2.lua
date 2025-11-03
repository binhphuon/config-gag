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
-- LƯU / TẢI DỮ LIỆU GIFT UUID
-- =========================
local GIFT_FILE   = "gift_records.json"
local GiftData    = {}  -- { [playerName] = { uuids = {uuid1, uuid2, ...}, confirmed = n } }
local GiftPending = {}  -- { [playerName] = in_flight_count }

local function loadGiftData()
    if not (isfile and isfile(GIFT_FILE)) then return {} end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(GIFT_FILE))
    end)
    if ok and type(data) == "table" then
        for name, entry in pairs(data) do
            if type(entry) ~= "table" then
                data[name] = {uuids = {}, confirmed = 0}
            else
                entry.uuids = entry.uuids or {}
                entry.confirmed = tonumber(entry.confirmed or #entry.uuids) or 0
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

local function addGiftedUUID(name, uuid)
    if not (name and uuid) then return end
    GiftData[name] = GiftData[name] or { uuids = {}, confirmed = 0 }
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

-- Đếm số tool có PET_UUID trong backpack (coi là số pet)
local function countBackpackPetsByUUID()
    local n = 0
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("PET_UUID") then
            n += 1
        end
    end
    return n
end

-- Chờ xác nhận biến mất (gift thành công khi UUID biến khỏi backpack)
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

local function getTool(name_pet, min_age, max_age, min_weight, unequip_Pet)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, kg, age = parsePetFromName(tool.Name)
            if petName and kg then
                if (name_pet or not isUnvalidPet(petName)) then
                    local nameOK   = (not name_pet) or petName:lower():find(name_pet:lower(), 1, true)
                    local weightOK = (not min_weight) or (kg >= min_weight)
                    local ageOK
                    if age == nil then ageOK = unequip_Pet else ageOK = (age >= min_age and age < max_age) end
                    if nameOK and ageOK and weightOK then
                        return tool
                    end
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
-- KHI LOAD XONG: XÁC MINH LẠI CÁC UUID CŨ CHO NHỮNG NGƯỜI ĐANG ONLINE
-- =========================
task.spawn(function()
    task.wait(3)
    print("🔄 Kiểm tra lại các UUID đã lưu (nếu người đó đang trong server)...")
    local changed = false
    for name, entry in pairs(GiftData) do
        if typeof(entry) == "table" and entry.uuids and #entry.uuids > 0 then
            local target = Players:FindFirstChild(name)
            if target then
                local before = #entry.uuids
                local validList = {}
                for _, uuid in ipairs(entry.uuids) do
                    if not isPetInBackpack(uuid) then
                        table.insert(validList, uuid) -- đã gift thành công
                    else
                        print(("⚠️ %s: UUID %s vẫn còn trong backpack (gift chưa thành công, loại).")
                            :format(name, uuid))
                    end
                end
                entry.uuids = validList
                entry.confirmed = #validList
                if #validList ~= before then
                    changed = true
                    print(("♻️ Cập nhật %s: %d -> %d gift hợp lệ."):format(name, before, #validList))
                end
            end
        end
    end
    if changed then saveGiftData() end
    print("✅ Hoàn tất kiểm tra UUID cũ.")
end)

-- =========================
-- NHẬN DIỆN “NGƯỜI NHẬN” & CHẠY KICK WATCHER
-- =========================
-- Chỉ kick nếu đã từng tăng số pet (PET_UUID) ít nhất 1 lần
local function startKickWatcher(waitSec)
    task.spawn(function()
        local poll = tonumber(waitSec) or 20
        local baseline = countBackpackPetsByUUID()
        local hasEverIncreased = false

        while true do
            task.wait(poll)
            local cur = countBackpackPetsByUUID()

            if cur > baseline then
                -- ghi nhận đã có pet mới và cập nhật mốc so sánh
                hasEverIncreased = true
                baseline = cur
                print(("[kick_after_done] 📈 PET_UUID count increased to %d"):format(cur))

            elseif cur == baseline then
                -- chỉ kick nếu đã từng tăng trước đó mà giờ đứng yên
                if hasEverIncreased then
                    player:Kick(("Không nhận được pet nào trong %ds dừng lại ở %d")
                        :format(poll, cur))
                    return
                else
                    -- chưa có lần tăng nào → tiếp tục chờ
                    print(("[kick_after_done] ⏳ Waiting for first increase... (current=%d)"):format(cur))
                end

            else -- cur < baseline (giảm)
                -- cập nhật baseline nhưng không kick; có thể do bạn sử dụng/di chuyển pet
                baseline = cur
                print(("[kick_after_done] 📉 PET_UUID count decreased to %d (no kick)."):format(cur))
            end
        end
    end)
end

-- Nếu LocalPlayer nằm trong bất kỳ block nào → là người nhận
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

-- Nếu là người nhận → KHÔNG chạy auto gift
if isReceiver then
    print("🟢 Receiver mode: chỉ chạy kick_after_done watcher(s), không auto gift.")
    return
end

-- =========================
-- Vòng lặp chính (CHỈ CHẠY KHI KHÔNG PHẢI NGƯỜI NHẬN)
-- =========================
while true do
    task.wait(1)
    if not auto_gift then task.wait(3600); continue end

    for _, cfg in ipairs(DataGetTool) do
        if cfg.unequip_Pet then
            unequipPetsByConfig(cfg)
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if table.find(cfg.playerlist, p.Name) then
                local limit        = tonumber(cfg.limit_pet) or math.huge
                local giftedSoFar  = getGiftedCountFor(p.Name)
                local pendingSoFar = getPendingFor(p.Name)

                -- 🔁 Nếu đã đạt limit_pet → xác minh lại các UUID cũ
                if giftedSoFar + pendingSoFar >= limit then
                    print(("🧩 %s đã đạt limit_pet (%d). Đang kiểm tra lại UUID cũ..."):format(p.Name, limit))
                    local entry = GiftData[p.Name]
                    if entry and entry.uuids and #entry.uuids > 0 then
                        local before = #entry.uuids
                        local validList = {}
                        for _, uuid in ipairs(entry.uuids) do
                            if not isPetInBackpack(uuid) then
                                table.insert(validList, uuid)
                            else
                                print(("⚠️ %s: UUID %s vẫn còn trong backpack (gift chưa thành công, loại).")
                                    :format(p.Name, uuid))
                            end
                        end
                        entry.uuids = validList
                        entry.confirmed = #validList
                        if #validList ~= before then
                            print(("♻️ Cập nhật lại %s: %d -> %d gift hợp lệ."):format(p.Name, before, #validList))
                            saveGiftData()
                        end
                    end

                    giftedSoFar = getGiftedCountFor(p.Name)
                    if giftedSoFar + pendingSoFar >= limit then
                        print(("🚫 %s vẫn đang ở giới hạn gift (%d/%d). Bỏ qua."):format(p.Name, giftedSoFar, limit))
                        continue
                    end
                end

                -- 🎁 Tiếp tục quy trình gift
                local tool = getTool(cfg.name_pet, cfg.min_age, cfg.max_age, cfg.min_weight, cfg.unequip_Pet)
                if tool then
                    local uuid = tool:GetAttribute("PET_UUID")
                    if not uuid then
                        warn("[gift] Tool thiếu PET_UUID, bỏ qua: ", tool.Name)
                        continue
                    end

                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(tool) end) end

                    addPending(p.Name, 1)
                    giftPetToPlayer(p.Name)

                    task.spawn(function(targetName, petUUID, limitForName)
                        local okDisappear = waitGiftConfirmed(petUUID, 120)
                        if okDisappear then
                            addGiftedUUID(targetName, petUUID)
                            print(("[limit] ✅ %s: %d/%s (gift confirmed)")
                                :format(targetName, getGiftedCountFor(targetName), tostring(limitForName)))
                        else
                            warn(("[limit] ⏳ %s: Chưa xác nhận pet biến mất (không cộng số lượng)."):format(targetName))
                        end
                        subPending(targetName, 1)
                    end, p.Name, uuid, limit)
                else
                    -- warn("[autoPickup] Không tìm thấy tool hợp lệ cho", p.Name)
                end
            end
        end
    end
end
