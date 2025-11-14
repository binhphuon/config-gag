-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/farm88/rai%20tien.lua"))()

-- ======= BYPASS "CLICK ANYWHERE TO CONTINUE" =======
local Players           = game:GetService("Players")
local GuiService        = game:GetService("GuiService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local StarterGui        = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStore   = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local SPLASH_MAX_WAIT     = 10
local SPLASH_POLL         = 0.25
local FORCE_HIDE_SPLASH   = false

local function sendVirtualClick(x, y)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendMouseMoveEvent(x, y, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end
local function sendKey(code)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendKeyEvent(true, code, false, game)
        task.wait(0.02)
        vim:SendKeyEvent(false, code, false, game)
    end)
end
local function findSplashCandidate()
    local kws = {
        "click anywhere","click to continue","tap to continue",
        "nhấn để tiếp tục","chạm để tiếp tục","tiếp tục","continue"
    }
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("TextLabel"))
            and gui.Visible and gui.AbsoluteSize.Magnitude > 0 then
            local text = (gui.Text or gui.Name or ""):lower()
            for _, kw in ipairs(kws) do
                if text:find(kw, 1, true) then return gui end
            end
        end
    end
    return nil
end
local function splashGone() return findSplashCandidate() == nil end
local function bypassClickAnywhere()
    local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
    local vp  = cam.ViewportSize
    local deadline = time() + SPLASH_MAX_WAIT

    sendVirtualClick(vp.X/2, vp.Y/2)
    task.wait(0.2)
    if splashGone() then return true end

    local c = findSplashCandidate()
    if c then
        local pos = c.AbsolutePosition
        local size= c.AbsoluteSize
        sendVirtualClick(pos.X + size.X/2, pos.Y + size.Y/2)
        task.wait(0.2)
        if splashGone() then return true end
    end

    sendKey(Enum.KeyCode.Space); task.wait(0.1); if splashGone() then return true end
    sendKey(Enum.KeyCode.Return);task.wait(0.1); if splashGone() then return true end

    while time() < deadline do
        task.wait(SPLASH_POLL)
        local cam2 = workspace.CurrentCamera
        local sz   = (cam2 and cam2.ViewportSize) or vp
        local cand = findSplashCandidate()
        if cand then
            local p = cand.AbsolutePosition; local s = cand.AbsoluteSize
            sendVirtualClick(p.X + s.X/2, p.Y + s.Y/2)
        else
            sendVirtualClick(sz.X/2, sz.Y/2)
        end
        if splashGone() then return true end
    end

    if FORCE_HIDE_SPLASH then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local hit = false
                for _, d in ipairs(gui:GetDescendants()) do
                    if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible then
                        local t = (d.Text or ""):lower()
                        if t:find("continue",1,true) or t:find("tiếp tục",1,true) then
                            hit = true; break
                        end
                    end
                end
                if hit then gui.Enabled = false end
            end
        end
        task.wait(0.1)
        if splashGone() then return true end
    end
    return false
end

pcall(function()
    if bypassClickAnywhere() then
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="Splash", Text="Đã bỏ qua màn hình continue", Duration=2})
        end)
    end
end)
-- ======= END SPLASH BYPASS =======

-- Anti AFK
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
end)

-- Create file
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/zcreatefilecc88.lua"))()
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/send%20small%20money.lua"))()
