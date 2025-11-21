-- XÓA TOÀN BỘ FILE TRONG THƯ MỤC CHỨA SCRIPT HIỆN TẠI
-- YÊU CẦU: executor có hỗ trợ: getscriptfilepath, listfiles, delfile, isfolder, delfolder

-- Kiểm tra hỗ trợ file system
if not listfiles or not delfile then
    warn("[DELETE] Executor của bạn không hỗ trợ listfiles/delfile.")
    return
end

-- Lấy đường dẫn file hiện tại (từ executor)
local scriptPath
do
    local ok, result = pcall(function()
        -- nhiều executor có hàm này
        return getscriptfilepath and getscriptfilepath()
    end)

    if ok and type(result) == "string" then
        scriptPath = result
    else
        -- fallback: nếu không lấy được, dùng root "" (cực kỳ nguy hiểm)
        -- NÊN sửa lại thành đường dẫn cụ thể, ví dụ: "workspace/config-gag"
        scriptPath = ""
    end
end

-- Tách ra thư mục chứa script: "C:/folder1/folder2/script.lua" -> "C:/folder1/folder2"
local currentFolder = scriptPath:match("^(.*[\\/])")
if not currentFolder then
    -- không tìm được dấu / hoặc \ -> coi như đang ở root
    currentFolder = ""
end

print("[DELETE] Thư mục hiện tại:", currentFolder ~= "" and currentFolder or "(root)")

-- Lấy danh sách file/folder trong thư mục hiện tại
local files
local ok, err = pcall(function()
    files = listfiles(currentFolder)
end)

if not ok or type(files) ~= "table" then
    warn("[DELETE] Không thể listfiles trong thư mục:", currentFolder, err)
    return
end

-- Xoá từng file / folder
local deletedCount = 0
for _, path in ipairs(files) do
    -- Bỏ qua chính file script hiện tại (nếu cùng folder)
    if scriptPath ~= "" and path == scriptPath then
        print("[DELETE] Bỏ qua file đang chạy:", path)
    else
        local isFolder = isfolder and isfolder(path)
        local okDel, errDel

        if isFolder and delfolder then
            okDel, errDel = pcall(delfolder, path)
        else
            okDel, errDel = pcall(delfile, path)
        end

        if okDel then
            deletedCount += 1
            print(("[DELETE] Đã xoá: %s"):format(path))
        else
            warn(("[DELETE] Lỗi khi xoá %s: %s"):format(path, tostring(errDel)))
        end
    end
end

print(("[DELETE] Hoàn tất. Đã xoá %d mục trong thư mục hiện tại."):format(deletedCount))
