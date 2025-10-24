--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/auto%20sell%20pet.lua"))()


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

-- Đặt giá trị AGE_THRESHOLD ra ngoài vòng lặp
local AGE_THRESHOLD = 60  -- Thay đổi giá trị này theo nhu cầu

-- Danh sách các tên tool hợp lệ
local unvalidToolNames = {"Ostrich", "Griffin", "Golden Goose", "Dragonfly", "Mimic Octopus", "Red Fox", "French Fry Ferret", "Cockatrice", "Swan"} -- sửa theo nhu cầu

-- Helper: kiểm tra pet có nằm trong blacklist không
local function isUnvalidPet(petName)
    if not petName then return false end
    local lname = petName:lower()
    for _, bad in ipairs(unvalidToolNames) do
        if bad and bad ~= "" and lname:find(bad:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Helper: parse tên pet theo định dạng {TênPet} [{kg} KG] [Age {age}]
local function parsePetFromName(name)
    if not name then return nil end
    local lname = name:lower()

    local kgStr  = lname:match("%[(%d+%.?%d*)%s*kg%]")
    local ageStr = lname:match("age%s*:?%s*(%d+)")

    if not (kgStr and ageStr) then
        return nil
    end

    -- petName = phần trước '[' đầu tiên
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")

    return petName, tonumber(kgStr), tonumber(ageStr)
end

-- Hàm lấy tool đầu tiên hợp lệ (age < threshold, không trong blacklist)
local function getTool(ageThreshold)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, kg, age = parsePetFromName(tool.Name)

            if petName and age then
                if not isUnvalidPet(petName) and age < ageThreshold then
                    return tool
                end
            end
        end
    end
    return nil
end

-- Hàm bán pet (sử dụng GameEvents)
local function sellPet()
    local args = {
        Instance.new("Tool", nil)
    }
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("SellPet_RE"):FireServer(unpack(args))
    print("🚀 Đã bán pet!")
end

-- Vòng lặp chính
while true do
    task.wait(25)
    -- Lấy tool với age < AGE_THRESHOLD
    local tool = getTool(AGE_THRESHOLD)
    if not tool then
        warn("❌ Không tìm thấy tool hợp lệ (Dog, Golden Lab, Bunny) với Age < " .. AGE_THRESHOLD)
        continue
    end
    player.Character.Humanoid:EquipTool(tool)
    sellPet()
     -- Delay giữa mỗi lần kiểm tra (có thể điều chỉnh)
end
