-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/zcreatefilecc88.lua"))()

-- ===== INFO LIVE EXTRACT & UPDATE -info.json =====
-- (Phiên bản có parse Sheckles dạng StringValue như "2.8T", "27.6QA", ...)

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

-- ===== FILES =====
local username     = player.Name
local userId       = player.UserId
local userInfoFile = tostring(userId) .. "-info.json"
local giftKeepFile = "gift_records.json"

-- ===== CONFIG: mốc và so sánh =====
local CONFIG = {
    money = { target = 20,  op = "~=" },   -- true nếu khác 20
    total_pet = { target = 2, op = "<=" },
    slot = {
        pet = { target = 8, op = ">=" },
        egg = { target = 8, op = ">=" },
        all_required = true
    }
}

-- ===== JSON helper =====
local function safeJSONDecode(s)
    local ok, data = pcall(function() return HttpService:JSONDecode(s) end)
    if ok and type(data) == "table" then return data end
    return nil
end
local function readJsonFile(fileName)
    if isfile and isfile(fileName) then
        local content = readfile(fileName)
        return safeJSONDecode(content)
    end
    return nil
end
local function writeJsonFile(fileName, data)
    if not writefile then return end
    local encoded = HttpService:JSONEncode(data)
    writefile(fileName, encoded)
end

-- Cleanup JSON
local function cleanupJsonFiles()
    if not listfiles then return end
    local files = listfiles("")
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local base = file:match("[^/\\]+$")
            if base ~= userInfoFile and base ~= giftKeepFile then
                if delfile then delfile(base) end
            end
        end
    end
end

local function ensureUserInfoDefaults()
    local info = readJsonFile(userInfoFile) or {}
    local changed = false
    if info.total_pet == nil then info.total_pet = false; changed = true end
    if info.slot      == nil then info.slot      = false; changed = true end
    if info.money     == nil then info.money     = false; changed = true end
    if changed then writeJsonFile(userInfoFile, info) end
end

local function updateIfChanged(key, newVal)
    local info = readJsonFile(userInfoFile) or {}
    if info[key] ~= newVal then
        local old = info[key]
        info[key] = newVal
        writeJsonFile(userInfoFile, info)
        print(("[update] %s: %s -> %s"):format(key, tostring(old), tostring(newVal)))
    end
end

-- ===== COMPARATORS =====
local function meets(op, value, target)
    if value == nil or target == nil then return false end
    if op == ">=" then return value >= target end
    if op == ">"  then return value >  target end
    if op == "==" then return value == target end
    if op == "<=" then return value <= target end
    if op == "<"  then return value <  target end
    if op == "~=" then return value ~= target end
    return value >= target
end

-- ===== HÀM ĐỌC LIVE DATA =====

-- 🔹 Bảng quy đổi hậu tố Sheckles
local suffixes = {
    K  = 1e3, M  = 1e6, B  = 1e9, T  = 1e12,
    QA = 1e15, QI = 1e18, SX = 1e21
}

-- 🔹 Parse StringValue như "2.8T" → 2800000000000
local function parseShecklesString(str)
    if not str or type(str) ~= "string" then return 0 end
    str = str:upper():gsub(",", ""):gsub("%s+", "")
    local num, suffix = str:match("([%d%.]+)([A-Z]+)")
    if num then
        num = tonumber(num) or 0
        local mult = suffixes[suffix] or 1
        return math.floor(num * mult)
    else
        return tonumber(str) or 0
    end
end

-- 🔹 Lấy tiền từ LocalPlayer.leaderstats.Sheckles
local function getSheckles()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return 0 end
    local shecklesVal = leaderstats:FindFirstChild("Sheckles")
    if shecklesVal and shecklesVal:IsA("StringValue") then
        return parseShecklesString(shecklesVal.Value)
    end
    return 0
end

-- 🔹 Kiểm tra Tool có phải pet không
local function isPetTool(inst)
    return inst and inst:IsA("Tool") and type(inst:GetAttribute("PET_UUID")) == "string"
end

-- 🔹 Đếm pet đang active (UI)
local function countActivePetsFromUI()
    local activeUI = PlayerGui:FindFirstChild("ActivePetUI", true)
    if not activeUI then return 0 end
    local ok, scrolling = pcall(function()
        return activeUI:WaitForChild("Frame", 1)
                       :WaitForChild("Main", 1)
                       :WaitForChild("PetDisplay", 1)
                       :WaitForChild("ScrollingFrame", 1)
    end)
    if not ok or not scrolling then return 0 end
    local c = 0
    for _, child in ipairs(scrolling:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("^%b{}$") then c += 1 end
    end
    return c
end

-- 🔹 Tổng pet
local function countOwnedPets()
    local total = 0
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if isPetTool(tool) then total += 1 end
    end
    local char = player.Character or player.CharacterAdded:Wait()
    for _, inst in ipairs(char:GetChildren()) do
        if isPetTool(inst) then total += 1 end
    end
    total += countActivePetsFromUI()
    return total
end

-- 🔹 Max Pet Slot
local function getMaxPetSlotFromUI()
    local ui = PlayerGui:FindFirstChild("ActivePetUI", true)
    if not ui then return 0 end
    local ok, title = pcall(function()
        return ui:WaitForChild("Frame", 1):WaitForChild("Title", 1)
    end)
    if not ok or not title then return 0 end
    local _, mx = title.Text:match("Active Pets:%s*(%d+)%s*/%s*(%d+)")
    return tonumber(mx or 0) or 0
end

-- 🔹 Max Egg Slot
local DataService
pcall(function()
    DataService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DataService"))
end)
local function getMaxEggSlotFromData()
    if not DataService then return 0 end
    local ok, data = pcall(function() return DataService:GetData() end)
    if not ok or type(data) ~= "table" then return 0 end
    local pets = data.PetsData or {}
    local mutable = pets.MutableStats or {}
    return tonumber(mutable.MaxEggsInFarm or 0) or 0
end

-- ===== INIT =====
cleanupJsonFiles()
ensureUserInfoDefaults()

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
    end)
end)

-- ===== MAIN LOOP =====
while true do
    local sheckles = getSheckles()
    local totalPet = countOwnedPets()
    local maxPetSlot = getMaxPetSlotFromUI()
    local maxEggSlot = getMaxEggSlotFromData()

    local moneyOK = meets(CONFIG.money.op, sheckles, CONFIG.money.target)
    local totalPetOK = meets(CONFIG.total_pet.op, totalPet, CONFIG.total_pet.target)
    local petSlotOK = meets(CONFIG.slot.pet.op, maxPetSlot, CONFIG.slot.pet.target)
    local eggSlotOK = meets(CONFIG.slot.egg.op, maxEggSlot, CONFIG.slot.egg.target)
    local slotOK = CONFIG.slot.all_required and (petSlotOK and eggSlotOK)
                    or (petSlotOK or eggSlotOK)

    updateIfChanged("money", moneyOK)
    updateIfChanged("total_pet", totalPetOK)
    updateIfChanged("slot", slotOK)

    -- print(("💰 %s | Pet=%d | PetSlot=%d | EggSlot=%d | → money=%s total_pet=%s slot=%s")
    --     :format(player.leaderstats.Sheckles.Value, totalPet, maxPetSlot, maxEggSlot, moneyOK, totalPetOK, slotOK))

    task.wait(2)
end
