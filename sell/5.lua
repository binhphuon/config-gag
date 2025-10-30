--// Player & Services
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

--// File names
local userId       = player.UserId
local userInfoFile = tostring(userId) .. "-info.json"

--// Helpers: file ops
local function writeJsonFile(fileName, data)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then
        warn("[writeJsonFile] JSONEncode failed:", encoded)
        return
    end
    pcall(writefile, fileName, encoded)
end

local function readJsonFile(fileName)
    if isfile and isfile(fileName) then
        local ok, content = pcall(readfile, fileName)
        if not ok then return nil end
        local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, content)
        if not ok2 then return nil end
        return decoded
    end
    return nil
end

--// (Optional) cleanup: chỉ giữ lại {userId}-info.json
local function cleanupJsonFiles()
    if not listfiles or not delfile then return end
    local files = listfiles("")
    for _, path in ipairs(files) do
        if path:match("%.json$") then
            local base = path:match("[^/\\]+$") or path
            if base ~= userInfoFile then
                pcall(delfile, base)
                print("🧹 Đã xoá file:", base)
            end
        end
    end
end

--// Count helpers
local TARGET_NAME = "Lucky Arrow"

local function countLuckyArrowIn(instance)
    if not instance then return 0 end
    local count = 0
    -- Duyệt cả con cháu để chắc chắn (Tool thường là con trực tiếp của Character/Backpack)
    for _, obj in ipairs(instance:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name == TARGET_NAME then
            count += 1
        end
    end
    -- Phòng trường hợp Tool là con trực tiếp (nếu GetDescendants bỏ sót do quyền), duyệt thêm 1 vòng nông:
    for _, obj in ipairs(instance:GetChildren()) do
        if obj:IsA("Tool") and obj.Name == TARGET_NAME then
            count += 1
        end
    end
    return count
end

local function getTotalLuckyArrow()
    local total = 0

    -- Backpack
    local backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack", 5)
    if backpack then
        total += countLuckyArrowIn(backpack)
    else
        warn("[getTotalLuckyArrow] Không tìm thấy Backpack")
    end

    -- Character (tool đang cầm → Tool.Parent = Character)
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        total += countLuckyArrowIn(character)
    else
        warn("[getTotalLuckyArrow] Không có Character hiện tại")
    end

    return total
end

local function getPlayerMoney()
    local stats = player:FindFirstChild("PlayerStats") or player:WaitForChild("PlayerStats", 5)
    if not stats then
        warn("[getPlayerMoney] Không tìm thấy folder PlayerStats")
        return 0
    end
    local moneyValue = stats:FindFirstChild("Money")
    if moneyValue and moneyValue:IsA("NumberValue") then
        return moneyValue.Value
    end
    warn("[getPlayerMoney] Không tìm thấy NumberValue 'Money' trong PlayerStats")
    return 0
end

local function getPlayerLevel()
    local stats = player:FindFirstChild("PlayerStats") or player:WaitForChild("PlayerStats", 5)
    if not stats then
        warn("[getPlayerLevel] Không tìm thấy folder PlayerStats")
        return 0
    end
    local levelValue = stats:FindFirstChild("Level")
    if levelValue and levelValue:IsA("NumberValue") then
        return levelValue.Value
    end
    warn("[getPlayerLevel] Không tìm thấy NumberValue 'Level' trong PlayerStats")
    return 0
end

--// Update writer
local function updateUserInfo()
    local total_arrow = 0
    local money       = 0
    local level       = 0

    pcall(function()
        total_arrow = getTotalLuckyArrow() -- Backpack + Character (equipped)
        money       = getPlayerMoney()
        level       = getPlayerLevel()
    end)

    -- Nếu sau này bạn thêm key khác, giữ lại; hiện tại chỉ cần hai key
    local userInfo = readJsonFile(userInfoFile) or {}
    userInfo.total_arrow = total_arrow
    userInfo.money       = money
    userInfo.level       = level

    writeJsonFile(userInfoFile, userInfo)
    print(("[info] Cập nhật %s → total_arrow=%d, money=%s")
        :format(userInfoFile, total_arrow, tostring(money), tostring(level)))
end

--// Chạy
cleanupJsonFiles()  -- xoá .json thừa, chỉ giữ {userId}-info.json

-- Cập nhật định kỳ
while true do
    updateUserInfo()
    task.wait(2) -- mỗi 2 giây cập nhật 1 lần
end

