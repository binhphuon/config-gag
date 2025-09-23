-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/main/create%20file%20to%20change%20acc.lua"))()

local player   = game.Players.LocalPlayer
local username = player.Name
local userId   = player.UserId

local HttpService = game:GetService("HttpService")

-- Tên file chính cần giữ lại
local userInfoFile = userId .. "-info.json"
local gagFile      = username .. "_gag.json"

-- 🧹 Xoá tất cả file .json trừ 2 file cần giữ
-- 🧹 Xoá tất cả file .json trừ 2 file cần giữ
local function cleanupJsonFiles()
    local files = listfiles("") -- lấy toàn bộ file trong thư mục hiện tại
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local baseName = file:match("[^/\\]+$") -- chỉ lấy tên file
            if baseName ~= userInfoFile and baseName ~= gagFile then
                delfile(baseName) -- xoá file thừa
                print("Đã xoá file:", baseName)
            end
        end
    end
end


-- Hàm để đọc file JSON và trả về dữ liệu đã được giải mã
local function readJsonFile(fileName)
    if isfile(fileName) then
        local jsonData = readfile(fileName)
        return HttpService:JSONDecode(jsonData)
    else
        return nil
    end
end

-- Hàm để ghi dữ liệu JSON vào file
local function writeJsonFile(fileName, data)
    local jsonData = HttpService:JSONEncode(data)
    writefile(fileName, jsonData)
end

-- Hàm cập nhật file {UserId}-info.json với giá trị từ {username}_gag.json
local function updateTotalPet()
    local userGagData = readJsonFile(gagFile)
    if not userGagData then
        print(gagFile .. " không tồn tại, bỏ qua vòng lặp.")
        return
    end

    if userGagData.total_pet then
        local userInfo = readJsonFile(userInfoFile) or {}
        userInfo.total_pet = userGagData.total_pet + userGagData.total_mythical + userGagData.total_divine
        writeJsonFile(userInfoFile, userInfo)
        print("Cập nhật total_pet trong " .. userInfoFile .. ": " .. userGagData.total_pet)
    else
        print("Không tìm thấy key 'total_pet' trong " .. gagFile)
    end
end

-- 🧹 Gọi cleanup ngay khi script bắt đầu
--cleanupJsonFiles()

-- Lặp cập nhật mỗi 10 giây
while true do
    updateTotalPet()
    task.wait(2)  -- Chờ 10 giây trước khi cập nhật lại 
end
