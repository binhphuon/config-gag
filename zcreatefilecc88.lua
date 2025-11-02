-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/zcreatefilecc88.lua"))()

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

-- ======= MAIN LOGIC =======
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player2     = Players.LocalPlayer
local username    = player2.Name
local userId      = player2.UserId

-- Files
local userInfoFile  = tostring(userId) .. "-info.json"      -- đích
local gagFile       = tostring(username) .. "_gag.json"     -- nguồn
local giftKeepFile  = "gift_records.json"                   -- file không xoá

-- Helpers
local function safeJSONDecode(s)
    local ok, data = pcall(function() return HttpService:JSONDecode(s) end)
    if ok and type(data) == "table" then return data end
    return nil
end

local function readJsonFile(fileName)
    if isfile(fileName) then
        local content = readfile(fileName)
        return safeJSONDecode(content)
    end
    return nil
end

local function writeJsonFile(fileName, data)
    local encoded = HttpService:JSONEncode(data)
    writefile(fileName, encoded)
end

-- Xoá mọi .json trừ 3 file cần giữ (userInfo, _gag, gift_records.json)
local function cleanupJsonFiles()
    local files = listfiles("") -- thư mục hiện tại
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local baseName = file:match("[^/\\]+$") -- chỉ lấy tên
            if baseName ~= userInfoFile
                and baseName ~= gagFile
                and baseName ~= giftKeepFile
            then
                delfile(baseName)
                print("[cleanup] Đã xoá:", baseName)
            end
        end
    end
end

-- Khởi tạo giá trị mặc định cho -info.json (booleans)
local function ensureUserInfoDefaults()
    local info = readJsonFile(userInfoFile) or {}
    local changed = false

    if info.total_pet == nil then
        info.total_pet = false
        changed = true
    end
    if info.slot == nil then
        info.slot = false
        changed = true
    end
    if info.money == nil then
        info.money = false
        changed = true
    end

    if changed then
        writeJsonFile(userInfoFile, info)
        print("[init] Khởi tạo mặc định cho "..userInfoFile)
    end
end

-- Ghi file chỉ khi có thay đổi
local function updateIfChanged(key, newVal)
    local info = readJsonFile(userInfoFile) or {}
    if info[key] ~= newVal then
        local old = info[key]
        info[key] = newVal
        writeJsonFile(userInfoFile, info)
        print(("[update] %s: %s -> %s"):format(key, tostring(old), tostring(newVal)))
    end
end

-- Debounce state cho total_pet
local _state = {
    total_pet_desired_last = nil,
    total_pet_stable_count = 0,
    required_stable = 2, -- cần ổn định 2 tick liên tiếp
}

-- Parse số an toàn (nhận cả number/string), trả về number hoặc nil
local function toNumber(v)
    if typeof(v) == "number" then return v end
    if type(v) == "string" then
        local n = tonumber(v)
        if n ~= nil then return n end
    end
    return nil
end

-- Áp dụng quy tắc cập nhật theo _gag.json
local function applyRulesFromGag(gag)
    if type(gag) ~= "table" then return end

    -- ===== 1) total_pet (boolean): dựa trên tổng (OPTION) total_pet + total_mythical + total_divine =====
    do
        local pet = toNumber(gag.total_pet) or 0
        local tm  = toNumber(gag.total_mythical) or 0
        local td  = toNumber(gag.total_divine) or 0
        local petCount = pet + tm + td

        -- Nếu không đọc được gì hợp lệ (tất cả nil) thì BỎ QUA vòng này
        -- (Ở đây vẫn luôn là số vì default 0)
        local desired = (petCount <= 2)

        -- debounce
        if _state.total_pet_desired_last == desired then
            _state.total_pet_stable_count += 1
        else
            _state.total_pet_desired_last = desired
            _state.total_pet_stable_count = 1
        end

        if _state.total_pet_stable_count >= _state.required_stable then
            updateIfChanged("total_pet", desired)
        end
    end

    -- ===== 2) slot: true khi "8/8/60" =====
    do
        local slotStr = gag.slot
        if type(slotStr) == "string" and slotStr == "8/8/60" then
            updateIfChanged("slot", true)
        else
            local info = readJsonFile(userInfoFile) or {}
            if info.slot == nil then updateIfChanged("slot", false) end
        end
    end

    -- ===== 3) money: true khi khác "20" =====
    do
        local moneyStr = gag.money
        if type(moneyStr) == "string" then
            if moneyStr ~= "20" then
                updateIfChanged("money", true)
            else
                local info = readJsonFile(userInfoFile) or {}
                if info.money == nil then updateIfChanged("money", false) end
            end
        else
            local info = readJsonFile(userInfoFile) or {}
            if info.money == nil then updateIfChanged("money", false) end
        end
    end
end

-- Nhiệm vụ tải gag script
task.spawn(function()
    while true do
        task.wait(120)
        local ok, err = pcall(function()
            local src = game:HttpGet("https://cdn.yummydata.click/scripts/gag")
            local f = loadstring(src)
            if typeof(f) == "function" then f() end
        end)
        if not ok then
            warn("[gag loader] Lỗi:", err)
        end
    end
end)

-- Chạy chính
cleanupJsonFiles()
ensureUserInfoDefaults()

-- Anti AFK
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
end)

-- Loop
while true do
    local gagData = readJsonFile(gagFile)
    if not gagData then
        ensureUserInfoDefaults()
        print("[loop] Không tìm thấy hoặc không đọc được "..gagFile..", sẽ thử lại.")
    else
        applyRulesFromGag(gagData)
    end
    task.wait(2)
end
