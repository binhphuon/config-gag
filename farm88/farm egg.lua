-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/farm88/farm%20egg.lua", true))()

task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/click%20to%20continue.lua", true))()
end)

task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/delete%20map%20gag.lua", true))()
end)

task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/fps%20cap.lua", true))()
end)

task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/buy%20common%20egg", true))()
end)

task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
end)

task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20gift%20pet.lua"))()
end)

-- 🔧 Toggle Render 3D UI Button
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local RunService = game:GetService("RunService")

-- Trạng thái ban đầu
getgenv().Rendering = false -- true = bật render, false = tắt render

-- Tạo ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "RenderToggleUI"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Tạo Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 160, 0, 40)
button.Position = UDim2.new(0, 20, 0, 150)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1,1,1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Text = "Rendering: ON"
button.Parent = gui

-- Hàm cập nhật UI + chế độ
local function updateState()
    if getgenv().Rendering then
        RunService:Set3dRenderingEnabled(true)
        button.Text = "Rendering: ON"
        button.BackgroundColor3 = Color3.fromRGB(0,170,255) -- xanh
    else
        RunService:Set3dRenderingEnabled(false)
        button.Text = "Rendering: OFF"
        button.BackgroundColor3 = Color3.fromRGB(255,70,70) -- đỏ
    end
end

-- Click để toggle
button.MouseButton1Click:Connect(function()
    getgenv().Rendering = not getgenv().Rendering
    updateState()
end)

-- Khởi động UI đúng trạng thái
updateState()
