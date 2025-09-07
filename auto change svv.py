import time
import os

# Đường dẫn tới các file
svv_file_path = 'svv.txt'
server_links_file_path = '/storage/emulated/0/Download/Shouko/server_links.txt'

# File lưu trạng thái vị trí SVV đã dùng lần gần nhất
state_file_path = 'svv_state.txt'  # đặt cạnh script; có thể đổi sang đường dẫn tuyệt đối nếu muốn

# --- HÀM XỬ LÝ FILE DỮ LIỆU ---

def read_svv_file():
    with open(svv_file_path, 'r', encoding='utf-8') as file:
        return [line.strip() for line in file.readlines() if line.strip()]

def read_server_links_file():
    with open(server_links_file_path, 'r', encoding='utf-8') as file:
        return [line.strip() for line in file.readlines()]

def write_server_links_file(content):
    with open(server_links_file_path, 'w', encoding='utf-8') as file:
        for line in content:
            file.write(line + '\n')

# --- HÀM LƯU/ĐỌC TRẠNG THÁI ---

def load_last_index(total_svv: int) -> int:
    """
    Đọc chỉ số đã dùng lần gần nhất từ state_file_path.
    Nếu file không tồn tại/không hợp lệ thì trả về 0.
    """
    try:
        if not os.path.exists(state_file_path):
            return 0
        with open(state_file_path, 'r', encoding='utf-8') as f:
            raw = f.read().strip()
            if raw == '':
                return 0
            idx = int(raw)
            # Đảm bảo luôn nằm trong [0, total_svv)
            return idx % max(total_svv, 1)
    except Exception:
        # Nếu lỗi (ví dụ nội dung hỏng), bắt đầu lại từ 0
        return 0

def save_last_index(idx: int) -> None:
    """
    Ghi chỉ số hiện tại vào state_file_path (ghi đè).
    """
    with open(state_file_path, 'w', encoding='utf-8') as f:
        f.write(str(idx))

# --- HÀM CẬP NHẬT 4 DÒNG ---

def update_server_links(svv_lines, server_links_lines, start_index):
    total_svv = len(svv_lines)
    if total_svv == 0:
        raise ValueError("File svv.txt trống – không có dòng nào để cập nhật.")

    # Tạo danh sách 4 dòng cần thay thế (xoay vòng nếu cần)
    updated_svv_lines = []
    for i in range(4):
        svv_index = (start_index + i) % total_svv
        updated_svv_lines.append(svv_lines[svv_index])

    # Đảm bảo server_links_lines có ít nhất 4 dòng
    if len(server_links_lines) < 4:
        raise ValueError("server_links.txt phải có tối thiểu 4 dòng để cập nhật.")

    # Cập nhật 4 dòng đầu trong server_links.txt
    for i in range(4):
        # Giữ phần trước dấu phẩy đầu tiên, thay SVV phía sau
        prefix = server_links_lines[i].split(',', 1)[0]
        server_links_lines[i] = f"{prefix},{updated_svv_lines[i]}"

    return server_links_lines

# --- CHƯƠNG TRÌNH CHÍNH ---

def main():
    svv_lines = read_svv_file()
    server_links_lines = read_server_links_file()

    total_svv = len(svv_lines)
    if total_svv == 0:
        print("svv.txt trống – kết thúc chương trình.")
        return

    # Đọc vị trí đã dùng lần trước (nếu có)
    start_index = load_last_index(total_svv)

    while True:
        # Cập nhật server_links.txt với 4 dòng svv từ svv.txt
        server_links_lines = update_server_links(svv_lines, server_links_lines, start_index)

        # Ghi lại kết quả vào server_links.txt
        write_server_links_file(server_links_lines)

        # Tính vị trí bắt đầu cho vòng sau và LƯU LẠI
        next_start_index = (start_index + 4) % total_svv
        save_last_index(next_start_index)

        print(f"Updated server_links.txt với SVV từ vị trí {start_index} đến {(start_index + 4) % total_svv}. "
              f"Lần sau sẽ bắt đầu từ {next_start_index}.")

        # Cập nhật chỉ số bắt đầu cho lần lặp tiếp theo trong bộ nhớ
        start_index = next_start_index

        # Chờ 4 phút
        time.sleep(4 * 3600)

if __name__ == "__main__":
    main()
