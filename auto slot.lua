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
local REQUIRE = {
    mid_age_min     = 20,
    mid_age_max     = 75,
    high_age_min    = 75,

    need_mid_count  = 6,   -- yêu cầu tối thiểu pet age 20–74
    need_high_count = 2,   -- yêu cầu tối thiểu pet age >=75
}

local unvalidToolNames = { "Capybara","Ostrich","Griffin","Golden Goose","Dragonfly",
                           "Mimic Octopus","Red Fox","French Fry Ferret","Cockatrice" }

local SAME_PET_RETRY_LIMIT = 2
local UNCHANGED_MAX_RETRY  = 2
local RANDOM_UNEQUIP_DELAY = 2.0
local DELAY_BETWEEN_USES   = 1.0
-- ==========================================

-- Helpers
local function isBlacklisted(petName)
    if not petName then return false end
    for _, bad in ipairs(unvalidToolNames) do
        if petName:lower():find(bad:lower(), 1, true) then return true end
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
        return tonumber(data.PetsData.MutableStats.MaxEggsInFarm or 0) or 0
    end
    return 0
end

local function getHRPCFrame()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    return hrp.CFrame
end

local function getAllToolsWithUUID()
    local out = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and typeof(tool:GetAttribute("PET_UUID")) == "string" then
            table.insert(out, {tool = tool, uuid = tool:GetAttribute("PET_UUID")})
        end
    end
    return out
end

----------------------------------------------------
-- 🔥 COUNT PET AGE BUCKETS (mid & high)
----------------------------------------------------
local function countBackpackAgeBuckets()
    local mid, high = 0, 0
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        local petName, age = parsePetFromName(tool.Name)
        if petName and age and not isBlacklisted(petName) then
            if age >= REQUIRE.high_age_min then
                high += 1
            elseif age >= REQUIRE.mid_age_min and age < REQUIRE.mid_age_max then
                mid += 1
            end
        end
    end
    return mid, high
end

local function hasEnoughPetsForUpgrade()
    local mid, high = countBackpackAgeBuckets()
    local ok = (mid >= REQUIRE.need_mid_count) and (high >= REQUIRE.need_high_count)

    if ok then
        print(string.format("[Gate] ✅ ĐỦ PET: mid=%d/%d, high=%d/%d",
            mid, REQUIRE.need_mid_count,
            high, REQUIRE.need_high_count))
    else
        print(string.format("[Gate] ❌ Thiếu pet → mid=%d/%d, high=%d/%d",
            mid, REQUIRE.need_mid_count,
            high, REQUIRE.need_high_count))
    end

    return ok
end

----------------------------------------------------
-- 🔥 PRE-LOOP: CHỜ ĐỦ PET TRƯỚC KHI BEGIN
----------------------------------------------------
print("[Gate] 🔍 Đang kiểm tra điều kiện pet trước khi nâng slot...")

while true do
    if hasEnoughPetsForUpgrade() then
        print("[Gate] 🚀 Đã đủ pet → bắt đầu nâng slot!")
        break
    end

    task.wait(4)
end

----------------------------------------------------
-- 🔥 MAIN UPGRADE LOGIC (giữ nguyên như cũ của bạn)
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
            return candidates[i]
        end
    end

    lastPick.count += 1
    return first
end

local function findPetForUpgrade(ageMin, ageMax)
    local cand = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        local petName, age = parsePetFromName(tool.Name)
        if petName and age and not isBlacklisted(petName) then
            local okAge = (age >= ageMin and age < ageMax)
            if okAge then
                local uuid = tool:GetAttribute("PET_UUID")
                if uuid then
                    table.insert(cand, {tool=tool, uuid=uuid, name=petName, age=age})
                end
            end
        end
    end
    return pickCandidate(cand)
end

local function unlockSlotWithPet(uuid, slotType)
    local ok,err = pcall(function()
        ReplicatedStorage.GameEvents.UnlockSlotFromPet:FireServer(uuid, slotType)
    end)
    return ok
end

local function decideAgeRangeForSlot(maxSlot)
    if maxSlot >= 8 then return nil,nil end
    if maxSlot == 3 then return 20,75 end
    if maxSlot == 4 then return 30,75 end
    if maxSlot == 5 then return 45,75 end
    if maxSlot == 6 then return 60,75 end
    if maxSlot == 7 then return 75,101 end
    return 20,75
end

local function bumpIfUnchanged(kind, curMax)
    if lastSeenMax[kind] == curMax then
        unchangedCounter[kind] += 1
    else
        unchangedCounter[kind] = 0
        lastSeenMax[kind] = curMax
    end

    if unchangedCounter[kind] >= UNCHANGED_MAX_RETRY then
        print("[Bump] slot không đổi → equip random")
        local list = getAllToolsWithUUID()
        if #list > 0 then
            local pick = list[math.random(1,#list)]
            PetsService:EquipPet(pick.uuid, getHRPCFrame())
            task.wait(RANDOM_UNEQUIP_DELAY)
            PetsService:UnequipPet(pick.uuid)
        end
        unchangedCounter[kind] = 0
    end
end

local function tryUpgradeOne(kind)
    local maxNow = (kind=="Pet") and getPetMaxSlotFromUI() or getEggMaxSlotFromDataService()
    print("[Upgrade] "..kind.." slot="..maxNow)

    if maxNow >= 8 then
        print("[Upgrade] "..kind.." tối đa")
        return true
    end

    local minA,maxA = decideAgeRangeForSlot(maxNow)
    local pet = findPetForUpgrade(minA,maxA)
    if not pet then
        bumpIfUnchanged(kind, maxNow)
        return false
    end

    unlockSlotWithPet(pet.uuid, kind)
    task.wait(DELAY_BETWEEN_USES)

    local newMax = (kind=="Pet") and getPetMaxSlotFromUI() or getEggMaxSlotFromDataService()
    if newMax > maxNow then
        unchangedCounter[kind] = 0
        lastSeenMax[kind] = newMax
        print("[Upgrade] tăng slot!")
        return true
    else
        bumpIfUnchanged(kind, maxNow)
        return false
    end
end

----------------------------------------------------
-- 🔥 MAIN LOOP
----------------------------------------------------
while true do
    task.wait(2)

    local petMax = getPetMaxSlotFromUI()
    if petMax < 8 then
        tryUpgradeOne("Pet")
        task.wait(3)
        continue
    end

    local eggMax = getEggMaxSlotFromDataService()
    if eggMax < 8 then
        tryUpgradeOne("Egg")
        task.wait(3)
        continue
    end

    print("[Upgrade] Hoàn tất 8/8 → nghỉ 1h")
    task.wait(3600)
end
