-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20slot.lua"))()

-- Đợi game & LocalPlayer
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local StarterGui         = game:GetService("StarterGui")
local player             = Players.LocalPlayer

-- Modules
local DataService
pcall(function()
    DataService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DataService"))
end)

-- ===== Config chống lặp lại cùng 1 pet =====
local ATTEMPT_LIMIT          = 2        -- Nếu cùng 1 PET_UUID bị thử >= số lần này, ưu tiên đổi sang pet khác
local RECENT_BUFFER_SIZE     = 3        -- Nhớ vài UUID gần nhất để tránh chọn lại ngay lập tức
local COOLDOWN_AFTER_FAIL    = 0.5      -- chờ nhẹ sau khi không unlock được

local AttemptCount = {}                 -- [uuid] = số lần đã thử
local RECENT_UUID  = { Pet = {}, Egg = {} }  -- nhớ các uuid vừa dùng theo slotType

local function pushRecent(kind, uuid)
    local buf = RECENT_UUID[kind]
    if not buf then return end
    table.insert(buf, 1, uuid)
    if #buf > RECENT_BUFFER_SIZE then
        table.remove(buf) -- bỏ phần tử cuối
    end
end
local function inRecent(kind, uuid)
    local buf = RECENT_UUID[kind]
    if not buf then return false end
    for _, u in ipairs(buf) do if u == uuid then return true end end
    return false
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

-- Thu thập toàn bộ ứng viên hợp lệ trong backpack
local function collectCandidates(ageMin, ageMax)
    local list = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, _, age = parsePetFromName(tool.Name)
            if petName and not isBlacklisted(petName) and age then
                local ok = (ageMax == math.huge) and (age >= ageMin) or ((age >= ageMin) and (age < ageMax))
                if ok then
                    local uuid = tool:GetAttribute("PET_UUID")
                    if uuid and typeof(uuid) == "string" then
                        table.insert(list, {tool = tool, uuid = uuid, age = age, name = petName})
                    end
                end
            end
        end
    end
    -- sắp xếp ưu tiên age giảm dần
    table.sort(list, function(a,b) return (a.age or 0) > (b.age or 0) end)
    return list
end

-- Chọn candidate theo luật: tránh uuid trong RECENT, tránh uuid đã vượt ATTEMPT_LIMIT
local function pickCandidate(list, kind)
    if #list == 0 then return nil end

    -- ưu tiên: attempt < limit và không nằm trong RECENT buffer
    for _, c in ipairs(list) do
        local tries = AttemptCount[c.uuid] or 0
        if tries < ATTEMPT_LIMIT and not inRecent(kind, c.uuid) then
            return c
        end
    end
    -- nếu không có ai < limit, thử ai không trong RECENT
    for _, c in ipairs(list) do
        if not inRecent(kind, c.uuid) then
            return c
        end
    end
    -- không còn lựa chọn, lấy con có attempt nhỏ nhất
    local best, bestTries = nil, math.huge
    for _, c in ipairs(list) do
        local tries = AttemptCount[c.uuid] or 0
        if tries < bestTries then
            best, bestTries = c, tries
        end
    end
    return best
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

-- Quy tắc mới theo slot hiện tại
local function decideAgeRangeForSlot(maxSlot)
    if maxSlot >= 8 then return nil, nil end
    if maxSlot == 3 then return 20, 75 end
    if maxSlot == 4 then return 30, 75 end
    if maxSlot == 5 then return 45, 75 end
    if maxSlot == 6 then return 60, 75 end
    if maxSlot == 7 then return 75, 101 end
    -- nhỏ hơn 3 => dùng mốc nhỏ nhất
    if maxSlot < 3 then return 20, 75 end
    return nil, nil
end

-- Thử nâng slot với anti-repeat
local function tryUpgradeOne(kind)
    local maxNow = (kind == "Pet") and getPetMaxSlotFromUI() or getEggMaxSlotFromDataService()
    print(("[Upgrade] %s slot hiện tại: %d"):format(kind, maxNow))
    if maxNow >= 8 then
        print(("[Upgrade] %s slot đã tối đa."):format(kind))
        return true
    end

    local minA, maxA = decideAgeRangeForSlot(maxNow)
    if not minA then return true end

    local candidates = collectCandidates(minA, maxA)
    if #candidates == 0 then
        local needStr = (maxA == math.huge) and (">= " .. minA) or (("%d-%d"):format(minA, maxA - 1))
        warn(("[Upgrade] Không có pet hợp lệ (lọc blacklist) để nâng %s: yêu cầu age %s")
            :format(kind, needStr))
        return false
    end

    local chosen = pickCandidate(candidates, kind)
    if not chosen then
        warn("[Upgrade] Không chọn được ứng viên nào (anti-repeat filter).")
        return false
    end

    print(("[Upgrade] Chọn pet: %s | Age=%d | UUID=%s (attempt=%d)")
        :format(chosen.name, chosen.age, chosen.uuid, (AttemptCount[chosen.uuid] or 0)))

    -- Đánh dấu và gửi
    AttemptCount[chosen.uuid] = (AttemptCount[chosen.uuid] or 0) + 1
    pushRecent(kind, chosen.uuid)

    local ok = unlockSlotWithPet(chosen.uuid, kind)
    if not ok then
        task.wait(COOLDOWN_AFTER_FAIL)
    end
    return ok
end

-- Main loop: ưu tiên Pet → Egg
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

    print("[Upgrade] ✅ Pet & Egg đều tối đa (8)")
    task.wait(3600)
end
