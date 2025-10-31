-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services & Player
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer

-- Modules
local GetFarm      = require(ReplicatedStore.Modules.GetFarm)
local Manhattan2D  = require(ReplicatedStore.Code.Manhattan2D)
local PetsService  = require(ReplicatedStore.Modules.PetServices.PetsService)

-- Utils
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
end

local function forceJump(humanoid)
    if not humanoid then return end
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    humanoid.Jump = false
    task.wait()
    humanoid.Jump = true
end

-- Delay giữa mỗi lần EquipPet
local delayBetweenUses = 1.0

-- Lấy một CFrame hợp lệ ngẫu nhiên trong PetArea
local function getValidCFrame()
    local farm = GetFarm(player)
    if not farm then return nil end
    local petArea = farm:FindFirstChild("PetArea")
    if not petArea then return nil end

    local size, center = petArea.Size, petArea.Position
    for _ = 1, 6 do
        local offset = Vector3.new(
            math.random(-size.X/2 + 2, size.X/2 - 2),
            0,
            math.random(-size.Z/2 + 2, size.Z/2 - 2)
        )
        local pos = center + offset
        local cf  = CFrame.new(pos.X, 0, pos.Z)
        if Manhattan2D(cf.Position, petArea) then
            return cf
        end
    end
    return nil
end

-- Đọc số pet hiện tại / tối đa từ UI
local function getPetCounts()
    local titleLabel = player.PlayerGui
        :FindFirstChild("ActivePetUI", true)
        :FindFirstChild("Frame", true)
        :FindFirstChild("Title", true)

    if not (titleLabel and titleLabel:IsA("TextLabel")) then
        warn("❌ Không tìm thấy TITLE TextLabel trong UI")
        return 0, 0
    end
    local cur, mx = titleLabel.Text:match("Active Pets:%s*(%d+)%s*/%s*(%d+)")
    return tonumber(cur) or 0, tonumber(mx) or 0
end

-- Thu thập toàn bộ Tool có chứa "Ostrich" trong Backpack và sort theo weight DESC
local function getAllOstrichToolsSorted()
    local list = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local baseName = tool.Name:match("^(.-)%s*%[") or tool.Name
            local lname    = baseName:lower()
            if lname:find("%f[%a]ostrich%f[%A]") then
                local w = tool.Name:lower():match("%[(%d+%.?%d*)%s*kg%]")
                local weight = tonumber(w or "0") or 0
                table.insert(list, { tool = tool, weight = weight })
            end
        end
    end
    table.sort(list, function(a, b) return a.weight > b.weight end)
    return list
end

-- Unequip tất cả pet một lần trước khi vào loop chính
local function unequipAllActivePetsOnce()
    local pg = player:FindFirstChildOfClass("PlayerGui")
    if not pg then return 0 end
    local activeUI = pg:FindFirstChild("ActivePetUI", true)
    if not activeUI then return 0 end

    local ok, scrolling = pcall(function()
        return activeUI:WaitForChild("Frame", 1)
            :WaitForChild("Main", 1)
            :WaitForChild("PetDisplay", 1)
            :WaitForChild("ScrollingFrame", 1)
    end)
    if not ok or not scrolling then return 0 end

    local count = 0
    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$") then
            local uuidKey = petFrame.Name
            pcall(function()
                PetsService:UnequipPet(uuidKey)
            end)
            count += 1
        end
    end
    print(("[INIT] Unequip %d pet(s) trước khi bắt đầu loop"):format(count))
    return count
end

-- Pickup tất cả pet KHÔNG phải Ostrich
local function pickupNonOstrich()
    local pg = player:FindFirstChildOfClass("PlayerGui")
    if not pg then return end
    local activeUI = pg:FindFirstChild("ActivePetUI", true)
    if not activeUI then return end

    local ok, scrolling = pcall(function()
        return activeUI:WaitForChild("Frame", 1)
            :WaitForChild("Main", 1)
            :WaitForChild("PetDisplay", 1)
            :WaitForChild("ScrollingFrame", 1)
    end)
    if not ok or not scrolling then return end

    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if not (petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$")) then continue end
        local nameLabel = petFrame:FindFirstChild("PET_TYPE", true)
        local petType   = nameLabel and nameLabel.Text or nil
        local keep = petType and petType:lower():find("ostrich") ~= nil
        if not keep then
            local uuidKey = petFrame.Name
            print(("[pickup] Unequip non-Ostrich: %s (%s)"):format(tostring(petType), uuidKey))
            pcall(function()
                PetsService:UnequipPet(uuidKey)
            end)
        end
    end
end



-- Nhảy nhẹ chống AFK
task.spawn(function()
    local humanoid = getHumanoid()
    while true do
        if humanoid and humanoid.Parent then
            forceJump(humanoid)
        else
            humanoid = getHumanoid()
        end
        task.wait(540)
    end
end)

-- Loop pickup non-Ostrich chạy song song
task.spawn(function()
    while true do
        pickupNonOstrich()
        task.wait(3)
    end
end)

-- 🔹 CHỈ UNEQUIP KHI TRONG BACKPACK CÓ ÍT NHẤT 1 OSTRICH
local ostrichList = getAllOstrichToolsSorted()
if #ostrichList > 0 then
    unequipAllActivePetsOnce()
    task.wait(2)
else
    print("[INIT] 🚫 Không có Ostrich trong Backpack — bỏ qua unequipAllActivePetsOnce()")
end

-- LOOP CHÍNH: chỉ equip Ostrich nặng nhất cho tới khi đầy slot
while true do
    task.wait(0.5)

    local cur, mx = getPetCounts()
    if mx == 0 then continue end

    local cf = getValidCFrame()
    if not cf then
        task.wait(2)
        continue
    end

    if cur >= mx then
        task.wait(1.5)
        continue
    end

    local list = getAllOstrichToolsSorted()
    if #list == 0 then
        task.wait(2)
        continue
    end

    for _, entry in ipairs(list) do
        local curNow, mxNow = getPetCounts()
        if curNow >= mxNow then break end

        local tool = entry.tool
        local uuid = tool and tool:GetAttribute("PET_UUID")
        if not (tool and uuid) then
            warn("⚠️ Tool thiếu hoặc không có PET_UUID:", tool and tool.Name)
        else
            print(("🚀 Equip Ostrich %.3f KG | UUID=%s"):format(entry.weight, tostring(uuid)))
            local ok, err = pcall(function()
                PetsService:EquipPet(uuid, cf)
            end)
            if not ok then
                warn("❌ EquipPet lỗi:", err)
            end
        end

        task.wait(delayBetweenUses)
    end
end
