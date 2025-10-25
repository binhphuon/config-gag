-- Đợi game & LocalPlayer
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local StarterGui         = game:GetService("StarterGui")
local player             = Players.LocalPlayer

-- Modules: cố gắng require DataService theo 2 đường dẫn phổ biến
local DataService
pcall(function()
    DataService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DataService"))
end)
if not DataService then
    pcall(function()
        DataService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DataService"))
    end)
end

-- ===== Blacklist pet (không dùng các pet này để nâng slot) =====
local unvalidToolNames = {
    "Capybara", "Ostrich", "Griffin", "Golden Goose", "Dragonfly",
    "Mimic Octopus", "Red Fox", "French Fry Ferret", "Cockatrice"
}
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
-- ===============================================================

-- Parse tên pet: trả petName, kg (number), age (number|nil)
local function parsePetFromName(name)
    if not name then return nil end
    local lower = name:lower()
    local kg  = tonumber((lower:match("%[(%d+%.?%d*)%s*kg%]") or "0"))
    local age = tonumber(lower:match("age%s*:?%s*(%d+)"))
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")
    return petName, kg, age
end

-- Đọc max PET slot từ UI "Active Pets: cur/max"
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

-- Đọc max EGG slot từ DataService
local function getEggMaxSlotFromDataService()
    if not DataService then return 0 end
    local ok, data = pcall(function() return DataService:GetData() end)
    if not ok or type(data) ~= "table" then return 0 end
    local pets = data.PetsData or {}
    local mutable = pets.MutableStats or {}
    return tonumber(mutable.MaxEggsInFarm or 0) or 0
end

-- Tìm 1 pet trong Backpack theo khoảng tuổi và KHÔNG thuộc blacklist.
-- Ưu tiên age cao nhất trong khoảng để “đỡ phí”.
-- Trả về: tool, uuidString (đã có ngoặc nhọn)
local function findPetForUpgrade(ageMin, ageMax)
    local best
    local bestAge = -1
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, _, age = parsePetFromName(tool.Name)
            if petName and (not isBlacklisted(petName)) and age then
                local okInRange
                if ageMax == math.huge then
                    okInRange = (age >= ageMin)
                else
                    okInRange = (age >= ageMin) and (age < ageMax)
                end
                if okInRange and age > bestAge then
                    local uuid = tool:GetAttribute("PET_UUID")
                    if uuid and typeof(uuid) == "string" then
                        best = { tool = tool, uuid = uuid, age = age, name = petName }
                        bestAge = age
                    end
                end
            end
        end
    end
    if best then
        print(("[Upgrade] Chọn pet: %s | Age=%d | UUID=%s"):format(best.name, best.age, best.uuid))
        return best.tool, best.uuid
    end
    return nil, nil
end

-- Gọi Remote nâng slot
local function unlockSlotWithPet(uuidStr, slotType) -- slotType: "Pet" | "Egg"
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

-- Rule tuổi theo mức slot hiện tại
local function decideAgeRangeForSlot(maxSlot)
    -- <7 => [60,75) ; ==7 => [75, +inf) ; >=8 => nil
    if maxSlot >= 8 then return nil, nil end
    if maxSlot < 7 then return 60, 75 end
    return 75, math.huge
end

-- Thử nâng 1 lần cho loại slot (ưu tiên PET trước khi gọi trong main)
local function tryUpgradeOne(kind) -- "Pet" | "Egg"
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
        return false
    end

    return unlockSlotWithPet(uuidStr, kind)
end

-- Main loop: ưu tiên Pet trước, sau đó Egg (không dùng goto/label)
while true do
    task.wait(2)

    -- 1) Ưu tiên nâng PET
    local petMax = getPetMaxSlotFromUI()
    if petMax < 8 then
        tryUpgradeOne("Pet")
        task.wait(3)      -- chờ server cập nhật UI/DataService
        continue
    end

    -- 2) PET max → thử nâng EGG
    local eggMax = getEggMaxSlotFromDataService()
    if eggMax < 8 then
        tryUpgradeOne("Egg")
        task.wait(3)
        continue
    end

    -- 3) Cả hai đều max
    print("[Upgrade] ✅ Pet & Egg đều tối đa (8). Nghỉ 10s.")
    task.wait(3600)
end
