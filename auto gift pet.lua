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


local allowedPlayers = {"BP_Gamer03", "Elain3H3l3n", "H3l3nCaraAva", "Ga1lBa1ley", "CarlaGa1l", "oubDQE7jx7", "Riku_Angela", "NganBarbara", "ChiBr3nda", "Natsum1Holly", "BeauCara", "MaiHollyAri", "ElsaGavin", "Ax3lChlo3", "Rina_DALLAS", "IngridDawn", "NhatAva34", "HanhC0dyBeth", "XuanDallas", "LING_Igor", "C0l1nEmma", "DanCol1n", "Yu3Ann40", "Edd1eIan", "Fallon_Danny", "Saki_Abby92", "ShengCarmen"}

-- Hàm tặng pet cho người chơi trong danh sách
local function giftPetToPlayer(playerName)
    local args = {
        "GivePet",
        game:GetService("Players"):WaitForChild(playerName)
    }
    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer(unpack(args))
    print("🛍️ Tặng pet cho", playerName)
end

-- Hàm kiểm tra và tặng pet cho những người chơi trong danh sách
local function giftPetsToAllowedPlayers()
    -- Duyệt qua tất cả người chơi trong game
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        -- Kiểm tra xem tên người chơi có trong danh sách không
        for _, allowedName in ipairs(allowedPlayers) do
            if player.Name == allowedName then
				local tool = getTool(AGE_THRESHOLD)
    			if not tool then
        			warn("❌ Không tìm thấy tool hợp lệ với Age >= " .. AGE_THRESHOLD)
        		continue
    			end
    			Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                -- Nếu tên trùng, gọi hàm gift pet
                giftPetToPlayer(player.Name)
                break  -- Không cần tiếp tục duyệt các tên còn lại nếu đã tìm thấy
            end
        end
    end
end

-- Vòng lặp chính
while true do
    task.wait(5) -- Delay giữa mỗi lần kiểm tra (có thể điều chỉnh)
	giftPetsToAllowedPlayers()
end
