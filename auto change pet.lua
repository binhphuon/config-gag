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

-- Thu thập toàn bộ Tool có chứa "Ostrich" trong Backpack và sort theo weight DESC
local function getAllOstrichToolsSorted()
    local list = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            -- Lấy phần tên trước '[' (nếu có), kiểm tra chứa "ostrich"
            local baseName = tool.Name:match("^(.-)%s*%[") or tool.Name
            local lname    = baseName:lower()

            if lname:find("%f[%a]ostrich%f[%A]") then
                -- Bắt cân nặng (int/float), KG không phân biệt hoa/thường
                local w = tool.Name:lower():match("%[(%d+%.?%d*)%s*kg%]")
                local weight = tonumber(w or "0") or 0
                table.insert(list, { tool = tool, weight = weight })
            end
        end
    end
    table.sort(list, function(a, b) return a.weight > b.weight end)
    return list
end

-- === Pickup tất cả pet KHÔNG phải Ostrich (chứa "Ostrich" thì giữ) ===
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
        local keep = petType and petType:lower():find("ostrich") ~= nil
        if not keep then
            local uuidKey = petFrame.Name -- {UUID}
            print(("[pickup] Unequip non-Ostrich: %s (%s)"):format(tostring(petType), uuidKey))
            pcall(function()
                PetsService:UnequipPet(uuidKey)
            end)
        end
    end
end

-- === Lấy danh sách Ostrich đang equip + trọng lượng (nếu UI có) ===
local function getEquippedOstrichList()
    local results = {}

    local pg = player:FindFirstChildOfClass("PlayerGui")
    if not pg then return results end

    local activeUI = pg:FindFirstChild("ActivePetUI", true)
    if not activeUI then return results end

    local ok, scrolling = pcall(function()
        return activeUI
            :WaitForChild("Frame", 1)
            :WaitForChild("Main", 1)
            :WaitForChild("PetDisplay", 1)
            :WaitForChild("ScrollingFrame", 1)
    end)
    if not ok or not scrolling then return results end

    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if not (petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$")) then
            continue
        end
        local nameLabel = petFrame:FindFirstChild("PET_TYPE", true)
        local wtLabel   = petFrame:FindFirstChild("PET_WEIGHT", true)
        local petType   = nameLabel and nameLabel.Text or nil
        if petType and petType:lower():find("ostrich") then
            local uuidKey = petFrame.Name -- {UUID}
            local weight = 0
            if wtLabel and wtLabel.Text then
                local w = wtLabel.Text:lower():match("(%d+%.?%d*)%s*kg")
                weight = tonumber(w or "0") or 0
            end
            table.insert(results, {
                uuid   = uuidKey,
                type   = petType,
                weight = weight
            })
        end
    end
    return results
end

-- === Swap: nếu Backpack có Ostrich nặng hơn con Ostrich đang equip nhẹ nhất, thì thay ===
local function swapInHeavierOstrichIfAny(cf)
    local equipped = getEquippedOstrichList()
    if #equipped == 0 then return false end

    -- tìm con equip nhẹ nhất
    table.sort(equipped, function(a, b) return a.weight < b.weight end)
    local lightest = equipped[1]
    local lightW   = lightest and lightest.weight or 0

    -- tìm con nặng nhất trong backpack
    local backpackList = getAllOstrichToolsSorted()
    local candidate
    for _, entry in ipairs(backpackList) do
        local tool = entry.tool
        local uuid = tool and tool:GetAttribute("PET_UUID")
        if uuid then
            candidate = entry
            break
        end
    end

    if not candidate then return false end
    if candidate.weight <= lightW then
        -- Không có con nào nặng hơn
        return false
    end

    -- Thực hiện swap: Unequip nhẹ nhất -> Equip con nặng hơn
    print(("[swap] 🔄 Thay Ostrich %.3f KG (uuid=%s) bằng %.3f KG (tool=%s)")
        :format(lightW, tostring(lightest.uuid), candidate.weight, candidate.tool.Name))

    pcall(function()
        PetsService:UnequipPet(lightest.uuid)
    end)
    task.wait(0.2)

    local ok, err = pcall(function()
        local uuid = candidate.tool:GetAttribute("PET_UUID")
        PetsService:EquipPet(uuid, cf)
    end)
    if not ok then
        warn("[swap] EquipPet lỗi:", err)
        return false
    end

    return true
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

-- Vòng lặp chính: luôn tối ưu đội hình Ostrich nặng nhất
while true do
    task.wait(0.5)

    local cur, mx = getPetCounts()
    if mx == 0 then
        continue -- UI chưa sẵn sàng
    end

    -- Tìm vị trí hợp lệ một lần (dùng chung cho equip/swap)
    local cf = getValidCFrame()
    if not cf then
        -- chưa có chỗ, đợi
        task.wait(2)
        continue
    end

    -- 1) Nếu full slot → thử SWAP (tìm con nặng hơn trong Backpack để thay con nhẹ nhất đang equip)
    if cur >= mx then
        swapInHeavierOstrichIfAny(cf)
        task.wait(1.5)
        continue
    end

    -- 2) Nếu chưa full → equip dần từ nặng -> nhẹ
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

    -- 3) Sau khi lấp đầy, thử tối ưu lại 1 lần bằng swap (phòng trường hợp có con nặng hơn chưa dùng)
    if getPetCounts() >= mx then
        swapInHeavierOstrichIfAny(cf)
    end
end
