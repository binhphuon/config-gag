-- wait game
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
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
local unvalidToolNames = { "Capybara","Ostrich","Griffin","Golden Goose","Dragonfly",
                           "Mimic Octopus","Red Fox","French Fry Ferret","Cockatrice" }

local SAME_PET_RETRY_LIMIT = 2     -- chọn trúng cùng 1 pet nhiều lần liên tiếp thì ép đổi pet khác
local UNCHANGED_MAX_RETRY  = 2     -- thử nâng slot tối đa N lần mà slot không đổi thì bump (equip random 2s rồi unequip)
local RANDOM_UNEQUIP_DELAY = 2.0   -- delay sau khi equip random trước khi unequip
local DELAY_BETWEEN_USES   = 1.0   -- delay giữa các lần gọi Equip/Unlock
-- ==========================================

-- Helpers
local function isBlacklisted(petName)
    if not petName then return false end
    local ln = petName:lower()
    for _, bad in ipairs(unvalidToolNames) do
        if ln:find(bad:lower(), 1, true) then return true end
    end
    return false
end

-- Parse tên pet: return petName, kg(number), age(number|nil)
local function parsePetFromName(name)
    if not name then return nil end
    local lower = name:lower()
    local kg  = tonumber((lower:match("%[(%d+%.?%d*)%s*kg%]") or "0"))
    local age = tonumber(lower:match("age%s*:?%s*(%d+)"))
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")
    return petName, kg, age
end

-- UI: "Active Pets: cur/max" → lấy max pet slot
local function getPetMaxSlotFromUI()
    local pg = player:FindFirstChildOfClass("PlayerGui"); if not pg then return 0 end
    local tl = pg:FindFirstChild("ActivePetUI", true)
    if not tl then return 0 end
    tl = tl:FindFirstChild("Frame", true); if not tl then return 0 end
    tl = tl:FindFirstChild("Title", true)
    if not (tl and tl:IsA("TextLabel")) then return 0 end
    local _, mx = tl.Text:match("Active Pets:%s*(%d+)%s*/%s*(%d+)")
    return tonumber(mx or "0") or 0
end

-- DataService: đọc max egg slot
local function getEggMaxSlotFromDataService()
    if not DataService then return 0 end
    local ok, data = pcall(function() return DataService:GetData() end)
    if not ok or type(data) ~= "table" then return 0 end
    local pets = data.PetsData or {}
    local mutable = pets.MutableStats or {}
    return tonumber(mutable.MaxEggsInFarm or 0) or 0
end

-- Lấy HRP CFrame gần hiện tại (dùng equip pet)
local function getHRPCFrame()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    return hrp and hrp.CFrame or CFrame.new()
end

-- Thu toàn bộ Tool có PET_UUID trong backpack
local function getAllToolsWithUUID()
    local out = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local uuid = tool:GetAttribute("PET_UUID")
            if uuid and typeof(uuid) == "string" then
                table.insert(out, {tool=tool, uuid=uuid, name=tool.Name})
            end
        end
    end
    return out
end

-- Equip ngẫu nhiên 1 pet rồi đợi RANDOM_UNEQUIP_DELAY → unequip lại
local function equipRandomThenUnequip()
    local list = getAllToolsWithUUID()
    if #list == 0 then
        warn("[Bump] Không có tool nào có PET_UUID trong Backpack để equip random.")
        return false
    end
    local pick = list[math.random(1, #list)]
    local cf   = getHRPCFrame()

    local ok1, err1 = pcall(function()
        PetsService:EquipPet(pick.uuid, cf)
    end)
    if not ok1 then
        warn("[Bump] EquipPet random lỗi:", err1)
        return false
    end
    print(("[Bump] ✅ Equip random UUID=%s → chờ %.1fs rồi unequip"):format(pick.uuid, RANDOM_UNEQUIP_DELAY))
    task.wait(RANDOM_UNEQUIP_DELAY)

    local ok2, err2 = pcall(function()
        PetsService:UnequipPet(pick.uuid)
    end)
    if not ok2 then
        warn("[Bump] Unequip random lỗi:", err2)
        return false
    end
    print(("[Bump] 🔁 Đã unequip UUID=%s"):format(pick.uuid))
    return true
end

-- Chọn pet theo khoảng tuổi (ưu tiên tuổi lớn nhất) + tránh lặp 1 UUID quá nhiều lần
local lastPick = { uuid=nil, count=0 }
local function pickCandidate(candidates)
    -- candidates: { {tool, uuid, name, age}, ... } (đã lọc age và blacklist)
    table.sort(candidates, function(a,b) return (a.age or -1) > (b.age or -1) end)

    if #candidates == 0 then return nil end
    local first = candidates[1]
    if lastPick.uuid ~= first.uuid then
        -- chọn ứng viên tốt nhất
        lastPick.uuid = first.uuid
        lastPick.count = 1
        return first
    end

    -- nếu trùng ứng viên cũ
    if lastPick.count < SAME_PET_RETRY_LIMIT then
        lastPick.count += 1
        return first
    end

    -- quá giới hạn: ép đổi sang con khác nếu có
    for i = 2, #candidates do
        if candidates[i].uuid ~= lastPick.uuid then
            lastPick.uuid  = candidates[i].uuid
            lastPick.count = 1
            print(("[Pick] 🔀 Đổi sang pet khác UUID=%s (tránh lặp)"):format(lastPick.uuid))
            return candidates[i]
        end
    end

    -- không còn lựa chọn khác: đành dùng lại
    lastPick.count += 1
    return first
end

-- Tìm pet hợp lệ theo tuổi
local function findPetForUpgrade(ageMin, ageMax)
    local cand = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, _, age = parsePetFromName(tool.Name)
            if petName and age and (not isBlacklisted(petName)) then
                local okAge = (ageMax == math.huge) and (age >= ageMin) or ((age >= ageMin) and (age < ageMax))
                if okAge then
                    local uuid = tool:GetAttribute("PET_UUID")
                    if uuid and typeof(uuid) == "string" then
                        table.insert(cand, {tool=tool, uuid=uuid, name=petName, age=age})
                    end
                end
            end
        end
    end
    local pick = pickCandidate(cand)
    if pick then
        print(("[Upgrade] Chọn pet: %s | Age=%d | UUID=%s"):format(pick.name, pick.age, pick.uuid))
        return pick.tool, pick.uuid
    end
    return nil, nil
end

-- Gọi remote nâng slot
local function unlockSlotWithPet(uuidStr, slotType)
    local args = { uuidStr, slotType }
    local ok, err = pcall(function()
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("UnlockSlotFromPet"):FireServer(unpack(args))
    end)
    if ok then
        print(("[Upgrade] ✅ Gửi nâng slot %s bằng pet %s"):format(slotType, uuidStr))
    else
        warn(("[Upgrade] ❌ UnlockSlotFromPet lỗi: %s"):format(err))
    end
    return ok
end

-- Quy tắc theo max slot hiện tại → khoảng tuổi cần
local function decideAgeRangeForSlot(maxSlot)
    if maxSlot >= 8 then return nil, nil end
    if maxSlot == 3 then return 20, 75 end
    if maxSlot == 4 then return 30, 75 end
    if maxSlot == 5 then return 45, 75 end
    if maxSlot == 6 then return 60, 75 end
    if maxSlot == 7 then return 75, 101 end
    if maxSlot < 3 then return 20, 75 end
    return nil, nil
end

-- Nếu slot không đổi sau N lần thử → “bump” (equip random 2s rồi unequip)
local unchangedCounter = { Pet = 0, Egg = 0 }
local lastSeenMax      = { Pet = 0, Egg = 0 }

local function bumpIfUnchanged(kind, curMax)
    local last = lastSeenMax[kind] or 0
    if curMax == last then
        unchangedCounter[kind] = (unchangedCounter[kind] or 0) + 1
    else
        unchangedCounter[kind] = 0
        lastSeenMax[kind] = curMax
    end

    if unchangedCounter[kind] >= UNCHANGED_MAX_RETRY then
        print(("[Bump] %s slot đứng yên %d lần → Equip random rồi Unequip")
            :format(kind, unchangedCounter[kind]))
        equipRandomThenUnequip()
        unchangedCounter[kind] = 0
    end
end

-- Thử nâng 1 slot theo loại
local function tryUpgradeOne(kind)
    local maxNow = (kind == "Pet") and getPetMaxSlotFromUI() or getEggMaxSlotFromDataService()
    print(("[Upgrade] %s slot hiện tại: %d"):format(kind, maxNow))
    if maxNow >= 8 then
        print(("[Upgrade] %s slot đã tối đa."):format(kind))
        return true
    end

    local minA, maxA = decideAgeRangeForSlot(maxNow)
    if not minA then return true end

    local _, uuidStr = findPetForUpgrade(minA, maxA)
    if not uuidStr then
        local needStr = (maxA == math.huge) and (">= " .. minA) or (("%d-%d"):format(minA, maxA - 1))
        warn(("[Upgrade] Không có pet hợp lệ (lọc blacklist) để nâng %s: yêu cầu age %s")
            :format(kind, needStr))
        bumpIfUnchanged(kind, maxNow)
        return false
    end

    local ok = unlockSlotWithPet(uuidStr, kind)
    task.wait(DELAY_BETWEEN_USES)

    -- kiểm tra sau khi bắn remote
    local newMax = (kind == "Pet" and getPetMaxSlotFromUI()) or getEggMaxSlotFromDataService()
    if newMax and newMax > maxNow then
        print(("[Upgrade] 🎉 %s slot tăng: %d → %d"):format(kind, maxNow, newMax))
        lastSeenMax[kind] = newMax
        unchangedCounter[kind] = 0
        return true
    else
        print(("[Upgrade] ⏸ %s slot chưa đổi (%d)"):format(kind, maxNow))
        bumpIfUnchanged(kind, maxNow)
        return false
    end
end


-- ================= MAIN LOOP =================
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

    print("[Upgrade] ✅ Pet & Egg đều tối đa (8) — nghỉ 1h")
    task.wait(3600)

    continue
end
