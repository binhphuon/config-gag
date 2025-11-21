-- wait game
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

-- Modules
local DataService do
    local ok, mod = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DataService"))
    end)
    if ok then DataService = mod end
end
local PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService)

-- ================= CONFIG =================
-- MỤC TIÊU SLOT (có thể chỉnh tuỳ ý, script sẽ KHÔNG nâng quá mốc này)
local WANTED_PET_SLOT = 7
local WANTED_EGG_SLOT = 3
local GAME_SLOT_CAP   = 8

WANTED_PET_SLOT = math.clamp(WANTED_PET_SLOT, 0, GAME_SLOT_CAP)
WANTED_EGG_SLOT = math.clamp(WANTED_EGG_SLOT, 0, GAME_SLOT_CAP)

-- Chia bucket tuổi
local REQUIRE = {
    mid_age_min  = 20,
    mid_age_max  = 75, -- mid: [20, 75)
    high_age_min = 75, -- high: [75, +∞)
}

local unvalidToolNames = {
    "Capybara","Ostrich","Griffin","Golden Goose","Dragonfly",
    "Mimic Octopus","Red Fox","French Fry Ferret","Cockatrice"
}

local SAME_PET_RETRY_LIMIT = 2
local UNCHANGED_MAX_RETRY  = 2
local RANDOM_UNEQUIP_DELAY = 2.0
local DELAY_BETWEEN_USES   = 1.0
-- ==========================================

-- Helpers
local function isBlacklisted(petName)
    if not petName then return false end
    local ln = petName:lower()
    for _, bad in ipairs(unvalidToolNames) do
        if ln:find(bad:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function parsePetFromName(name)
    if not name then return end
    local lower = name:lower()
    local age = tonumber(lower:match("age%s*:?%s*(%d+)"))
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")
    return petName, age
end

local function getPetMaxSlotFromUI()
    local pg = player:FindFirstChildOfClass("PlayerGui"); if not pg then return 0 end
    local tl = pg:FindFirstChild("ActivePetUI", true)
    if not tl then return 0 end
    tl = tl:FindFirstChild("Frame", true); if not tl then return 0 end
    tl = tl:FindFirstChild("Title", true)
    if not tl then return 0 end
    local _, mx = tl.Text:match("Active Pets:%s*(%d+)%s*/%s*(%d+)")
    return tonumber(mx or "0") or 0
end

local function getEggMaxSlotFromDataService()
    if not DataService then return 0 end
    local ok, data = pcall(function() return DataService:GetData() end)
    if ok and type(data) == "table" then
        local pets = data.PetsData or {}
        local mutable = pets.MutableStats or {}
        return tonumber(mutable.MaxEggsInFarm or 0) or 0
    end
    return 0
end

local function getHRPCFrame()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    return hrp.CFrame
end

-- 🔹 Unequip toàn bộ Tool đang cầm trên tay → đưa về Backpack
local function unequipAllHeldTools()
    local char = player.Character or player.CharacterAdded:Wait()
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:UnequipTools() end)
    end

    -- đảm bảo không còn Tool nằm trong Character
    for _, inst in ipairs(char:GetChildren()) do
        if inst:IsA("Tool") then
            inst.Parent = player.Backpack
        end
    end
end

-- Lấy list Tool có PET_UUID trong Backpack + Character
local function getAllToolsWithUUID()
    local out = {}
    local char = player.Character

    local function collectFrom(container)
        if not container then return end
        for _, inst in ipairs(container:GetChildren()) do
            if inst:IsA("Tool") then
                local uuid = inst:GetAttribute("PET_UUID")
                if uuid and typeof(uuid) == "string" then
                    table.insert(out, {tool = inst, uuid = uuid, name = inst.Name})
                end
            end
        end
    end

    collectFrom(player.Backpack)
    collectFrom(char)

    return out
end

----------------------------------------------------
-- 🔥 COUNT PET AGE BUCKETS (mid & high) – Backpack + tay cầm
----------------------------------------------------
local function countAgeBuckets()
    local mid, high = 0, 0
    local char = player.Character

    local function countFrom(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local petName, age = parsePetFromName(tool.Name)
                if petName and age and not isBlacklisted(petName) then
                    if age >= REQUIRE.high_age_min then
                        high += 1
                    elseif age >= REQUIRE.mid_age_min and age < REQUIRE.mid_age_max then
                        mid += 1
                    end
                end
            end
        end
    end

    countFrom(player.Backpack)
    countFrom(char)

    return mid, high
end

----------------------------------------------------
-- 🔥 decideAgeRangeForSlot: giữ logic cũ
----------------------------------------------------
local function decideAgeRangeForSlot(maxSlot)
    if maxSlot >= GAME_SLOT_CAP then return nil, nil end
    if maxSlot == 3 then return 20, 75 end
    if maxSlot == 4 then return 30, 75 end
    if maxSlot == 5 then return 45, 75 end
    if maxSlot == 6 then return 60, 75 end
    if maxSlot == 7 then return 75, 101 end
    -- nhỏ hơn 3
    return 20, 75
end

----------------------------------------------------
-- 🔥 TÍNH SỐ PET CẦN CHO TOÀN BỘ HÀNH TRÌNH → mid / high
----------------------------------------------------
local function computeRequiredCounts(petMax, eggMax)
    local neededMid, neededHigh = 0, 0

    local function addForRange(minA, maxA)
        if not minA then return end
        if minA >= REQUIRE.high_age_min then
            neededHigh += 1
        else
            neededMid  += 1
        end
    end

    -- Pet slot từ hiện tại → WANTED_PET_SLOT
    for s = petMax, WANTED_PET_SLOT - 1 do
        local minA, maxA = decideAgeRangeForSlot(s)
        addForRange(minA, maxA)
    end

    -- Egg slot từ hiện tại → WANTED_EGG_SLOT
    for s = eggMax, WANTED_EGG_SLOT - 1 do
        local minA, maxA = decideAgeRangeForSlot(s)
        addForRange(minA, maxA)
    end

    return neededMid, neededHigh
end

local function hasEnoughPetsForUpgrade()
    local petMax = getPetMaxSlotFromUI()
    local eggMax = getEggMaxSlotFromDataService()

    local needMid, needHigh = computeRequiredCounts(petMax, eggMax)

    -- Nếu không cần nâng gì nữa thì coi như đạt
    if needMid == 0 and needHigh == 0 then
        print("[Gate] 🎯 Không cần thêm pet (slot đã đạt mục tiêu).")
        return true
    end

    local mid, high = countAgeBuckets()
    local ok = (mid >= needMid) and (high >= needHigh)

    local msgFmt = "[Gate] %s PET: mid=%d/%d, high=%d/%d"
    if ok then
        print(string.format(msgFmt, "✅ ĐỦ", mid, needMid, high, needHigh))
    else
        print(string.format(msgFmt, "❌ THIẾU", mid, needMid, high, needHigh))
    end

    return ok
end

----------------------------------------------------
-- 🔥 PRE-LOOP: CHỜ ĐỦ PET TRƯỚC KHI BEGIN
----------------------------------------------------
print("[Gate] 🔍 Đang tính toán và kiểm tra điều kiện pet trước khi nâng slot...")

while true do
    if hasEnoughPetsForUpgrade() then
        print("[Gate] 🚀 Đã đủ pet → bắt đầu nâng slot!")
        break
    end
    task.wait(2)
end

task.wait(3)

----------------------------------------------------
-- 🔥 MAIN UPGRADE LOGIC
----------------------------------------------------
local lastPick = {uuid=nil, count=0}
local unchangedCounter = {Pet = 0, Egg = 0}
local lastSeenMax      = {Pet = 0, Egg = 0}

local function pickCandidate(candidates)
    table.sort(candidates, function(a,b) return a.age > b.age end)
    if #candidates == 0 then return nil end
    local first = candidates[1]

    if lastPick.uuid ~= first.uuid then
        lastPick.uuid = first.uuid
        lastPick.count = 1
        return first
    end

    if lastPick.count < SAME_PET_RETRY_LIMIT then
        lastPick.count += 1
        return first
    end

    for i = 2, #candidates do
        if candidates[i].uuid ~= lastPick.uuid then
            lastPick.uuid = candidates[i].uuid
            lastPick.count = 1
            print(("[Pick] 🔀 Đổi sang pet khác UUID=%s (tránh lặp)"):format(lastPick.uuid))
            return candidates[i]
        end
    end

    lastPick.count += 1
    return first
end

-- Tìm pet hợp lệ theo tuổi trong Backpack + tay cầm
local function findPetForUpgrade(ageMin, ageMax)
    local cand = {}
    local char = player.Character

    local function collectFrom(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local petName, age = parsePetFromName(tool.Name)
                if petName and age and not isBlacklisted(petName) then
                    if age >= ageMin and age < ageMax then
                        local uuid = tool:GetAttribute("PET_UUID")
                        if uuid and typeof(uuid) == "string" then
                            table.insert(cand, {tool=tool, uuid=uuid, name=petName, age=age})
                        end
                    end
                end
            end
        end
    end

    collectFrom(player.Backpack)
    collectFrom(char)

    return pickCandidate(cand)
end

local function unlockSlotWithPet(uuid, slotType)
    local ok, err = pcall(function()
        ReplicatedStorage.GameEvents.UnlockSlotFromPet:FireServer(uuid, slotType)
    end)
    if not ok then
        warn("[Upgrade] UnlockSlotFromPet lỗi:", err)
    end
    return ok
end

local function bumpIfUnchanged(kind, curMax)
    if lastSeenMax[kind] == curMax then
        unchangedCounter[kind] += 1
    else
        unchangedCounter[kind] = 0
        lastSeenMax[kind] = curMax
    end

    if unchangedCounter[kind] >= UNCHANGED_MAX_RETRY then
        print("[Bump] "..kind.." slot không đổi → equip random + unequip")
        local list = getAllToolsWithUUID()
        if #list > 0 then
            local pick = list[math.random(1,#list)]
            PetsService:EquipPet(pick.uuid, getHRPCFrame())
            task.wait(RANDOM_UNEQUIP_DELAY)
            PetsService:UnequipPet(pick.uuid)
        else
            warn("[Bump] Không tìm thấy pet nào có PET_UUID để equip random.")
        end
        unchangedCounter[kind] = 0
    end
end

local function tryUpgradeOne(kind)
    unequipAllHeldTools()
    task.wait(0.1)

    local targetMax = (kind == "Pet") and WANTED_PET_SLOT or WANTED_EGG_SLOT
    local maxNow = (kind == "Pet") and getPetMaxSlotFromUI() or getEggMaxSlotFromDataService()
    print(("[Upgrade] %s slot hiện tại: %d / %d"):format(kind, maxNow, targetMax))

    if maxNow >= targetMax then
        print(("[Upgrade] %s đã đạt mục tiêu."):format(kind))
        return true
    end

    local minA, maxA = decideAgeRangeForSlot(maxNow)
    if not minA then
        print(("[Upgrade] Không có age range hợp lệ cho %s (slot=%d)"):format(kind, maxNow))
        return true
    end

    local pet = findPetForUpgrade(minA, maxA)
    if not pet then
        print("[Upgrade] Không tìm thấy pet hợp lệ cho "..kind)
        bumpIfUnchanged(kind, maxNow)
        return false
    end

    unequipAllHeldTools()
    task.wait(0.05)

    unlockSlotWithPet(pet.uuid, kind)
    task.wait(DELAY_BETWEEN_USES)

    local newMax = (kind == "Pet") and getPetMaxSlotFromUI() or getEggMaxSlotFromDataService()
    if newMax > maxNow then
        unchangedCounter[kind] = 0
        lastSeenMax[kind] = newMax
        print(("[Upgrade] 🎉 %s slot tăng: %d → %d"):format(kind, maxNow, newMax))
        return true
    else
        print(("[Upgrade] ⏸ %s slot chưa đổi (%d)"):format(kind, maxNow))
        bumpIfUnchanged(kind, maxNow)
        return false
    end
end

----------------------------------------------------
-- 🔥 MAIN LOOP
----------------------------------------------------
while true do
    task.wait(1)

    local petMax = getPetMaxSlotFromUI()
    if petMax < WANTED_PET_SLOT then
        tryUpgradeOne("Pet")
        task.wait(2)
        continue
    end

    local eggMax = getEggMaxSlotFromDataService()
    if eggMax < WANTED_EGG_SLOT then
        tryUpgradeOne("Egg")
        task.wait(2)
        continue
    end

    print(("[Upgrade] ✅ Hoàn tất: Pet=%d/%d, Egg=%d/%d → nghỉ 1h")
        :format(petMax, WANTED_PET_SLOT, eggMax, WANTED_EGG_SLOT))
    task.wait(3600)
end
