-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/zcreatefilecc88.lua"))()



-- ======= BYPASS "CLICK ANYWHERE TO CONTINUE" =======
local Players           = game:GetService("Players")
local GuiService        = game:GetService("GuiService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local StarterGui        = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStore   = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local SPLASH_MAX_WAIT     = 10
local SPLASH_POLL         = 0.25
local FORCE_HIDE_SPLASH   = false

local function sendVirtualClick(x, y)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendMouseMoveEvent(x, y, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end
local function sendKey(code)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendKeyEvent(true, code, false, game)
        task.wait(0.02)
        vim:SendKeyEvent(false, code, false, game)
    end)
end
local function findSplashCandidate()
    local kws = {
        "click anywhere","click to continue","tap to continue",
        "nhấn để tiếp tục","chạm để tiếp tục","tiếp tục","continue"
    }
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("TextLabel"))
            and gui.Visible and gui.AbsoluteSize.Magnitude > 0 then
            local text = (gui.Text or gui.Name or ""):lower()
            for _, kw in ipairs(kws) do
                if text:find(kw, 1, true) then return gui end
            end
        end
    end
    return nil
end
local function splashGone() return findSplashCandidate() == nil end
local function bypassClickAnywhere()
    local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
    local vp  = cam.ViewportSize
    local deadline = time() + SPLASH_MAX_WAIT

    sendVirtualClick(vp.X/2, vp.Y/2)
    task.wait(0.2)
    if splashGone() then return true end

    local c = findSplashCandidate()
    if c then
        local pos = c.AbsolutePosition
        local size= c.AbsoluteSize
        sendVirtualClick(pos.X + size.X/2, pos.Y + size.Y/2)
        task.wait(0.2)
        if splashGone() then return true end
    end

    sendKey(Enum.KeyCode.Space); task.wait(0.1); if splashGone() then return true end
    sendKey(Enum.KeyCode.Return);task.wait(0.1); if splashGone() then return true end

    while time() < deadline do
        task.wait(SPLASH_POLL)
        local cam2 = workspace.CurrentCamera
        local sz   = (cam2 and cam2.ViewportSize) or vp
        local cand = findSplashCandidate()
        if cand then
            local p = cand.AbsolutePosition; local s = cand.AbsoluteSize
            sendVirtualClick(p.X + s.X/2, p.Y + s.Y/2)
        else
            sendVirtualClick(sz.X/2, sz.Y/2)
        end
        if splashGone() then return true end
    end

    if FORCE_HIDE_SPLASH then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local hit = false
                for _, d in ipairs(gui:GetDescendants()) do
                    if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible then
                        local t = (d.Text or ""):lower()
                        if t:find("continue",1,true) or t:find("tiếp tục",1,true) then
                            hit = true; break
                        end
                    end
                end
                if hit then gui.Enabled = false end
            end
        end
        task.wait(0.1)
        if splashGone() then return true end
    end
    return false
end

pcall(function()
    if bypassClickAnywhere() then
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="Splash", Text="Đã bỏ qua màn hình continue", Duration=2})
        end)
    end
end)
-- ======= END SPLASH BYPASS =======
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
    money = { target = 900000000,  op = ">=" },   -- true nếu khác 20
    total_pet = { target = 15, op = ">=" },
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
--cleanupJsonFiles()
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
