-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/create%20file%20to%20change%20acc.lua"))()

--// Basic
local Players       = game:GetService("Players")
local HttpService   = game:GetService("HttpService")
local player        = Players.LocalPlayer
local username      = player.Name
local userId        = player.UserId

--// Files
local userInfoFile  = tostring(userId) .. "-info.json"  -- đích
local gagFile       = tostring(username) .. "_gag.json" -- nguồn

--// Helpers: FS
local function safeJSONDecode(s)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(s)
    end)
    if ok and type(data) == "table" then
        return data
    end
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

-- Xoá mọi .json trừ 2 file cần giữ
local function cleanupJsonFiles()
    local files = listfiles("") -- thư mục hiện tại
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local baseName = file:match("[^/\\]+$") -- chỉ lấy tên
            if baseName ~= userInfoFile and baseName ~= gagFile then
                delfile(baseName)
                print("[cleanup] Đã xoá:", baseName)
            end
        end
    end
end

-- Đảm bảo -info.json tồn tại và có key mặc định
local function ensureUserInfoDefaults()
    local info = readJsonFile(userInfoFile) or {}
    local changed = false

    if info.total_pet == nil then
        info.total_pet = 0
        changed = true
    end
    if info.slot == nil then
        info.slot = "notok"
        changed = true
    end
    if info.money == nil then
        info.money = "notok"
        changed = true
    end

    if changed then
        writeJsonFile(userInfoFile, info)
        print("[init] Khởi tạo mặc định cho "..userInfoFile)
    end
end

-- So sánh và chỉ ghi khi có thay đổi
local function updateIfChanged(key, newVal)
    local info = readJsonFile(userInfoFile) or {}
    if info[key] ~= newVal then
        local old = info[key]
        info[key] = newVal
        writeJsonFile(userInfoFile, info)
        print(("[update] %s: %s -> %s"):format(key, tostring(old), tostring(newVal)))
    end
end

-- Áp dụng luật cập nhật theo _gag.json
local function applyRulesFromGag(gag)
    if type(gag) ~= "table" then return end

    -- 1) total_pet rule
    do
        local petCount = gag.total_pet
        if typeof(petCount) == "number" then
            if petCount <= 2 then
                updateIfChanged("total_pet", 60)
            else
                updateIfChanged("total_pet", 0)
            end
        else
            -- Không có số hợp lệ => giữ 0
            updateIfChanged("total_pet", 0)
        end
    end

    -- 2) slot rule
    do
        local slotStr = gag.slot
        if type(slotStr) == "string" and slotStr == "8/8/60" then
            updateIfChanged("slot", "ok")
        else
            -- giữ nguyên (mặc định notok); không ép ghi lại nếu chưa đạt
            local info = readJsonFile(userInfoFile) or {}
            if info.slot == nil then updateIfChanged("slot", "notok") end
        end
    end

    -- 3) money rule
    do
        local moneyStr = gag.money
        if type(moneyStr) == "string" then
            if moneyStr ~= "20" then
                updateIfChanged("money", "ok")
            else
                -- giữ nguyên (mặc định notok)
                local info = readJsonFile(userInfoFile) or {}
                if info.money == nil then updateIfChanged("money", "notok") end
            end
        else
            -- Không có chuỗi hợp lệ => giữ nguyên
            local info = readJsonFile(userInfoFile) or {}
            if info.money == nil then updateIfChanged("money", "notok") end
        end
    end
end

-- Tải script gag định kỳ (an toàn với pcall)
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

-- Chạy
cleanupJsonFiles()
ensureUserInfoDefaults()

-- Vòng lặp cập nhật: đọc _gag.json và apply luật
while true do
    local gagData = readJsonFile(gagFile)
    if not gagData then
        -- Không có _gag.json hoặc lỗi decode
        -- Đảm bảo file đích vẫn có mặc định
        ensureUserInfoDefaults()
        print("[loop] Không tìm thấy hoặc không đọc được "..gagFile..", sẽ thử lại.")
    else
        applyRulesFromGag(gagData)
    end
    task.wait(2) -- lặp mỗi 2 giây
end
