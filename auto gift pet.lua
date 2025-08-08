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
local AGE_THRESHOLD = 75  -- Thay đổi giá trị này theo nhu cầu

-- Danh sách các tên tool hợp lệ
local validToolNames = {"Dog", "Golden Lab", "Bunny", "Starfish"}

-- Lấy tool với tên trong danh sách validToolNames và age < AGE_THRESHOLD đầu tiên trong Backpack
local function getTool(ageThreshold)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            -- Kiểm tra nếu tên tool có trong danh sách validToolNames
            for _, validName in ipairs(validToolNames) do
                if tool.Name:match(validName) then
                    local age = tonumber(tool.Name:match("^" .. validName .. " %[%d+%.?%d* KG%] %[Age (%d+)%]$"))
                    if age and age >= ageThreshold then
                        return tool
                    end
                end
            end
        end
    end
    return nil
end

-- Hàm bán pet (sử dụng GameEvents)
local function giftPet()
    local args = {
	    "GivePet",
	    game:GetService("Players"):WaitForChild("BP_Gamer03")
    }
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer(unpack(args))
end

-- Vòng lặp chính
while true do
    task.wait(5) -- Delay giữa mỗi lần kiểm tra (có thể điều chỉnh)

    -- Lấy tool với age < AGE_THRESHOLD
    local tool = getTool(AGE_THRESHOLD)
    if not tool then
        warn("❌ Không tìm thấy tool hợp lệ với Age >= " .. AGE_THRESHOLD)
        continue
    end
    tool.Parent = player.Character
    giftPet()
	tool.Parent = player.Backpack
end
