-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20unequip%20all%20pets.lua"))()

-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services & Player
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer

-- Modules
local PetsService
do
    local ok, mod = pcall(function()
        return require(ReplicatedStore.Modules.PetServices.PetsService)
    end)
    if ok then
        PetsService = mod
    else
        warn("❌ Không thể require PetsService:", mod)
        return
    end
end

-- Lấy ScrollingFrame chứa danh sách pet đang active
local function getActivePetScrollingFrame()
    local pg = player:FindFirstChildOfClass("PlayerGui")
    if not pg then return nil end

    local activeUI = pg:FindFirstChild("ActivePetUI", true)
    if not activeUI then return nil end

    local ok, scrolling = pcall(function()
        return activeUI:WaitForChild("Frame", 1)
            :WaitForChild("Main", 1)
            :WaitForChild("PetDisplay", 1)
            :WaitForChild("ScrollingFrame", 1)
    end)

    if not ok or not scrolling then
        return nil
    end

    return scrolling
end

-- Unequip tất cả pet đang active (KHÔNG phân biệt loại)
local function unequipAllActivePetsOnce()
    local scrolling = getActivePetScrollingFrame()
    if not scrolling then
        -- Không spam warn, chỉ báo nhẹ 1 lần khi không tìm thấy
        -- warn("⚠️ Không tìm thấy ActivePetUI / ScrollingFrame")
        return 0
    end

    local count = 0

    for _, petFrame in ipairs(scrolling:GetChildren()) do
        -- Theo script gốc: Frame tên dạng {UUID}
        if petFrame:IsA("Frame") and petFrame.Name:match("^%b{}$") then
            local uuidKey = petFrame.Name
            pcall(function()
                PetsService:UnequipPet(uuidKey)
            end)
            count += 1
        end
    end

    if count > 0 then
        print(("[AUTO-UNEQUIP] Đã unequip %d pet đang active"):format(count))
    end

    return count
end

-- CONFIG: delay giữa mỗi lần quét/unequip
local LOOP_DELAY = 2.0  -- giây, chỉnh tùy ý

-- Vòng lặp auto unequip
task.spawn(function()
    while true do
        local removed = unequipAllActivePetsOnce()
        -- Nếu không có pet nào active thì vẫn chờ 1 chút rồi quét lại
        task.wait(LOOP_DELAY)
    end
end)
