--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/hope%20bf.lua"))() 

--[[ ============================================================
     AUTO SERVER HOP
     - Hop sau X phút
     - Hop khi có player khác đứng sát (số frame cần = random 1..10)
     - Nhớ server đã đi qua, không quay lại
     - Thử từng server cho tới khi teleport thành công (bỏ qua server đầy)
     Lưu ý: đặt script vào AUTOEXEC để tự chạy lại sau mỗi lần hop.
   ============================================================ ]]

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- ===================== CẤU HÌNH =====================
getgenv().HopMinutes    = 600    -- hop sau X phút
getgenv().PlayerRange   = 5     -- khoảng cách phát hiện player (studs)
getgenv().CheckInterval = 0.8   -- giãn cách giữa các lần check (giây)
getgenv().TeleportGap   = 0.3   -- giãn cách giữa các cú spam teleport (giây)
getgenv().SkipFull      = false  -- bo qua server day (Count >= 12) cho do ton luot
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

local wasVisited = (visited[game.JobId] == true)  -- server này đã từng đi qua chưa?
visited[game.JobId] = true                        -- đánh dấu đã đi

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

saveVisited()   -- luu lai: server hien tai = da thuc su vao

-- ---------- lấy danh sách server ----------
-- Server tra list bat dong bo: chi DUNG mot cu goi (luc load xong) tra ve full list,
-- cac cu khac tra rong. Nen phai spam InvokeServer that nhanh, vo duoc lan nao
-- non-empty thi lay luon (giong cach UI Server Browser cua game lam).
local function getServers()
    for round = 1, 2 do                          -- thử lại tối đa 2 lượt
        for p = 1, 600 do
            local ok, l = pcall(function() return SB:InvokeServer(p) end)
            if ok and type(l) == "table" and next(l) ~= nil then
                return l                          -- tóm được full list
            end
            task.wait()                           -- spam nhanh, ~1 frame/lan
        end
    end
    return {}
end

-- ---------- hop: spam teleport cho toi khi vao duoc ----------
-- Teleport thanh cong = roi session. OnTeleport bao khi teleport that su bat dau
-- -> ngung spam ngay de khong tu de len cu teleport dang chay.
-- KHONG danh dau server fail la visited (visited chi la server da thuc su vao).
local hopping = false
local leaving = false
plr.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
        leaving = true
    end
end)

local function HopServer()
    if hopping then return end
    hopping = true
    print("[Hop] === Bat dau spam teleport ===")
    while not leaving do
        local list = getServers()
        local candidates = {}
        for jobId, info in pairs(list) do
            if type(jobId) == "string"                 -- key = JobId
               and jobId ~= game.JobId
               and not visited[jobId]
               and not (getgenv().SkipFull and type(info) == "table"
                        and info.Count and info.Count >= 12) then   -- bo qua server day
                candidates[#candidates + 1] = jobId
            end
        end
        -- xáo trộn
        for i = #candidates, 2, -1 do
            local j = math.random(1, i)
            candidates[i], candidates[j] = candidates[j], candidates[i]
        end
        print("[Hop] spam qua", #candidates, "server...")

        for _, pick in ipairs(candidates) do
            if leaving then return end                 -- teleport da bat dau -> dung
            pcall(function() SB:InvokeServer("teleport", pick) end)
            task.wait(getgenv().TeleportGap)
        end
        if not leaving then
            print("[Hop] het list, lay list moi spam tiep...")
        end
    end
end

-- ---------- khoảng cách tới player gần nhất (dùng cho debug) ----------
local function nearestPlayerDist()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return math.huge end
    local best = math.huge
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= plr and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
            local d = (other.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < best then best = d end
        end
    end
    return best
end

print(("[AutoHop] === Khoi dong === Server: %s | Da luu %d server"):format(
    game.JobId, (function() local n=0 for _ in pairs(visited) do n=n+1 end return n end)()))

-- ---------- nếu server hiện tại đã từng đi qua -> hop ngay ----------
if wasVisited then
    print("[AutoHop] Server hien tai DA TUNG di qua -> hop ngay.")
    HopServer()                                  -- lặp tới khi roi server (khong tra ve)
    return                                        -- (chi toi day neu khong con server nao)
else
    print("[AutoHop] Server moi, chua tung den.")
end

-- ===================== TASK 1: hop sau X phút =====================
task.spawn(function()
    print(("[AutoHop] Hen gio: se hop sau %d phut."):format(getgenv().HopMinutes))
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
            print(("[AutoHop] Player gan! %d/%d"):format(streak, need))
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

-- ===================== TASK 3: heartbeat (báo còn sống mỗi 30s) =====================
task.spawn(function()
    local startTime = os.clock()
    while task.wait(30) do
        local left = math.max(0, getgenv().HopMinutes * 60 - (os.clock() - startTime))
        local nd = nearestPlayerDist()
        print(("[AutoHop] dang chay | player gan nhat: %s studs | con ~%.1f phut nua hop gio"):format(
            nd == math.huge and "khong co" or string.format("%.0f", nd),
            left / 60))
    end
end)

print(("[AutoHop] Da chay. Hop sau %d phut hoac khi co player trong %d studs."):format(
    getgenv().HopMinutes, getgenv().PlayerRange))
