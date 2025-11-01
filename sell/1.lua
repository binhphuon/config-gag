-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer
local HttpService     = game:GetService("HttpService")

-- Modules
local PetsService     = require(ReplicatedStore.Modules.PetServices.PetsService)


-- ============ LƯU / TẢI ĐẾM ============
local GIFT_FILE = "gift_counts.txt"
local GiftCount   = {}  -- { [playerName] = confirmed_count }
local GiftPending = {}  -- { [playerName] = in_flight_count }

local function loadGiftCounts()
    GiftCount = {}
    if isfile and isfile(GIFT_FILE) then
        local content = readfile(GIFT_FILE)
        for line in content:gmatch("[^\r\n]+") do
            local name, cnt = line:match("^(.-)%-(%d+)$")
            if name and cnt then GiftCount[name] = tonumber(cnt) end
        end
    end
end
local function saveGiftCounts()
    if not writefile then return end
    local lines = {}
    for name, cnt in pairs(GiftCount) do
        table.insert(lines, ("%s-%d"):format(name, cnt))
    end
    writefile(GIFT_FILE, table.concat(lines, "\n"))
end
local function getGiftedCountFor(name) return GiftCount[name] or 0 end
local function incGiftedCountFor(name, delta)
    delta = delta or 1
    GiftCount[name] = (GiftCount[name] or 0) + delta
    saveGiftCounts()
end
local function getPendingFor(name) return GiftPending[name] or 0 end
local function addPending(name, n) GiftPending[name] = getPendingFor(name) + (n or 1) end
local function subPending(name, n)
    GiftPending[name] = math.max(getPendingFor(name) - (n or 1), 0)
end
pcall(loadGiftCounts)

-- ============ HELPERS ============
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

-- Tìm tool trong Backpack theo PET_UUID
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

-- Chờ xác nhận biến mất (gift thành công)
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
-- Vòng lặp chính
-- =========================
while true do
    task.wait(1)
    if not auto_gift then task.wait(3600); continue end

    for _, cfg in ipairs(DataGetTool) do
        -- 1) Unequip theo block nếu cần
        if cfg.unequip_Pet then unequipPetsByConfig(cfg) end

        -- 2) Duyệt player trong server
        for _, p in ipairs(Players:GetPlayers()) do
            if table.find(cfg.playerlist, p.Name) then
                local limit        = tonumber(cfg.limit_pet) or math.huge
                local giftedSoFar  = getGiftedCountFor(p.Name)
                local pendingSoFar = getPendingFor(p.Name)

                -- Tránh vượt limit khi gift song song
                if giftedSoFar + pendingSoFar >= limit then
                    -- print(("[limit] %s: %d confirmed + %d pending >= %d → skip"):format(p.Name, giftedSoFar, pendingSoFar, limit))
                    continue
                end

                -- 3) Chọn tool theo cfg
                local tool = getTool(cfg.name_pet, cfg.min_age, cfg.max_age, cfg.min_weight, cfg.unequip_Pet)
                if tool then
                    local uuid = tool:GetAttribute("PET_UUID")
                    if not uuid then
                        warn("[gift] Tool thiếu PET_UUID, bỏ qua: ", tool.Name)
                        continue
                    end

                    -- (4) Equip rồi gửi gift
                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(tool) end) end

                    -- Tăng pending trước khi gửi
                    addPending(p.Name, 1)

                    giftPetToPlayer(p.Name)

                    -- (5) Xác nhận gift KHÔNG CHẶN vòng chính
                    task.spawn(function(targetName, petUUID, limitForName)
                        local okDisappear = waitGiftConfirmed(petUUID, 120)
                        if okDisappear then
                            incGiftedCountFor(targetName, 1)
                            print(("[limit] ✅ %s: %d/%s (gift confirmed)")
                                :format(targetName, getGiftedCountFor(targetName), tostring(limitForName)))
                        else
                            warn(("[limit] ⏳ %s: Chưa xác nhận pet biến mất (không cộng số lượng)."):format(targetName))
                        end
                        -- Giảm pending dù thành công hay không
                        subPending(targetName, 1)
                    end, p.Name, uuid, limit)
                else
                    -- Không có tool thỏa
                    -- warn("[autoPickup] Không tìm thấy tool hợp lệ cho", p.Name)
                end
            end
        end
    end
end
