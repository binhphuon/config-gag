import time

# Đường dẫn tới các file
svv_file_path = 'svv.txt'
server_links_file_path = '/storage/emulated/0/Download/Shouko/server_links.txt'

# Hàm đọc file svv.txt
def read_svv_file():
    with open(svv_file_path, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Hàm đọc file server_links.txt
def read_server_links_file():
    with open(server_links_file_path, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Hàm ghi lại nội dung vào file server_links.txt
def write_server_links_file(content):
    with open(server_links_file_path, 'w') as file:
        for line in content:
            file.write(line + '\n')

# Hàm thay thế các dòng trong server_links.txt với svv mới
def update_server_links(svv_lines, server_links_lines, start_index):
    total_svv = len(svv_lines)
    
    # Tạo danh sách 5 dòng cần thay thế
    updated_svv_lines = []
    for i in range(5):
        svv_index = (start_index + i) % total_svv  # Lấy dòng với chỉ số vòng lặp
        updated_svv_lines.append(svv_lines[svv_index])
    
    # Cập nhật các dòng trong server_links.txt
    for i in range(5):
        server_links_lines[i] = server_links_lines[i].split(',')[0] + ',' + updated_svv_lines[i]

    return server_links_lines

# Hàm chính thực hiện vòng lặp cập nhật
def main():
    svv_lines = read_svv_file()  # Đọc dữ liệu từ svv.txt
    server_links_lines = read_server_links_file()  # Đọc dữ liệu từ server_links.txt
    start_index = 0  # Chỉ số bắt đầu của vòng lặp

    while True:
        # Cập nhật server_links.txt với 5 dòng svv từ svv.txt
        server_links_lines = update_server_links(svv_lines, server_links_lines, start_index)

        # Ghi lại kết quả vào server_links.txt
        write_server_links_file(server_links_lines)

        # In ra thông báo mỗi lần cập nhật
        print("Updated server_links.txt with new SVV values.")
        
        # Cập nhật chỉ số bắt đầu cho lần lặp tiếp theo
        start_index = (start_index + 5) % len(svv_lines)

        # Chờ 5 phút trước khi tiếp tục
        time.sleep(5 * 60)

if __name__ == "__main__":
    main()
