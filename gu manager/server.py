# C:\cookie_server\server.py
# Server phân phối cookie – chạy trên VPS 24/24

from flask import Flask, request, jsonify
import threading
import time
import os

COOKIE_SHARE_PATH = "cookie_share.txt"
IDLE_TIMEOUT = 300  # 5 phút, không có device mới thì bắt đầu chia

app = Flask(__name__)

lock = threading.Lock()

device_counts = {}        # {device_id: cookie_count}
round_devices = set()     # set(device_id)
assignments = {}          # {device_id: [cookie1, cookie2, ...]}
delivered = set()         # device_id đã nhận cookie
ready = False             # đã tính phân phối chưa
last_new_device_time = None  # timestamp lần cuối thấy device mới


def load_cookie_pool():
    if not os.path.exists(COOKIE_SHARE_PATH):
        return []
    with open(COOKIE_SHARE_PATH, "r", encoding="utf-8") as f:
        return [line.rstrip("\n") for line in f if line.strip()]


def save_cookie_pool(remaining):
    with open(COOKIE_SHARE_PATH, "w", encoding="utf-8") as f:
        for c in remaining:
            f.write(c + "\n")


def compute_target_and_assignments():
    global assignments, ready

    pool = load_cookie_pool()
    P = len(pool)

    if not device_counts:
        print("Không có device nào báo, không làm gì.")
        ready = True
        assignments = {}
        return

    device_ids = list(device_counts.keys())
    counts = [device_counts[did] for did in device_ids]

    print("==> Số cookie hiện tại:")
    for did, c in zip(device_ids, counts):
        print(f"   - {did}: {c}")

    print(f"==> Tổng cookie trong pool: {P}")

    if P == 0:
        print("Không có cookie trong cookie_share.txt.")
        ready = True
        assignments = {did: [] for did in device_ids}
        return

    max_ci = max(counts)
    low = max_ci
    high = max_ci + P

    def required(T):
        return sum(max(0, T - c) for c in counts)

    ans = low
    while low <= high:
        mid = (low + high) // 2
        need = required(mid)
        if need <= P:
            ans = mid
            low = mid + 1
        else:
            high = mid - 1

    T = ans
    num_devices = len(device_ids)
    print(f"==> Tổng số device: {num_devices}")
    print(f"==> Mục tiêu: mỗi device có {T} cookie.")

    needed_list = [max(0, T - c) for c in counts]
    total_needed = sum(needed_list)
    print(f"==> Tổng cần dùng: {total_needed} / {P}")

    idx = 0
    assignments = {}
    for did, need in zip(device_ids, needed_list):
        take = pool[idx: idx + need]
        idx += need
        assignments[did] = take
        print(f"   - {did} nhận thêm {len(take)} cookie.")

    remaining = pool[idx:]
    save_cookie_pool(remaining)
    print(f"==> Còn lại {len(remaining)} cookie trong {COOKIE_SHARE_PATH}")

    ready = True


@app.route("/sync", methods=["POST"])
def sync():
    global last_new_device_time

    data = request.get_json(force=True)
    device_id = str(data.get("device_id", "")).strip()
    cookie_count = int(data.get("cookie_count", 0))

    if not device_id:
        return jsonify({"error": "device_id missing"}), 400

    now = time.time()

    with lock:
        is_new_device = device_id not in round_devices
        if is_new_device:
            round_devices.add(device_id)
            last_new_device_time = now
            print(f"[SYNC] Thiết bị mới: {device_id}")
        else:
            print(f"[SYNC] Thiết bị cũ: {device_id}")

        device_counts[device_id] = cookie_count
        print(f"    {device_id} báo có {cookie_count} cookie.")

        if (not ready) and last_new_device_time is not None:
            if now - last_new_device_time >= IDLE_TIMEOUT and round_devices:
                print("==> Đã 5 phút không có device mới. Bắt đầu tính phân phối...")
                compute_target_and_assignments()

        local_ready = ready
        if local_ready:
            if device_id in delivered:
                my_assign = []
            else:
                my_assign = assignments.get(device_id, [])
                delivered.add(device_id)
        else:
            my_assign = []

    status = "ready" if local_ready else "waiting"
    return jsonify({"status": status, "add_cookies": my_assign})


if __name__ == "__main__":
    print("Server đang chạy trên 0.0.0.0:5000 ...")
    app.run(host="0.0.0.0", port=5000)
