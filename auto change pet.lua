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

-- Delay giữa mỗi lần EquipPet (điều chỉnh nếu cần)
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

-- Thu thập toàn bộ Tool là "Ostrich [...]" trong Backpack và sort theo weight DESC
local function getAllOstrichToolsSorted()
    local list = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find("^Ostrich") then
            -- chấp nhận: "Ostrich [10 KG]" hoặc "Ostrich [10.2 KG] [Age 12]"
            local w = tool.Name:match("%[(%d+%.?%d*)%s*KG%]")
            local weight = tonumber(w or "0") or 0
            table.insert(list, {tool = tool, weight = weight})
        end
    end
    table.sort(list, function(a, b) return a.weight > b.weight end)
    return list
end

-- === NEW: Pickup tất cả pet KHÔNG phải Ostrich ===
local function pickupNonOstrich()
    local pg = player:FindFirstChildOfClass("PlayerGui")
    if not pg then return end

    local activeUI = pg:FindFirstChild("ActivePetUI", true)
    if not activeUI then return end

    local ok, scrolling = pcall(function()
        return activeUI
            :WaitForChild("Frame", 1)
            :WaitForChild("Main", 1)
            :WaitForChild("PetDisplay", 1)
            :WaitForChild("ScrollingFrame", 1)
    end)
    if not ok or not scrolling then return end

    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if not (petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$")) then
            continue
        end
        local nameLabel = petFrame:FindFirstChild("PET_TYPE", true)
        local petType   = nameLabel and nameLabel.Text or nil
        if petType and petType ~= "Ostrich" then
            local uuidKey = petFrame.Name -- theo game: Frame name là UUID dạng {....}
            print(("[pickup] Unequip pet không phải Ostrich: %s (%s)"):format(petType, uuidKey))
            pcall(function()
                PetsService:UnequipPet(uuidKey)
            end)
        end
    end
end

-- Auto gift pet (giữ nguyên nếu bạn cần; nếu không thì xoá 2 dòng dưới)
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/auto%20gift%20pet.lua"))()
end)

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

-- Loop pickup non-Ostrich chạy song song (mặc định 3s/lần)
task.spawn(function()
    while true do
        pickupNonOstrich()
        task.wait(3)
    end
end)

-- Vòng lặp chính: equip tất cả Ostrich từ nặng → nhẹ cho tới khi đầy slot
while true do
    task.wait(0.5)

    local cur, mx = getPetCounts()
    if mx == 0 then
        -- UI chưa sẵn sàng
        continue
    end
    if cur >= mx then
        -- Đầy slot, chờ thêm
        task.wait(2)
        continue
    end

    local list = getAllOstrichToolsSorted()
    if #list == 0 then
        -- Không còn Ostrich trong Backpack
        task.wait(2)
        continue
    end

    -- Tìm vị trí hợp lệ một lần (reuse cho các equip kế tiếp nếu cần)
    local cf = getValidCFrame()
    if not cf then
        warn("⚠️ Không tìm được vị trí hợp lệ để EquipPet")
        task.wait(2)
        continue
    end

    -- Equip lần lượt theo thứ tự nặng → nhẹ, cho tới khi đầy slot
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
