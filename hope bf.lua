--[[ ============================================================
     AUTO SERVER HOP
     - Hop sau X phút
     - Hop khi có player khác đứng sát (số frame cần = random 1..10)
     - Nhớ server đã đi qua, không quay lại
     - Chỉ nhận server có Count > MinPlayers
     Lưu ý: đặt script vào AUTOEXEC để tự chạy lại sau mỗi lần hop.
   ============================================================ ]]

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- ===================== CẤU HÌNH =====================
getgenv().HopMinutes    = 120    -- hop sau X phút
getgenv().PlayerRange   = 5     -- khoảng cách phát hiện player (studs)
getgenv().CheckInterval = 0.8   -- giãn cách giữa các lần check (giây)
getgenv().MinPlayers    = 5     -- chỉ nhận server có Count > số này
-- ====================================================

local Players      = game:GetService("Players")
local RS           = game:GetService("ReplicatedStorage")
local HttpService  = game:GetService("HttpService")
local SB           = RS:WaitForChild("__ServerBrowser")
local plr          = Players.LocalPlayer

-- seed random theo UserId -> mỗi máy 1 dãy số khác nhau (chống 2 bot trùng ngưỡng)
math.randomseed(os.clock() * 1e6 + (plr.UserId % 100000))

-- ---------- danh sách server đã đi qua ----------
local VISIT_FILE = "visited_servers.json"
local visited = {}

pcall(function()
    if isfile and isfile(VISIT_FILE) then
        for _, id in ipairs(HttpService:JSONDecode(readfile(VISIT_FILE))) do
            visited[id] = true
        end
    end
end)
if next(visited) == nil and getgenv().VisitedServers then
    visited = getgenv().VisitedServers          -- dự phòng nếu không có file API
end
getgenv().VisitedServers = visited
visited[game.JobId] = true                      -- server hiện tại = đã đi

local function saveVisited()
    getgenv().VisitedServers = visited
    pcall(function()
        if writefile then
            local arr = {}
            for id in pairs(visited) do arr[#arr + 1] = id end
            writefile(VISIT_FILE, HttpService:JSONEncode(arr))
        end
    end)
end

-- ---------- lấy danh sách server (chờ warm-up, thử nhiều trang) ----------
local function getServers()
    local t0 = os.clock()
    while os.clock() - t0 < 20 do                -- chờ tối đa 20s cho cache load
        for _, p in ipairs({1, 5, 10, 30, 60, 100}) do
            local ok, list = pcall(function() return SB:InvokeServer(p) end)
            if ok and type(list) == "table" and next(list) ~= nil then
                return list                      -- trang nào có data thì lấy luôn
            end
        end
        task.wait(0.5)
    end
    return {}
end

-- ---------- hop ----------
local function HopServer()
    local list = getServers()
    local candidates = {}
    for jobId, info in pairs(list) do
        if jobId ~= game.JobId
           and not visited[jobId]
           and type(info) == "table" and info.Count
           and info.Count > getgenv().MinPlayers then
            candidates[#candidates + 1] = jobId
        end
    end
    if #candidates == 0 then
        warn("[Hop] Het server moi thoa dieu kien (>" .. getgenv().MinPlayers .. " nguoi).")
        return false
    end
    local pick = candidates[math.random(1, #candidates)]
    visited[pick] = true
    saveVisited()                                -- lưu trước khi nhảy
    print("[Hop] Nhay sang server:", pick)
    SB:InvokeServer("teleport", pick)
    return true
end

-- ===================== TASK 1: hop sau X phút =====================
task.spawn(function()
    task.wait(getgenv().HopMinutes * 60)
    print("[Hop] Het gio, dang hop...")
    HopServer()
end)

-- ===================== TASK 2: hop khi có player sát =====================
task.spawn(function()
    local streak = 0
    local need = math.random(1, 10)
    while task.wait(getgenv().CheckInterval) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        local found = false
        if hrp then
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= plr
                   and other.Character
                   and other.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (other.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist <= getgenv().PlayerRange then
                        found = true
                        break
                    end
                end
            end
        end
        if found then
            if streak == 0 then
                need = math.random(1, 10)        -- roll lại cho mỗi lần chạm mặt mới
            end
            streak = streak + 1
            if streak >= need then
                print("[Hop] Phat hien player sat ben, hop di!")
                HopServer()
                return
            end
        else
            streak = 0                           -- player đi khỏi -> reset
        end
    end
end)

print("[AutoHop] Da chay. Hop sau " .. getgenv().HopMinutes ..
      " phut hoac khi co player trong " .. getgenv().PlayerRange .. " studs.")
