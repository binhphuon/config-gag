-- ======= BYPASS "CLICK ANYWHERE TO CONTINUE" =======
local Players           = game:GetService("Players")
local GuiService        = game:GetService("GuiService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Config
local MAX_WAIT_SECONDS     = 10         -- thời gian tối đa cố gắng vượt splash
local POLL_INTERVAL        = 0.25       -- chu kỳ quét GUI
local FORCE_HIDE_SPLASH    = false      -- true: tắt hẳn ScreenGui (mạnh tay, tránh dùng nếu game anti)

-- Helper: gửi click ảo bằng VirtualInputManager
local function sendVirtualClick(x, y)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendMouseMoveEvent(x, y, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end

-- Helper: gửi phím ảo
local function sendKey(keyCode)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.02)
        vim:SendKeyEvent(false, keyCode, false, game)
    end)
end

-- Tìm một GuiObject có chữ gợi ý splash
local function findSplashCandidate()
    local keywords = {
        "click anywhere", "click to continue", "tap to continue",
        "nhấn để tiếp tục", "chạm để tiếp tục", "tiếp tục", "continue"
    }
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("TextLabel") then
            if gui.Visible and gui.AbsoluteSize.Magnitude > 0 then
                local text = (gui.Text or gui.Name or ""):lower()
                for _, kw in ipairs(keywords) do
                    if text:find(kw, 1, true) then
                        return gui
                    end
                end
            end
        end
    end
    return nil
end

-- Thử kích hoạt một GuiObject như nút
local function tryActivate(guiObj)
    -- Ưu tiên gọi API chuẩn
    if guiObj:IsA("TextButton") or guiObj:IsA("ImageButton") then
        if guiObj.Visible then
            -- Gọi trực tiếp sự kiện Activated nếu có
            if guiObj.Activated then
                pcall(function() guiObj:Activate() end)
            end
            -- Click ảo ngay tâm của guiObj
            local absPos  = guiObj.AbsolutePosition
            local absSize = guiObj.AbsoluteSize
            local cx = absPos.X + absSize.X/2
            local cy = absPos.Y + absSize.Y/2
            sendVirtualClick(cx, cy)
            return true
        end
    else
        -- Nếu chỉ là label/khung to phủ màn, click giữa màn hình
        local cam = workspace.CurrentCamera
        local vp  = cam and cam.ViewportSize or Vector2.new(800,600)
        sendVirtualClick(vp.X/2, vp.Y/2)
        return true
    end
    return false
end

local function splashGone()
    -- heuristic: nếu không còn UI toàn màn hình nào mang chữ “continue”
    return findSplashCandidate() == nil
end

local function bypassClickAnywhere()
    local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
    local vp  = cam.ViewportSize
    local deadline = time() + MAX_WAIT_SECONDS

    -- 1) Thử click giữa màn hình bằng VIM (nhẹ nhàng nhất)
    sendVirtualClick(vp.X/2, vp.Y/2)
    task.wait(0.2)
    if splashGone() then return true end

    -- 2) Quét GUI -> tìm ứng viên rồi activate/click vào nó
    local candidate = findSplashCandidate()
    if candidate then
        tryActivate(candidate)
        task.wait(0.2)
        if splashGone() then return true end
    end

    -- 3) Thử nhấn phím phổ biến (Space / Enter)
    sendKey(Enum.KeyCode.Space)
    task.wait(0.1)
    if splashGone() then return true end
    sendKey(Enum.KeyCode.Return)
    task.wait(0.1)
    if splashGone() then return true end

    -- 4) Trong khoảng thời gian cho phép, lặp lại nhẹ nhàng
    while time() < deadline do
        task.wait(POLL_INTERVAL)
        local c = findSplashCandidate()
        if c then
            tryActivate(c)
        else
            -- không thấy đối tượng cụ thể -> click giữa màn
            local curCam = workspace.CurrentCamera
            local sz = (curCam and curCam.ViewportSize) or vp
            sendVirtualClick(sz.X/2, sz.Y/2)
        end
        if splashGone() then return true end
    end

    -- 5) Chốt hạ: nếu bạn bật FORCE_HIDE_SPLASH, tắt ScreenGui gợi ý
    if FORCE_HIDE_SPLASH then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.DisplayOrder >= 0 then
                -- hạ ưu tiên cấu phần có chữ “continue”
                local hit = false
                for _, d in ipairs(gui:GetDescendants()) do
                    if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible then
                        local t = (d.Text or ""):lower()
                        if t:find("continue", 1, true) or t:find("tiếp tục", 1, true) then
                            hit = true
                            break
                        end
                    end
                end
                if hit then
                    gui.Enabled = false
                end
            end
        end
        task.wait(0.1)
        if splashGone() then return true end
    end

    return false
end

-- Gọi bypass ngay khi load
pcall(function()
    local ok = bypassClickAnywhere()
    if ok then
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="Splash", Text="Đã bỏ qua màn hình continue", Duration=2})
        end)
    end
end)
-- ======= HẾT PHẦN BYPASS =======
