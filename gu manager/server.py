# mega_server.py
from flask import Flask, request, jsonify, send_from_directory
import threading
import time
from pathlib import Path
from typing import Dict, List, Set
import logging  # <-- thêm dòng này

# TẮT log HTTP của werkzeug cho đỡ trôi console
logging.getLogger("werkzeug").setLevel(logging.ERROR)
# =========================
# CẤU HÌNH
# =========================
HOST = "0.0.0.0"
PORT = 5000

BASE_DIR = Path(__file__).resolve().parent

COMMAND_FILE      = BASE_DIR / "command.txt"
UNINSTALL_FILE    = BASE_DIR / "uninstall.txt"
BACKUP_APPS_DIR   = BASE_DIR / "backup_apps"
AUTOEXEC_DIR      = BASE_DIR / "Autoexec"
UPDATE_CLIENT_DIR = BASE_DIR / "update_client"

POLL_ENDPOINT = "/poll"   # remote điều khiển
SYNC_ENDPOINT = "/sync"   # chia cookie (MANUAL ONLY)

COOKIE_SHARE_PATH = BASE_DIR / "cookie_share.txt"

app = Flask(__name__)
lock = threading.Lock()

# =========================
# 1. TRẠNG THÁI REMOTE CONTROL
# =========================
# devices[id] = {
#   "last_seen": timestamp,
#   "last_result": ...,
#   "last_cookie_count": int
# }
devices: Dict[str, Dict] = {}
pending_jobs: Dict[str, List[dict]] = {}
jobs_waiting: Dict[int, Set[str]] = {}
next_job_id = 1

last_new_device_time_for_menu = time.time()
seen_devices_for_menu: Set[str] = set()

# =========================
# 2. TRẠNG THÁI CHIA COOKIE (MANUAL ROUND)
# =========================
device_counts = {}           # {device_id: cookie_count}
round_devices = set()        # các device tham gia round hiện tại
round_base_devices = set()   # snapshot device trong round
assignments = {}             # {device_id: [cookie1, cookie2, ...]}
delivered = set()            # device đã nhận phần cookie
ready = False                # đã tính xong phân phối chưa
round_closed = False         # round cookie đã khép lại (không chia nữa)


# =========================
# HÀM HỖ TRỢ COOKIE
# =========================
def load_cookie_pool() -> List[str]:
    if not COOKIE_SHARE_PATH.exists():
        return []
    with COOKIE_SHARE_PATH.open("r", encoding="utf-8") as f:
        return [line.rstrip("\n") for line in f if line.strip()]


def save_cookie_pool(remain: List[str]):
    with COOKIE_SHARE_PATH.open("w", encoding="utf-8") as f:
        for c in remain:
            f.write(c + "\n")


def compute_target_and_assignments():
    """
    Tính phân phối cookie theo device_counts, chỉ được phép THÊM cookie từ pool.
    (MANUAL – được gọi khi chọn chức năng #5 trong menu)
    """
    global assignments, ready, round_base_devices

    pool = load_cookie_pool()
    P = len(pool)

    if not device_counts:
        print("[COOKIE] Không có device nào trong round, bỏ qua.")
        ready = True
        assignments = {}
        round_base_devices = set()
        return

    device_ids = list(device_counts.keys())
    counts = [device_counts[d] for d in device_ids]

    round_base_devices = set(device_ids)

    print("\n[COOKIE] Device counts:")
    for did, c in zip(device_ids, counts):
        print(f"  - {did}: {c}")

    print(f"[COOKIE] Pool size = {P}")

    if P == 0:
        assignments = {d: [] for d in device_ids}
        ready = True
        return

    max_c = max(counts)
    low = max_c
    high = max_c + P

    def required(T: int) -> int:
        # số cookie cần thêm để tất cả đạt T
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

    needed = [max(0, T - c) for c in counts]

    assignments.clear()
    idx = 0
    for did, need in zip(device_ids, needed):
        take = pool[idx: idx + need]
        idx += need
        assignments[did] = take
        print(f"[COOKIE] {did} nhận {len(take)} cookie.")

    remain = pool[idx:]
    save_cookie_pool(remain)
    print(f"[COOKIE] Còn lại {len(remain)} cookie trong cookie_share.txt")

    ready = True
    print("[COOKIE] ĐÃ TÍNH XONG PHÂN PHỐI (MANUAL ROUND).")


# =========================
# ENDPOINT POLL - điều khiển từ xa
# =========================
@app.route(POLL_ENDPOINT, methods=["POST"])
def poll():
    global last_new_device_time_for_menu, seen_devices_for_menu, next_job_id

    data = request.get_json(force=True)
    device_id = str(data.get("id", "")).strip()
    if not device_id:
        return jsonify({"error": "missing id"}), 400

    result = data.get("result")

    with lock:
        now = time.time()
        devices.setdefault(device_id, {})
        devices[device_id]["last_seen"] = now

        # xử lý kết quả job (nếu có)
        if result and isinstance(result, dict):
            job_id = result.get("job_id")
            status = result.get("status")
            if job_id in jobs_waiting:
                if device_id in jobs_waiting[job_id]:
                    jobs_waiting[job_id].remove(device_id)
                    print(f"[JOB {job_id}] {device_id} DONE ({status})")
                if not jobs_waiting[job_id]:
                    print(f"[JOB {job_id}] COMPLETED trên tất cả device.")
                    jobs_waiting.pop(job_id, None)

        # ghi nhận device mới xuất hiện (cho logic menu nếu cần)
        if device_id not in seen_devices_for_menu:
            seen_devices_for_menu.add(device_id)
            last_new_device_time_for_menu = now

        # trả job kế tiếp nếu có
        job_list = pending_jobs.get(device_id, [])
        if job_list:
            job = job_list.pop(0)
            return jsonify(job)

    return jsonify({"action": "none"})


# =========================
# ENDPOINT SYNC - chia cookie (MANUAL-ONLY)
# =========================
@app.route(SYNC_ENDPOINT, methods=["POST"])
def sync():
    global ready, round_closed

    data = request.get_json(force=True)
    device_id = str(data.get("device_id", "")).strip()
    cookie_count = int(data.get("cookie_count", 0))

    if not device_id:
        return jsonify({"error": "device_id missing"}), 400

    with lock:
        # luôn lưu lại số cookie mới nhất, để khi bấm #5 có dữ liệu mà tính
        devices.setdefault(device_id, {})
        devices[device_id]["last_cookie_count"] = cookie_count

        # nếu chưa bấm chia -> chỉ báo waiting, không chia gì
        if not ready:
            return jsonify({"status": "waiting", "add_cookies": []})

        # đã chia rồi:
        # - nếu round đóng hoặc device không nằm trong round -> closed
        if round_closed or device_id not in round_base_devices:
            return jsonify({"status": "closed", "add_cookies": []})

        # device trong round, round đang mở:
        if device_id in delivered:
            send = []
        else:
            send = assignments.get(device_id, [])
            delivered.add(device_id)
            if delivered >= round_base_devices:
                round_closed = True
                print("[COOKIE] ROUND CLOSED (manual).")

    return jsonify({"status": "ready", "add_cookies": send})


# =========================
# PHỤC VỤ FILE BACKUP APPS
# =========================
@app.route("/backup_apps/<package>/<filename>", methods=["GET"])
def serve_backup(package, filename):
    folder = BACKUP_APPS_DIR / package
    if not folder.exists():
        return "Not found", 404
    return send_from_directory(folder, filename, as_attachment=True)


# =========================
# HÀM HỖ TRỢ REMOTE CONTROL
# =========================
def read_lines_strip(path: Path) -> List[str]:
    if not path.exists():
        return []
    return [x.strip() for x in path.read_text(encoding="utf-8").splitlines() if x.strip()]


def get_all_devices_sorted() -> List[str]:
    with lock:
        ids = list(devices.keys())
    return sorted(ids, key=lambda x: (len(x), x))


def dispatch_job_to_devices(device_ids: List[str], payload: dict, wait: bool = True):
    global next_job_id

    with lock:
        job_id = next_job_id
        next_job_id += 1

        job = {"job_id": job_id}
        job.update(payload)

        for d in device_ids:
            pending_jobs.setdefault(d, []).append(job)

        jobs_waiting[job_id] = set(device_ids)

        print(f"[JOB {job_id}] Gửi tới: {device_ids}")
        print(f"[JOB {job_id}] Action = {payload.get('action')}")

    if not wait:
        return job_id

    # chờ tất cả device báo DONE
    while True:
        with lock:
            if job_id not in jobs_waiting:
                break
        time.sleep(3)

    print(f"[JOB {job_id}] DONE.")
    return job_id


def choose_devices() -> List[str]:
    print("\n1) All devices")
    print("2) Select devices")
    while True:
        ch = input("Chọn (1/2): ").strip()
        if ch == "1":
            ids = get_all_devices_sorted()
            print("Chọn:", ids)
            return ids
        elif ch == "2":
            ids = get_all_devices_sorted()
            print("Tất cả devices hiện tại:", ids)
            s = input("Nhập ID cách nhau dấu phẩy: ").strip()
            selected = [x.strip() for x in s.split(",") if x.strip()]
            return selected
        else:
            print("Nhập lại.")


# =========================
# MENU ĐIỀU KHIỂN (9 CHỨC NĂNG)
# =========================
def menu_loop():
    global ready, round_closed, device_counts, round_devices, round_base_devices, assignments, delivered

    while True:
        ids = get_all_devices_sorted()
        print("\n============================")
        print("Devices hiện tại:", ids)
        print("1) Kill shouko")
        print("2) Send command (command.txt)")
        print("3) Uninstall apps (uninstall.txt)")
        print("4) Restore apps (backup_apps/)")
        print("5) Chia COOKIE (manual, chọn device)")
        print("6) Delete cookie.txt trên phones")
        print("7) Update Autoexec scripts")
        print("8) Reboot devices")
        print("9) Update rqck.py (client) trên phones")
        print("q) Thoát menu")
        ch = input("Chọn: ").strip().lower()

        if ch == "q":
            break

        if ch not in {"1","2","3","4","5","6","7","8","9"}:
            continue

        # các chức năng cần chọn device
        if ch in {"1","2","3","4","5","6","7","8","9"}:
            tdev = choose_devices()
            if not tdev:
                print("Không có device nào được chọn.")
                continue

        # 1) Kill shouko
        if ch == "1":
            dispatch_job_to_devices(tdev, {"action": "kill_shouko"})

        # 2) Send command
        elif ch == "2":
            if not COMMAND_FILE.exists():
                print("command.txt không tồn tại!")
                continue
            cmd = COMMAND_FILE.read_text(encoding="utf-8")
            dispatch_job_to_devices(tdev, {"action": "run_command", "command": cmd})

        # 3) Uninstall apps
        elif ch == "3":
            pkgs = read_lines_strip(UNINSTALL_FILE)
            if not pkgs:
                print("uninstall.txt rỗng hoặc không tồn tại.")
                continue
            dispatch_job_to_devices(tdev, {"action": "uninstall_apps", "packages": pkgs})

        # 4) Restore apps
        elif ch == "4":
            if not BACKUP_APPS_DIR.exists():
                print("backup_apps/ không tồn tại.")
                continue
            pkgs = sorted([p.name for p in BACKUP_APPS_DIR.iterdir() if p.is_dir()])
            if not pkgs:
                print("Không có package nào trong backup_apps/.")
                continue
            confirm = input(f"Sẽ restore: {pkgs}. Tiếp tục? (y/n): ").strip().lower()
            if confirm != "y":
                continue
            # uninstall trước
            dispatch_job_to_devices(tdev, {"action": "uninstall_apps", "packages": pkgs})
            # restore
            dispatch_job_to_devices(tdev, {"action": "restore_apps", "packages": pkgs})

        # 5) CHIA COOKIE MANUAL
        elif ch == "5":
            with lock:
                print("\n[COOKIE] Tạo round mới với devices:", tdev)

                # reset toàn bộ state round cũ
                device_counts.clear()
                round_devices.clear()
                round_base_devices.clear()
                assignments.clear()
                delivered.clear()
                ready = False
                round_closed = False

                # lấy số cookie mới nhất từ devices[] (cập nhật qua /sync)
                for d in tdev:
                    last_cc = devices.get(d, {}).get("last_cookie_count", 0)
                    device_counts[d] = last_cc
                    round_devices.add(d)

                round_base_devices.update(tdev)

                print("[COOKIE] Tính phân phối...")
                compute_target_and_assignments()

            print("[COOKIE] READY. Phones sẽ nhận phần chia ở lần /sync tiếp theo.")

        # 6) Delete cookie file
        elif ch == "6":
            dispatch_job_to_devices(tdev, {"action": "delete_cookies"})

        # 7) Update Autoexec scripts
        elif ch == "7":
            if not AUTOEXEC_DIR.exists():
                print("[ERROR] Folder Autoexec/ không tồn tại.")
                continue
            files = []
            for f in AUTOEXEC_DIR.iterdir():
                if f.is_file() and f.suffix.lower() == ".txt":
                    files.append({
                        "name": f.name,
                        "content": f.read_text(encoding="utf-8")
                    })
            if not files:
                print("[ERROR] Không có file .txt nào trong Autoexec/.")
                continue

            # yummy.txt vẫn được gửi raw; phía phone sẽ sửa Note=... theo device_id
            dispatch_job_to_devices(
                tdev,
                {"action": "update_script", "files": files}
            )

        # 8) Reboot devices
        elif ch == "8":
            dispatch_job_to_devices(tdev, {"action": "reboot_device"})

        # 9) Update rqck.py trên phones
        elif ch == "9":
            update_path = UPDATE_CLIENT_DIR / "rqck.py"
            if not update_path.exists():
                print(f"[ERROR] Không tìm thấy {update_path}")
                continue
            content = update_path.read_text(encoding="utf-8")
            dispatch_job_to_devices(
                tdev,
                {"action": "update_phone_client", "content": content}
            )


# =========================
# THREAD SERVER + MAIN
# =========================
def server_thread():
    app.run(host=HOST, port=PORT, debug=False, threaded=True)


def main():
    t = threading.Thread(target=server_thread, daemon=True)
    t.start()

    print(f"[SERVER] Running at http://{HOST}:{PORT}")
    print("[SERVER] Đang chờ device poll...")

    # nếu muốn, có thể bỏ phần chờ này và gọi menu_loop() luôn
    start = time.time()
    while True:
        time.sleep(3)
        with lock:
            if seen_devices_for_menu and (time.time() - start >= 60):
                break

    print("\n[SERVER] BẮT ĐẦU MENU.")
    menu_loop()


if __name__ == "__main__":
    main()
