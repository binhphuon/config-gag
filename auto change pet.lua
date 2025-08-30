

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

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    return hum
end

local function forceJump(humanoid)
    if not humanoid then return end
    -- 1) Thử ép state (nếu hợp lệ)
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    -- 2) Toggle Jump (an toàn hơn)
    humanoid.Jump = false
    task.wait()     -- 1 frame
    humanoid.Jump = true
end


-- Delay giữa mỗi lần equip
local delayBetweenUses = 60

-- Đặt giá trị AGE_THRESHOLD để lấy tool có tuổi nhỏ hơn giá trị này
local AGE_THRESHOLD = 75  -- Thay đổi giá trị này theo nhu cầu

-- Lấy tool Starfish với age < ageThreshold đầu tiên trong Backpack
local function getTool(ageThreshold)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:match("^Starfish %[%d+%.?%d* KG%] %[Age (%d+)%]$") then
            local age = tonumber(tool.Name:match("^Starfish %[%d+%.?%d* KG%] %[Age (%d+)%]$"))
            if age and age < ageThreshold then
                return tool
            end
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
        :FindFirstChild("Frame", true)
        :FindFirstChild("Title", true)

    if not titleLabel or not titleLabel:IsA("TextLabel") then
        warn("❌ Không tìm thấy TITLE TextLabel trong UI")
        return 0, 0
    end

    local cur, mx = titleLabel.Text:match("Active Pets:%s*(%d+)%s*/%s*(%d+)")
    return tonumber(cur) or 0, tonumber(mx) or 0
end

-- Pickup tất cả pet có age >= AGE_THRESHOLD
local function autoPickupOldPets(ageThreshold)
    -- 1️⃣ Lấy đúng ScrollingFrame
    local activeUI = player.PlayerGui:WaitForChild("ActivePetUI", 5)
    if not activeUI then
        warn("[autoPickup] Không tìm thấy ActivePetUI")
        return
    end
    local scrolling = activeUI
        :WaitForChild("Frame")
        :WaitForChild("Main")
        :WaitForChild("PetDisplay")
        :WaitForChild("ScrollingFrame")

    -- 2️⃣ Kiểm tra có Capybara không
    local hasCapybara = false
    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$") then
            local nameLabel = petFrame:FindFirstChild("PET_TYPE", true)
            if nameLabel and nameLabel.Text == "Capybara" then
                hasCapybara = true
                break
            end
        end
    end

    -- 3️⃣ Duyệt từng Frame
    for _, petFrame in ipairs(scrolling:GetChildren()) do
        if not (petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$")) then
            continue
        end

        local ageLabel = petFrame:FindFirstChild("PET_AGE", true)
        local nameLabel = petFrame:FindFirstChild("PET_TYPE", true)
        local age = ageLabel and tonumber(ageLabel.Text:match("(%d+)"))
        local name = nameLabel and nameLabel.Text

        if not age or not name then
            warn(("[autoPickup] [%s] thiếu dữ liệu age/name"):format(petFrame.Name))
            continue
        end

        local shouldPickup = false

        -- 🔹 Starfish đủ tuổi → luôn pickup
        if name == "Starfish" and age >= ageThreshold then
            shouldPickup = true
        end

        -- 🔹 Nếu có Capybara → pickup tất cả pet khác
        -- trừ Capybara và Starfish (nếu chưa đủ tuổi)
        if hasCapybara and name ~= "Capybara" then
            if name ~= "Starfish" or (name == "Starfish" and age >= ageThreshold) then
                shouldPickup = true
            end
        end

        -- Thực hiện pickup nếu cần
        if shouldPickup then
            print(("[autoPickup] Pickup %s [%s] (age=%d)"):format(petFrame.Name, name, age))
            local ok, err = pcall(function()
                PetsService:UnequipPet(petFrame.Name)
            end)
            if not ok then
                warn(("[autoPickup] UnequipPet(%s) lỗi: %s"):format(petFrame.Name, err))
            end
        end
    end
end
--Auto gift pet
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/auto%20gift%20pet.lua"))()
end)

task.spawn(function()
    local humanoid = getHumanoid()
    while true do
        task.wait(600) -- thay đổi interval nếu cần
        if humanoid and humanoid.Parent then
            forceJump(humanoid)
        else
            -- nếu dead/respawn thì cố lấy lại humanoid
            humanoid = getHumanoid()
        end

    end
end)


-- Vòng lặp chính
while true do
    task.wait(6)
    -- Gọi autoPickupOldPets với AGE_THRESHOLD
    autoPickupOldPets(AGE_THRESHOLD)
    
    -- 2) Kiểm tra số slot pet
    local cur, mx = getPetCounts()
    if cur >= mx then
        print(("🛑 Slot pet đầy (%d/%d), gọi pickup"):format(cur, mx))
        continue
    end


    task.wait(delayBetweenUses)
    
    -- 1) Lấy tool với age < AGE_THRESHOLD
    local tool = getTool(AGE_THRESHOLD)
    if not tool then
        warn("❌ Không tìm thấy tool Starfish [Age < " .. AGE_THRESHOLD .. "]")
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
