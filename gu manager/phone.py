# phone_client.py
# Script chạy trên Termux (cloud phone)
# pip install requests

import requests
import os
import argparse
import time

# ===== CẤU HÌNH MẶC ĐỊNH =====
DEFAULT_SERVER_URL = "http://160.25.73.213:5000"  # VPS của bạn
DEFAULT_COOKIE_PATH = "/sdcard/Download/cookie.txt"
DEFAULT_INTERVAL = 180  # giây giữa mỗi lần sync (5 phút)


def count_cookies(path):
    """Đếm số dòng (bỏ dòng trống) trong cookie.txt.
       Nếu file chưa tồn tại thì tạo file rỗng rồi trả về 0.
    """
    folder = os.path.dirname(path)
    try:
        with open(path, "r", encoding="utf-8") as f:
            return sum(1 for line in f if line.strip())
    except FileNotFoundError:
        # Tạo thư mục nếu cần
        if folder and not os.path.exists(folder):
            os.makedirs(folder, exist_ok=True)
        # Tạo file rỗng
        with open(path, "w", encoding="utf-8") as f:
            pass
        return 0


def append_cookies(path, cookies):
    """Append danh sách cookie vào cuối file cookie.txt."""
    folder = os.path.dirname(path)
    if folder and not os.path.exists(folder):
        os.makedirs(folder, exist_ok=True)

    with open(path, "a", encoding="utf-8") as f:
        for c in cookies:
            c = c.rstrip("\n")
            if c:
                f.write(c + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--id", required=True, help="device_id, ví dụ: gvip-01")
    parser.add_argument("--server", default=DEFAULT_SERVER_URL,
                        help="URL server, ví dụ: http://160.25.73.213:5000")
    parser.add_argument("--cookie", default=DEFAULT_COOKIE_PATH,
                        help="Đường dẫn cookie.txt")
    parser.add_argument("--interval", type=int, default=DEFAULT_INTERVAL,
                        help="Thời gian nghỉ (giây) giữa mỗi lần sync")
    args = parser.parse_args()

    device_id = args.id
    server_url = args.server.rstrip("/")
    cookie_path = args.cookie
    interval = args.interval

    print(f"[{device_id}] Bắt đầu loop sync. Server = {server_url}")
    print(f"[{device_id}] Cookie file = {cookie_path}")
    print(f"[{device_id}] Interval = {interval} giây\n")

    while True:
        try:
            current_count = count_cookies(cookie_path)
            print(f"[{device_id}] Hiện có {current_count} cookie.")

            payload = {
                "device_id": device_id,
                "cookie_count": current_count,
            }

            try:
                resp = requests.post(
                    f"{server_url}/sync",
                    json=payload,
                    timeout=30
                )
                resp.raise_for_status()
            except Exception as e:
                print(f"[{device_id}] Không kết nối được server: {e}")
                print(f"[{device_id}] Sẽ thử lại sau {interval} giây.\n")
                time.sleep(interval)
                continue

            data = resp.json()
            status = data.get("status", "unknown")
            add_cookies = data.get("add_cookies", [])

            print(f"[{device_id}] Server status = {status}, "
                  f"nhận {len(add_cookies)} cookie.")

            if add_cookies:
                append_cookies(cookie_path, add_cookies)
                new_count = count_cookies(cookie_path)
                print(f"[{device_id}] Sau khi append: {new_count} cookie.\n")
            else:
                print(f"[{device_id}] Không có cookie mới.\n")

            time.sleep(interval)

        except KeyboardInterrupt:
            print(f"[{device_id}] Dừng bởi người dùng.")
            break
        except Exception as e:
            print(f"[{device_id}] Lỗi bất ngờ: {e}")
            time.sleep(interval)


if __name__ == "__main__":
    main()
