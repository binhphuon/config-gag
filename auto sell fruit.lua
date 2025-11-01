-- Đợi game & player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local ReplicatedStore = game:GetService("ReplicatedStorage")

-- Lấy HumanoidRootPart
local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Hàm teleport & bán inventory
local function tpAndSell()
    local root = getRoot()
    if not root then return end

    -- 1️⃣ Teleport
    root.CFrame = CFrame.new(65, 3, 0.4)
    print("📍 Teleported to 65, 3, 0.4")

    task.wait(0.5)

    -- 2️⃣ Bán inventory
    ReplicatedStore:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
    print("💰 Sell_Inventory remote fired!")
end

-- 3️⃣ Lặp lại mỗi 10 giây
while true do
    tpAndSell()
    task.wait(10)
end
