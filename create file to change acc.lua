local player = game.Players.LocalPlayer
local username = player.Name
local userId = player.UserId

-- Hàm để đọc file JSON và trả về dữ liệu đã được giải mã
local function readJsonFile(fileName)
    if isfile(fileName) then
        local jsonData = readfile(fileName)
        return game:GetService("HttpService"):JSONDecode(jsonData)
    else
        return nil
    end
end

-- Hàm để ghi dữ liệu JSON vào file
local function writeJsonFile(fileName, data)
    local jsonData = game:GetService("HttpService"):JSONEncode(data)
    writefile(fileName, jsonData)
end

-- Hàm cập nhật file {UserId}-info.json với giá trị từ {username}_gag.json
local function updateTotalPet()
    -- Kiểm tra nếu file {username}_gag.json tồn tại
    local userGagData = readJsonFile(username .. "_gag.json")
    if not userGagData then
        -- Nếu file không tồn tại, bỏ qua vòng lặp này và tiếp tục vòng lặp sau
        print(username .. "_gag.json không tồn tại, bỏ qua vòng lặp.")
        return  -- Dừng hàm và quay lại vòng lặp chính
    end

    -- Kiểm tra xem key "total_pet" có tồn tại trong file không
    if userGagData.total_pet then
        -- Đọc file {UserId}-info.json (hoặc tạo mới nếu chưa có)
        local userInfo = readJsonFile(userId .. "-info.json") or {}

        -- Cập nhật giá trị của key "total_pet"
        userInfo.total_pet = userGagData.total_pet

        -- Ghi lại vào file {UserId}-info.json
        writeJsonFile(userId .. "-info.json", userInfo)
        print("Cập nhật total_pet trong " .. userId .. "-info.json: " .. userGagData.total_pet)
    else
        print("Không tìm thấy key 'total_pet' trong " .. username .. "_gag.json")
    end
end

-- Cập nhật "total_pet" mỗi 10 giây
while true do
    updateTotalPet()
    task.wait(10)  -- Chờ 10 giây trước khi cập nhật lại
end
