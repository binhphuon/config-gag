-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer

-- Modules
local PetsService     = require(ReplicatedStore.Modules.PetServices.PetsService)

-- =========================
-- Helper parse pet name
-- =========================
local function parsePetFromName(name)
    if not name then return nil end
    local lname = name:lower()

    -- Cho phép số thập phân cho KG, case-insensitive
    local kgStr  = lname:match("%[(%d+%.?%d*)%s*kg%]")
    local ageStr = lname:match("age%s*:?%s*(%d+)")

    if not (kgStr and ageStr) then return nil end

    -- petName = phần trước '[' đầu tiên
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")

    return petName, tonumber(kgStr), tonumber(ageStr)
end

-- =========================
-- Check blacklist
-- =========================
local function isUnvalidPet(petName)
    if not petName then return false end
    local lname = petName:lower()
    for _, bad in ipairs(unvalidToolNames) do
        if lname:find(bad:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- =========================
-- Lấy ScrollingFrame ActivePetUI (đang equip)
-- =========================
local function getActivePetScrollingFrame()
    local activeUI = player.PlayerGui:WaitForChild("ActivePetUI", 5)
    if not activeUI then
        warn("[autoPickup] Không tìm thấy ActivePetUI")
        return nil
    end
    local ok, scrolling = pcall(function()
        return activeUI
            :WaitForChild("Frame")
            :WaitForChild("Main")
            :WaitForChild("PetDisplay")
            :WaitForChild("ScrollingFrame")
    end)
    if not ok or not scrolling then
        warn("[autoPickup] Không lấy được ScrollingFrame trong ActivePetUI")
        return nil
    end
    return scrolling
end

-- =========================
-- Unequip các pet đang equip theo 1 cfg block
-- =========================
local function unequipPetsByConfig(cfg)
    if not cfg.unequip_Pet then return end

    local scrolling = getActivePetScrollingFrame()
    if not scrolling then return end

    -- Kiểm tra nhanh xem UI có hiển thị cân nặng không (không phải game nào cũng có)
    local function findLabel(frame, name)
        return frame:FindFirstChild(name, true)
    end

    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if not (petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$")) then
            continue
        end

        local nameLabel = findLabel(petFrame, "PET_TYPE")
        local ageLabel  = findLabel(petFrame, "PET_AGE")
        local wtLabel   = findLabel(petFrame, "PET_WEIGHT") -- nếu có

        local petType = nameLabel and nameLabel.Text or nil
        local age     = ageLabel and tonumber(ageLabel.Text:match("(%d+)")) or nil

        -- thử parse weight nếu label có định dạng "5 KG" v.v.
        local weight  = nil
        if wtLabel and wtLabel.Text then
            local w = wtLabel.Text:match("(%d+%.?%d*)%s*[Kk][Gg]")
            weight = w and tonumber(w) or nil
        end

        if not (petType and age) then
            warn(("[autoPickup] Frame %s thiếu dữ liệu age/name"):format(petFrame.Name))
            continue
        end

        -- Kiểm tra theo cfg: name_pet (nil = không lọc theo tên), tuổi, cân nặng (nếu UI có + cfg có min_weight)
        local nameOK = (cfg.name_pet == nil) or petType:lower():find(cfg.name_pet:lower(), 1, true)
        local ageOK  = (age >= cfg.min_age and age < cfg.max_age)
        local weightOK = true
        if cfg.min_weight then
            if weight ~= nil then
                weightOK = (weight >= cfg.min_weight)
            else
                -- Nếu UI không có weight, coi như qua điều kiện (không thể kiểm chứng)
                weightOK = true
            end
        end

        if nameOK and ageOK and weightOK then
            print(("[autoPickup] Unequip %s [%s] age=%d wt=%s"):format(
                petFrame.Name, petType, age, tostring(weight)))
            local ok2, err = pcall(function()
                PetsService:UnequipPet(petFrame.Name)
            end)
            if not ok2 then
                warn(("[autoPickup] UnequipPet(%s) lỗi: %s"):format(petFrame.Name, err))
            end
        end
    end
end

-- =========================
-- Lấy tool từ Backpack theo 1 cfg block
-- name_pet nil => áp dụng blacklist
-- có min_weight => yêu cầu kg >= min_weight
-- =========================
local function getTool(name_pet, min_age, max_age, min_weight)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, kg, age = parsePetFromName(tool.Name)
            if petName and age and kg then
                -- Blacklist chỉ áp dụng khi name_pet == nil
                if (name_pet or not isUnvalidPet(petName)) then
                    local nameOK = (not name_pet) or petName:lower():find(name_pet:lower(), 1, true)
                    local ageOK  = (age >= min_age and age < max_age)
                    local weightOK = (not min_weight) or (kg >= min_weight)
                    if nameOK and ageOK and weightOK then
                        print(("[DEBUG] ✅ Chọn tool: %s | pet=%s | age=%d | kg=%.3f"):format(tool.Name, petName, age, kg))
                        return tool
                    end
                else
                    -- bị loại vì blacklist (chỉ khi name_pet == nil)
                    -- print(("[DEBUG] Bỏ qua (blacklist): %s"):format(petName))
                end
            else
                -- print(("[DEBUG] Không parse được: %s"):format(tool and tool.Name or "nil"))
            end
        end
    end
    return nil
end

-- =========================
-- Hàm tặng pet
-- =========================
local function giftPetToPlayer(targetPlayerName)
    local args = {
        "GivePet",
        Players:WaitForChild(targetPlayerName)
    }
    ReplicatedStore.GameEvents.PetGiftingService:FireServer(unpack(args))
    print("🛍️ Tặng pet cho", targetPlayerName)
end

task.spawn(function()
-- Webhook Discord của bạn
local webhookUrl = "https://canary.discord.com/api/webhooks/1420998430641356891/wQfhiVm0h-KGiER-XsnUk7YqgOrwSobhGvfyG5HOekETqBET-28HOr92zxU4cDVUZGc4"

-- Services
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Nội dung gửi
local data = {
    ["content"] = "🚀 Script vừa được exec bởi **"..player.Name.."** " ..
        "(UserId: "..player.UserId..")\n" ..
        "📌 GameId: "..game.PlaceId.."\n" ..
        "🆔 JobId: "..game.JobId.."\n" ..
        "HWID: "..HWID
}

-- Encode JSON
local body = HttpService:JSONEncode(data)

-- Gửi request qua Codex API
if http_request then
    http_request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = body
    })
else
    warn("❌ Codex không hỗ trợ http_request")
end

end)
-- =========================
-- Vòng lặp chính
-- =========================
while true do
    task.wait(1)
    if not auto_gift then
        -- Cho phép bật/tắt nhanh không tốn CPU
        task.wait(3600)
        continue
    end

    for _, cfg in ipairs(DataGetTool) do
        -- (1) Unequip theo block nếu cần
        if cfg.unequip_Pet then
            unequipPetsByConfig(cfg)
        end

        -- (2) Duyệt player trong server
        for _, p in ipairs(Players:GetPlayers()) do
            if table.find(cfg.playerlist, p.Name) then
                -- (3) Chọn tool theo cfg (có thể gồm min_weight)
                local tool = getTool(cfg.name_pet, cfg.min_age, cfg.max_age, cfg.min_weight)
                if tool then
                    -- (4) Equip rồi gift
                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:EquipTool(tool) end
                    giftPetToPlayer(p.Name)
                else
                    warn("[autoPickup] Không tìm thấy tool hợp lệ cho", p.Name)
                end
            end
        end
    end
end