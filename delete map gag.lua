-- Xóa mọi thứ trong Workspace trừ LocalPlayer và BasePlate

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

for _, obj in ipairs(Workspace:GetChildren()) do
    -- Giữ lại model của LocalPlayer
    if obj == character then
        print("[Skip] Giữ lại model LocalPlayer:", obj.Name)
        continue
    end

    -- Giữ lại model có tên BasePlate
    if obj.Name == "BasePlate" then
        print("[Skip] Giữ lại BasePlate:", obj.Name)
        continue
    end

    -- Xóa tất cả các object còn lại
    local ok, err = pcall(function()
        obj:Destroy()
    end)
    if ok then
        print("[Deleted]:", obj.Name)
    else
        warn("[Error khi xóa]", obj.Name, err)
    end
end

print("✅ Đã xóa xong mọi thứ trong Workspace (trừ LocalPlayer và BasePlate).")
