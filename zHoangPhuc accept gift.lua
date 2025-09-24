-- AutoAccept_UINav.lua
-- LocalScript (StarterPlayerScripts). Chỉ tìm Accept bên trong PlayerGui.Gift_Notification

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
if not player then
    warn("[AutoAccept] This must be a LocalScript (StarterPlayerScripts / StarterGui).")
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local giftGui = playerGui:WaitForChild("Gift_Notification", 5)
if not giftGui then
    warn("[AutoAccept] Gift_Notification not found under PlayerGui.")
    return
end

local DEBOUNCE = 1
local last = {}

local function isVisibleGui(obj)
    if not obj:IsA("GuiObject") then return false end
    if obj.Visible == false then return false end
    if obj.AbsoluteSize and (obj.AbsoluteSize.X == 0 or obj.AbsoluteSize.Y == 0) then return false end
    local a = obj.Parent
    while a and a ~= playerGui do
        if a:IsA("GuiObject") and a.Visible == false then return false end
        a = a.Parent
    end
    return true
end

local function trySendEnterViaVIM()
    local ok, vim = pcall(function() return game:GetService("VirtualInputManager") end)
    if not ok or not vim or not vim.SendKeyEvent then
        return false
    end
    -- send Enter down/up
    pcall(function()
        vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end)
    return true
end

local function focusAndEnter(btn)
    if not btn then return false end
    -- debounce
    local t = tick()
    if last[btn] and t - last[btn] < DEBOUNCE then return false end
    last[btn] = t

    -- focus bằng UI Navigation
    pcall(function() GuiService.SelectedObject = btn end)
    task.wait(0.04)

    -- Thử VirtualInputManager (executor)
    if trySendEnterViaVIM() then
        print("[AutoAccept] Sent Enter (VIM) ->", btn:GetFullName())
        return true
    end

    -- Fallback: thử phát event MouseButton1Click (pcall vì có thể bị restricted)
    local fired = false
    pcall(function()
        if btn and (btn:IsA("ImageButton") or btn:IsA("TextButton")) then
            if btn.MouseButton1Click then
                btn.MouseButton1Click:Fire()
                fired = true
            elseif btn.Activated then
                -- nếu Activated event tồn tại, trigger bằng cách connect->fire không có sẵn; skip
            end
        end
    end)
    if fired then
        print("[AutoAccept] Fired MouseButton1Click ->", btn:GetFullName())
        return true
    end

    -- Không có cách nào khác đảm bảo — báo log
    warn("[AutoAccept] Could not activate Accept by Enter or firing event ->", btn:GetFullName())
    return false
end

local function tryClickAcceptInGift(container)
    for _, obj in ipairs(container:GetDescendants()) do
        if (obj:IsA("ImageButton") or obj:IsA("TextButton")) and string.lower(obj.Name) == "accept" then
            print("[AutoAccept] Candidate found:", obj:GetFullName())
            if isVisibleGui(obj) then
                focusAndEnter(obj)
            else
                print("[AutoAccept] Candidate not visible yet:", obj:GetFullName())
            end
        end
    end
end

-- initial scan
tryClickAcceptInGift(giftGui)

-- listen for new nodes under Gift_Notification
giftGui.DescendantAdded:Connect(function(desc)
    task.delay(0.04, function()
        -- nếu chính nó là nút Accept
        if (desc:IsA("ImageButton") or desc:IsA("TextButton")) and string.lower(desc.Name) == "accept" then
            print("[AutoAccept] New Accept detected:", desc:GetFullName())
            if isVisibleGui(desc) then
                focusAndEnter(desc)
            else
                print("[AutoAccept] New Accept not visible:", desc:GetFullName())
            end
            return
        end
        -- nếu là container, scan bên trong
        if desc:IsA("GuiObject") then
            for _, c in ipairs(desc:GetDescendants()) do
                if (c:IsA("ImageButton") or c:IsA("TextButton")) and string.lower(c.Name) == "accept" then
                    print("[AutoAccept] New inner Accept detected:", c:GetFullName())
                    if isVisibleGui(c) then
                        focusAndEnter(c)
                    else
                        print("[AutoAccept] Inner Accept not visible:", c:GetFullName())
                    end
                    break
                end
            end
        end
    end)
end)

-- periodic scan as fallback
task.spawn(function()
    while true do
        task.wait(1)
        tryClickAcceptInGift(giftGui)
    end
end)
