-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- =========================
-- DEBUG TOÀN CỤC
-- =========================
local DEBUG = true  -- false nếu muốn tắt spam log

local function dbg(tag, msg, ...)
    if not DEBUG then return end
    if select("#", ...) > 0 then
        print(("[%s] "..msg):format(tag, ...))
    else
        print(("[%s] %s"):format(tag, msg))
    end
end

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

-- Kế hoạch gift: AssignedGifts[playerName][uuid] = { startTime, lastSend }
local AssignedGifts = {}
local PENDING_RETRY_INTERVAL = 5   -- giây giữa các lần gửi lại pet đang trong plan
local STALE_HAVE_TIMEOUT      = 60 -- 1 phút have không tăng thì sửa file & gift bù
local LastHave = {}               -- LastHave[playerName] = { have = number, lastChange = time }

local firstSeen = {}  -- [playerName] = true nếu đã delay lần đầu

local function loadGiftData()
    if not (isfile and isfile(GIFT_FILE)) then
        dbg("FILE", "Không tìm thấy %s, dùng bảng rỗng.", GIFT_FILE)
        return {}
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(GIFT_FILE))
    end)
    if ok and type(data) == "table" then
        dbg("FILE", "Đọc %s thành công.", GIFT_FILE)
        for name, entry in pairs(data) do
            if type(entry) ~= "table" then
                dbg("FILE", "Entry %s không hợp lệ, reset.", tostring(name))
                data[name] = {uuids = {}, confirmed = 0, verified2 = false}
            else
                entry.uuids     = entry.uuids or {}
                entry.confirmed = tonumber(entry.confirmed or #entry.uuids) or 0
                entry.verified2 = not not entry.verified2
            end
        end
        return data
    else
        warn("[FILE] ⚠️ Lỗi đọc "..GIFT_FILE..", khởi tạo lại.", data)
        return {}
    end
end

local function saveGiftData()
    if not writefile then
        dbg("FILE", "writefile không tồn tại, bỏ qua save.")
        return
    end
    local ok, res = pcall(function()
        writefile(GIFT_FILE, HttpService:JSONEncode(GiftData))
    end)
    if not ok then
        warn("[FILE] ⚠️ Ghi file "..GIFT_FILE.." lỗi:", res)
    else
        dbg("FILE", "Đã save %s.", GIFT_FILE)
    end
end

GiftData = loadGiftData()

local function ensureEntry(name)
    GiftData[name] = GiftData[name] or {uuids = {}, confirmed = 0, verified2 = false}
    local e = GiftData[name]
    e.uuids     = e.uuids or {}
    e.confirmed = tonumber(e.confirmed or #e.uuids) or 0
    e.verified2 = not not e.verified2
    return e
end

local function getGiftedCountFor(name)
    local entry = GiftData[name]
    if not entry then return 0 end
    return #(entry.uuids or {})
end

local function setVerified2(name, v)
    local e = ensureEntry(name)
    e.verified2 = not not v
    dbg("L2", "Set verified2 cho %s = %s.", name, tostring(e.verified2))
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
        dbg("FILE", "Thêm UUID %s cho %s, tổng=%d.", tostring(uuid), name, e.confirmed)
        saveGiftData()
    else
        dbg("FILE", "UUID %s của %s đã tồn tại, bỏ qua.", tostring(uuid), name)
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
        if lname:find(bad:lower(), 1, true) then
            dbg("FILTER", "Pet %s nằm trong blacklist (%s).", petName, bad)
            return true
        end
    end
    return false
end

local function qualifiesByCfg(petName, kg, age, cfg)
    if not petName or not kg then return false end
    if cfg.name_pet then
        if not petName:lower():find(cfg.name_pet:lower(), 1, true) then
            return false
        end
    else
        if isUnvalidPet(petName) then return false end
    end
    if cfg.min_weight and kg < cfg.min_weight then
        return false
    end
    if age == nil then
        -- nếu không đọc được age: chỉ pass khi đang unequip_Pet (rule cũ)
        return cfg.unequip_Pet == true
    end
    return (age >= (cfg.min_age or -1)) and (age < (cfg.max_age or math.huge))
end

local function getActivePetScrollingFrame()
    local activeUI = player.PlayerGui:WaitForChild("ActivePetUI", 5)
    if not activeUI then
        dbg("UI", "Không tìm thấy ActivePetUI.")
        return nil
    end
    local ok, scrolling = pcall(function()
        return activeUI:WaitForChild("Frame")
                       :WaitForChild("Main")
                       :WaitForChild("PetDisplay")
                       :WaitForChild("ScrollingFrame")
    end)
    if ok and scrolling then
        return scrolling
    end
    dbg("UI", "Không tìm được ScrollingFrame trong ActivePetUI.")
    return nil
end

local function unequipPetsByConfig(cfg)
    if not cfg.unequip_Pet then return end
    local scrolling = getActivePetScrollingFrame()
    if not scrolling then return end
    local function findLabel(frame, name) return frame:FindFirstChild(name, true) end

    dbg("UNEQ", "Bắt đầu unequip theo cfg.")

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
            dbg("UNEQ", "Unequip pet %s (age=%s, kg=%s).", petType, tostring(age), tostring(weight))
            pcall(function() PetsService:UnequipPet(petFrame.Name) end)
        end
    end
end

-- Tìm tool có PET_UUID trên người mình (Character + Backpack)
local function findToolOnSelfByUUID(uuid)
    if not uuid then return nil end

    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local tUuid = tool:GetAttribute("PET_UUID")
                if tUuid == uuid then
                    return tool
                end
            end
        end
    end

    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local tUuid = tool:GetAttribute("PET_UUID")
            if tUuid == uuid then
                return tool
            end
        end
    end

    return nil
end

local function isPetOnSelf(uuid)
    return findToolOnSelfByUUID(uuid) ~= nil
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

-- Chờ xác nhận biến mất (gift thành công khi UUID biến khỏi cả Character + Backpack)
local function waitGiftConfirmed(uuid, timeoutSec)
    local t0 = os.clock()
    timeoutSec = timeoutSec or 120
    dbg("WAIT", "Bắt đầu chờ confirm UUID %s, timeout=%ds.", tostring(uuid), timeoutSec)
    while os.clock() - t0 < timeoutSec do
        if not findToolOnSelfByUUID(uuid) then
            dbg("WAIT", "UUID %s đã biến khỏi người → confirm.", tostring(uuid))
            return true
        end
        task.wait(0.5)
    end
    dbg("WAIT", "UUID %s hết timeout %ds nhưng vẫn còn trên người.", tostring(uuid), timeoutSec)
    return false
end

local function giftPetToPlayer(targetPlayerName)
    dbg("SEND", "Fire GivePet tới %s.", targetPlayerName)
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
            dbg("limit", "%s: %d/%s (gift confirmed)", targetName, getGiftedCountFor(targetName), tostring(limitForName))

            -- Sau khi confirm, kiểm tra layer-2 (khóa nếu đã đủ)
            local targetPlr = Players:FindFirstChild(targetName)
            if targetPlr then
                local have2    = countQualifiedInPlayerBackpack(targetPlr, cfgLocal)
                local limitCfg = tonumber(cfgLocal.limit_pet) or math.huge
                if have2 >= limitCfg then
                    if not isVerified2(targetName) then
                        dbg("L2", "Layer-2 đạt sau confirm cho %s (%d/%d) → khóa.", targetName, have2, limitCfg)
                        setVerified2(targetName, true)
                    end
                else
                    dbg("L2", "Sau confirm %s mới có %d/%d, chưa khóa.", targetName, have2, limitCfg)
                end
            end
        else
            warn(("[limit] ⏳ %s: UUID %s timeout, không xác nhận pet biến mất."):format(targetName, tostring(uuid)))
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
    dbg("INIT", "🔄 Kiểm tra lại UUID cũ + layer-2 cho người đang online...")
    local changed = false
    for name, entry in pairs(GiftData) do
        if typeof(entry) == "table" then
            ensureEntry(name)
            local target = Players:FindFirstChild(name)
            if target then
                dbg("INIT", "Xử lý entry file cho %s.", name)
                -- Loại các UUID vẫn còn trên người (gift fail từ trước)
                local before    = #entry.uuids
                local validList = {}
                for _, uuid in ipairs(entry.uuids) do
                    if not isPetOnSelf(uuid) then
                        table.insert(validList, uuid)
                    else
                        dbg("INIT", "%s: UUID %s vẫn còn trên người (gift fail cũ, loại).", name, tostring(uuid))
                    end
                end
                entry.uuids     = validList
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
                                dbg("L2", "Layer-2 OK cho %s (%d/%d).", name, have, limit)
                                changed = true
                            end
                        else
                            if entry.verified2 then
                                dbg("L2", "Reset layer-2 %s (chỉ %d/%d).", name, have, limit)
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
    dbg("INIT", "✅ Hoàn tất kiểm tra khởi động.")
end)

-- =========================
-- NHẬN DIỆN “NGƯỜI NHẬN” & KICK WATCHER
-- =========================
local function startKickWatcher(waitSec)
    task.spawn(function()
        local poll      = tonumber(waitSec) or 20
        local baseline  = countMyBackpackPetsByUUID()
        local hasEverIncreased = false
        dbg("KICK", "Bắt đầu kick watcher (poll=%ds, baseline=%d).", poll, baseline)
        while true do
            task.wait(poll)
            local cur = countMyBackpackPetsByUUID()
            if cur > baseline then
                hasEverIncreased = true
                baseline = cur
                dbg("KICK", "📈 PET_UUID count increased to %d", cur)
            elseif cur == baseline then
                if hasEverIncreased then
                    player:Kick(("Không nhận được pet nào trong %ds dừng lại ở %d"):format(poll, cur))
                    return
                else
                    dbg("KICK", "⏳ Waiting for first increase... current=%d", cur)
                end
            else
                baseline = cur
                dbg("KICK", "📉 PET_UUID count decreased to %d (no kick).", cur)
            end
        end
    end)
end

local isReceiver = false
do
    for idx, cfg in ipairs(DataGetTool) do
        dbg("CFG", "Block cfg[%d]: limit_pet=%s, unequip=%s.", idx, tostring(cfg.limit_pet), tostring(cfg.unequip_Pet))
        if cfg.playerlist and table.find(cfg.playerlist, player.Name) then
            isReceiver = true
            dbg("CFG", "Player hiện tại (%s) nằm trong playerlist của cfg[%d].", player.Name, idx)
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

dbg("MAIN", "Sender mode bắt đầu chạy auto gift.")

-- =========================
-- Vòng lặp chính (Auto Gift)
-- =========================
while true do
    task.wait(0.5)
    if not auto_gift then
        dbg("MAIN", "auto_gift=false → ngủ 3600s.")
        task.wait(3600)
        continue
    end

    for cfgIndex, cfg in ipairs(DataGetTool) do
        local limit = tonumber(cfg.limit_pet) or math.huge
        local unlim = limit > 100

        dbg("CFG", "=== Xử lý cfg[%d] (limit=%s, unlimited=%s) ===",
            cfgIndex, tostring(cfg.limit_pet), tostring(unlim))

        if cfg.unequip_Pet then
            unequipPetsByConfig(cfg)
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if not (cfg.playerlist and table.find(cfg.playerlist, p.Name)) then
                dbg("LOOP", "Bỏ qua %s (không nằm trong playerlist cfg[%d]).", p.Name, cfgIndex)
                continue
            end

            -- Lần đầu gặp player trong config → delay 10s cho load Backpack/UI
            if not firstSeen[p.Name] then
                firstSeen[p.Name] = true
                dbg("INIT", "⏳ Đợi 10s cho %s load đầy đủ...", p.Name)
                task.wait(10)
            end

            if unlim then
                ----------------------------------------------------------------
                -- UNLIMITED MODE: limit_pet > 100
                ----------------------------------------------------------------
                dbg("UNL", "Bắt đầu cycle unlimited cho %s (limit=%s > 100).", p.Name, tostring(cfg.limit_pet))
                local chosen, petName, kg, age
                for _, tool in ipairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local n, w, a = parsePetFromName(tool.Name)
                        if n and w and qualifiesByCfg(n, w, a, cfg) then
                            chosen  = tool
                            petName = n
                            kg      = w
                            age     = a
                            break
                        end
                    end
                end

                if chosen then
                    local uuid = chosen:GetAttribute("PET_UUID")
                    dbg("UNL", "Gửi pet %s (kg=%.2f, age=%s, uuid=%s) cho %s.",
                        tostring(petName or chosen.Name),
                        tonumber(kg or 0),
                        tostring(age),
                        tostring(uuid),
                        p.Name)

                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        pcall(function() hum:EquipTool(chosen) end)
                    end
                    giftPetToPlayer(p.Name)
                else
                    dbg("UNL", "⚠️ Không tìm thấy pet phù hợp để gift cho %s.", p.Name)
                end

                -- không dùng limit, không layer-2 trong mode này
                continue
            end

            ----------------------------------------------------------------
            -- LIMITED MODE
            ----------------------------------------------------------------
            local giftedLifetime = getGiftedCountFor(p.Name)
            local assignedMap    = AssignedGifts[p.Name]

            if isVerified2(p.Name) then
                dbg("SKIP", "%s đã verified2, bỏ qua trong cfg[%d].", p.Name, cfgIndex)
                AssignedGifts[p.Name] = nil
                continue
            end

            -- Gom lại kế hoạch hiện tại: chỉ giữ UUID còn trên người
            local assignedCount = 0
            if assignedMap then
                for uuid, _ in pairs(assignedMap) do
                    if not findToolOnSelfByUUID(uuid) then
                        dbg("PLAN", "%s: UUID %s không còn trên người → remove khỏi plan.", p.Name, tostring(uuid))
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

            -- Số pet hiện có bên người nhận
            local haveNow = countQualifiedInPlayerBackpack(p, cfg)
            local now     = os.clock()

            -- Cập nhật LastHave cho player này
            do
                local info = LastHave[p.Name]
                if not info then
                    LastHave[p.Name] = { have = haveNow, lastChange = now }
                else
                    if haveNow ~= info.have then
                        dbg("FIX", "%s: have đổi từ %d → %d.", p.Name, info.have, haveNow)
                        info.have       = haveNow
                        info.lastChange = now
                    end
                end
            end

            -- 🕒 Nếu file ghi nhiều hơn thực tế, have không tăng trong 60s và không còn plan pending
            --     → cắt file xuống đúng haveNow để cho phép gift thêm.
            do
                local info = LastHave[p.Name]
                if info and haveNow < limit and assignedCount == 0 and giftedLifetime > haveNow then
                    local elapsed = now - info.lastChange
                    if elapsed >= STALE_HAVE_TIMEOUT then
                        local entry  = ensureEntry(p.Name)
                        local before = #entry.uuids
                        while #entry.uuids > haveNow do
                            table.remove(entry.uuids)
                        end
                        entry.confirmed = #entry.uuids
                        saveGiftData()
                        giftedLifetime = entry.confirmed

                        dbg("FIX",
                            "%s: Sau %.1fs have vẫn =%d/%d nhưng file có %d → cắt còn %d.",
                            p.Name, elapsed, haveNow, limit, before, entry.confirmed)
                    end
                end
            end

            -- ⚙️ Gift hiệu lực = min(giftedLifetime, haveNow, limit)
            local effectiveGifted = math.min(giftedLifetime, haveNow, limit)

            local maxByCap      = limit - (effectiveGifted + assignedCount)
            local maxByBackpack = limit - (haveNow      + assignedCount)
            local canAssignNew  = math.max(math.min(maxByCap, maxByBackpack), 0)

            dbg("PLAN", "%s: have=%d, gifted=%d (eff=%d), assigned=%d, limit=%d, canAssignNew=%d.",
                p.Name, haveNow, giftedLifetime, effectiveGifted, assignedCount, limit, canAssignNew)

            -- 🔹 Chọn thêm UUID mới nếu còn slot
            if canAssignNew > 0 then
                AssignedGifts[p.Name] = AssignedGifts[p.Name] or {}
                assignedMap = AssignedGifts[p.Name]

                for _, tool in ipairs(player.Backpack:GetChildren()) do
                    if canAssignNew <= 0 then break end
                    if tool:IsA("Tool") then
                        local petName2, kg2, age2 = parsePetFromName(tool.Name)
                        if petName2 and kg2 and qualifiesByCfg(petName2, kg2, age2, cfg) then
                            local uuid = tool:GetAttribute("PET_UUID")
                            if uuid and not assignedMap[uuid] then
                                assignedMap[uuid] = {
                                    startTime = os.clock(),
                                    lastSend  = 0,
                                }

                                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    pcall(function() hum:EquipTool(tool) end)
                                end
                                giftPetToPlayer(p.Name)
                                assignedMap[uuid].lastSend = os.clock()

                                dbg("SEND", "Lần đầu gửi %s [%s] cho %s.", tool.Name, tostring(uuid), p.Name)

                                -- Thread theo dõi confirm cho UUID này
                                trackUUID(p.Name, uuid, cfg, limit)

                                canAssignNew -= 1
                                assignedCount += 1
                            end
                        end
                    end
                end
            else
                dbg("INFO", "%s: Không thể chọn thêm UUID mới (have=%d, gifted=%d, assigned=%d, limit=%d).",
                    p.Name, haveNow, giftedLifetime, assignedCount, limit)
            end

            -- 🔁 Retry các UUID đang trong plan
            assignedMap = AssignedGifts[p.Name]
            if assignedMap then
                for uuid, info in pairs(assignedMap) do
                    local tool = findToolOnSelfByUUID(uuid)
                    if not tool then
                        dbg("PLAN", "%s: UUID %s biến mất khỏi người → bỏ khỏi plan.", p.Name, tostring(uuid))
                        assignedMap[uuid] = nil
                    else
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
                            dbg("RETRY", "Gửi lại %s (%s) cho %s | elapsed=%.1fs, còn %.1fs timeout.",
                                tool.Name, tostring(uuid), p.Name, elapsed, remaining)
                        end
                    end
                end
                if next(assignedMap) == nil then
                    AssignedGifts[p.Name] = nil
                end
            end

            -- 🔒 Layer-2 hard check: nếu giờ đã đủ limit trong backpack → khóa
            local haveAfter = countQualifiedInPlayerBackpack(p, cfg)
            if haveAfter >= limit and not isVerified2(p.Name) then
                dbg("L2", "%s hiện có %d/%d → khóa layer-2.", p.Name, haveAfter, limit)
                setVerified2(p.Name, true)
                AssignedGifts[p.Name] = nil
            else
                dbg("L2", "%s hiện có %d/%d → chưa đủ để khóa.", p.Name, haveAfter, limit)
            end
        end
    end
end
