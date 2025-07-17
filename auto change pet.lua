-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services và Player
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer

-- Load các module
local GetFarm      = require(ReplicatedStore.Modules.GetFarm)
local Manhattan2D  = require(ReplicatedStore.Code.Manhattan2D)
local PetsService  = require(ReplicatedStore.Modules.PetServices.PetsService)

-- In ra các method của PetsService để xem có hàm pickup không
print("🔧 PetsService methods:")
for name,_ in pairs(PetsService) do
    print("   •", name)
end

-- Delay giữa mỗi lần equip
local delayBetweenUses = 120.5

-- Lấy tool Starfish [Age 1] đầu tiên trong Backpack
local function getTool()
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:match("^Starfish %[%d+%.?%d* KG%] %[Age 1%]$") then
            return tool
        end
    end
    return nil
end

-- Lấy một CFrame hợp lệ ngẫu nhiên trong PetArea
local function getValidCFrame()
    local farm = GetFarm(player)
    if not farm then return nil end

    local petArea = farm:FindFirstChild("PetArea")
    if not petArea then return nil end

    local size   = petArea.Size
    local center = petArea.Position

    for _ = 1, 5 do
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

-- Đọc số pet hiện tại và max từ UI
local function getPetCounts()
    local titleLabel = player.PlayerGui
        :FindFirstChild("ActivePetUI", true)
        :FindFirstChild("TITLE", true)

    if not titleLabel or not titleLabel:IsA("TextLabel") then
        warn("❌ Không tìm thấy TITLE TextLabel trong UI")
        return 0, 0
    end

    local cur, mx = titleLabel.Text:match("Active Pets:%s*(%d+)%s*/%s*(%d+)")
    return tonumber(cur) or 0, tonumber(mx) or 0
end

-- Pickup tất cả pet có age >= 75
local AGE_THRESHOLD = 75

local function autoPickupOldPets()
    -- 1️⃣ Lấy đúng ScrollingFrame
    local activeUI = player.PlayerGui:WaitForChild("ActivePetUI", 5)
    if not activeUI then
        warn("[autoPickup] Không tìm thấy ActivePetUI")
        return
    end
    local scrolling = activeUI
        :WaitForChild("Frame")
        :WaitForChild("Main")
        :WaitForChild("ScrollingFrame")

    -- 2️⃣ Duyệt từng Frame tên "{uuid}"
    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if not (petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$")) then
            continue
        end

        -- 3️⃣ Lấy và parse tuổi
        local ageLabel = petFrame:FindFirstChild("PET_AGE", true)
        local age = ageLabel and tonumber(ageLabel.Text:match("(%d+)"))
        if not age then
            warn(("[autoPickup] [%s] không đọc được tuổi"):format(petFrame.Name))
            continue
        end

        -- 4️⃣ Nếu đủ tuổi, gọi service với đúng key (có ngoặc)
        if age >= AGE_THRESHOLD then
            print(("[autoPickup] Pickup pet %s (age=%d)"):format(petFrame.Name, age))
            local ok, err = pcall(function()
                PetsService:UnequipPet(petFrame.Name)
            end)
            if not ok then
                warn(("[autoPickup] UnequipPet(%s) lỗi: %s")
                      :format(petFrame.Name, err))
            end
        end
    end
end


-- Vòng lặp chính
while true do
    task.wait(delayBetweenUses)

    autoPickupOldPets()

    -- 2) Kiểm tra số slot pet
    local cur, mx = getPetCounts()
    if cur >= mx then
        print(("🛑 Slot pet đầy (%d/%d), gọi pickup"):format(cur, mx))
        
        continue
    end

    -- 1) Lấy tool
    local tool = getTool()
    if not tool then
        warn("❌ Không tìm thấy tool Starfish [Age 1]")
        continue
    end

    task.wait(1)

    -- 3) Equip pet mới
    local uuid = tool:GetAttribute("PET_UUID")
    if not uuid then
        warn("⚠️ Tool thiếu PET_UUID")
        continue
    end

    local cf = getValidCFrame()
    if not cf then
        warn("⚠️ Không tìm được vị trí hợp lệ")
        continue
    end

    print("🚀 Đang equip pet", uuid, "tại", cf.Position)
    PetsService:EquipPet(uuid, cf)
end
