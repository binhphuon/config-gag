# rqck.py
# Client chạy trên Termux
# pip install requests

import argparse
import threading
import time
import subprocess
from pathlib import Path

import requests

# =========================
# CẤU HÌNH
# =========================
DEFAULT_SERVER_URL = "http://160.25.73.213:5000"
DEFAULT_COOKIE_PATH = "/sdcard/Download/cookie.txt"
COOKIE_SYNC_INTERVAL = 20   # 5 phút
POLL_INTERVAL = 20           # 20 giây

BASE_DOWNLOAD_DIR = Path("/sdcard/Download/app_restore")
BASE_DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Các folder Autoexec trên máy
dest_folders = [
    "/storage/emulated/0/RobloxClone001/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone002/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone003/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone004/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone005/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone006/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone007/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone008/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone009/Codex/Autoexec/",
    "/storage/emulated/0/RobloxClone010/Codex/Autoexec/",
    "/storage/emulated/0/Cryptic/Auto Execute/",
    "/storage/emulated/0/Arceus X/Autoexec/",
    "/storage/emulated/0/RobloxClone001/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone002/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone003/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone004/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone005/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone006/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone007/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone008/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone009/Cryptic/Auto Execute/",
    "/storage/emulated/0/RobloxClone010/Cryptic/Auto Execute/",
]

# =========================
# HELPERS
# =========================
def run_su(cmd: str):
    print(f"[su] {cmd}")
    result = subprocess.run(["su", "-c", cmd],
                            text=True,
                            capture_output=True)
    out = (result.stdout or "").strip()
    err = (result.stderr or "").strip()
    if out:
        print("[su stdout]", out)
    if err:
        print("[su stderr]", err)
    return result


def run_shell(command: str):
    print("[shell] chạy lệnh:\n", command)
    result = subprocess.run(command,
                            shell=True,
                            text=True,
                            capture_output=True)
    out = (result.stdout or "").strip()
    err = (result.stderr or "").strip()
    if out:
        print("[shell stdout]", out)
    if err:
        print("[shell stderr]", err)
    return result


def download_file(url: str, dest: Path):
    print(f"[DOWNLOAD] {url} -> {dest}")
    r = requests.get(url, stream=True, timeout=120)
    r.raise_for_status()
    with dest.open("wb") as f:
        for chunk in r.iter_content(8192):
            if chunk:
                f.write(chunk)
    print("[DOWNLOAD] Done:", dest.name)


def get_app_owner(package: str):
    res = run_su(f'ls -ld "/data/data/{package}"')
    line = (res.stdout or "").splitlines()
    if not line:
        print("[OWNER] Không lấy được owner, dùng root:root")
        return "root", "root"
    parts = line[-1].split()
    owner = parts[2]
    group = parts[3]
    print(f"[OWNER] {package}: {owner}:{group}")
    return owner, group


def restore_one_package(server_url: str, package: str):
    base = server_url.rstrip("/")
    apk_url = f"{base}/backup_apps/{package}/app.apk"
    data_url = f"{base}/backup_apps/{package}/data.tar"
    sddata_url = f"{base}/backup_apps/{package}/sddata.tar"

    apk_path = BASE_DOWNLOAD_DIR / f"{package}.apk"
    data_tar = BASE_DOWNLOAD_DIR / f"{package}_data.tar"
    sddata_tar = BASE_DOWNLOAD_DIR / f"{package}_sddata.tar"

    download_file(apk_url, apk_path)
    download_file(data_url, data_tar)

    has_sddata = False    # sddata optional
    try:
        download_file(sddata_url, sddata_tar)
        has_sddata = True
    except Exception as e:
        print("[RESTORE] Không tải được sddata.tar (không sao):", e)

    run_su(f"am force-stop {package}")

    res = run_su(f'pm install -r "{apk_path}"')
    if "Success" not in (res.stdout or ""):
        print(f"[RESTORE] Install fail cho {package}, bỏ qua.")
        return

    run_su(f'mkdir -p "/data/data/{package}"')
    owner, group = get_app_owner(package)

    run_su(f'rm -rf "/data/data/{package}/"*')

    run_su(f'tar -xpf "{data_tar}" -C "/data/data/{package}"')

    run_su(f'chown -R {owner}:{group} "/data/data/{package}"')

    run_su(f'restorecon -R "/data/data/{package}"')

    if has_sddata:
        run_su(f'mkdir -p "/sdcard/Android/data/{package}"')
        run_su(f'tar -xpf "{sddata_tar}" -C "/sdcard/Android/data/{package}"')

    print(f"[RESTORE] Xong package {package}")


def count_cookies(path: str) -> int:
    p = Path(path)
    folder = p.parent
    if not folder.exists():
        folder.mkdir(parents=True, exist_ok=True)
    if not p.exists():
        p.write_text("", encoding="utf-8")
        return 0
    with p.open("r", encoding="utf-8") as f:
        return sum(1 for line in f if line.strip())


def append_cookies(path: str, cookies):
    p = Path(path)
    folder = p.parent
    folder.mkdir(parents=True, exist_ok=True)
    with p.open("a", encoding="utf-8") as f:
        for c in cookies:
            c = c.rstrip("\n")
            if c:
                f.write(c + "\n")

# =========================
# HANDLE JOB
# =========================
def handle_job(server_url: str, job: dict, cookie_path: str, device_id: str, interval: int):
    action = job.get("action")
    print(f"[JOB] action = {action}")

    if action == "kill_shouko":
        run_su("pkill -f shouko.py")

    elif action == "run_command":
        cmd = job.get("command", "")
        if cmd:
            run_shell(cmd)

    elif action == "uninstall_apps":
        pkgs = job.get("packages") or []
        if pkgs:
            pkg_str = " ".join(pkgs)
            run_su(f'for p in {pkg_str}; do pm uninstall "$p"; done')

    elif action == "restore_apps":
        pkgs = job.get("packages") or []
        for pkg in pkgs:
            restore_one_package(server_url, pkg)

    elif action == "delete_cookies":
        run_shell(f'rm -f "{cookie_path}"')
        print(f"[JOB] Đã xoá {cookie_path}")

    elif action == "update_script":
        files = job.get("files", [])
        for folder in dest_folders:
            try:
                p = Path(folder)
                p.mkdir(parents=True, exist_ok=True)
                # xoá sạch folder
                for f in p.iterdir():
                    try:
                        f.unlink()
                    except:
                        pass
                # ghi file mới
                for file in files:
                    name = file.get("name", "noname.txt")
                    content = file.get("content", "")

                    # Nếu là yummy.txt thì patch Note="" -> Note="<device_id>"
                    if name == "yummy.txt":
                        try:
                            patched = content.replace('Note=""', f'Note="{device_id}"')
                            content_to_write = patched
                            print(f"[UPDATE_SCRIPT] Patched yummy.txt với Note='{device_id}'")
                        except Exception as e:
                            print("[UPDATE_SCRIPT] Lỗi patch yummy.txt:", e)
                            content_to_write = content
                    else:
                        content_to_write = content

                    (p / name).write_text(content_to_write, encoding="utf-8")

                print(f"[UPDATE_SCRIPT] Updated: {folder}")
            except Exception as e:
                print(f"[UPDATE_SCRIPT] Lỗi {folder}: {e}")

    elif action == "reboot_device":
        print("[REBOOT] Rebooting device...")
        run_su("reboot")

    elif action == "update_phone_client":
        new_content = job.get("content", "")
        target_path = "/sdcard/Download/rqck.py"
        try:
            Path(target_path).write_text(new_content, encoding="utf-8")
            print("[UPDATE_CLIENT] Đã ghi rqck.py mới.")

            cmd = (
                f'python "{target_path}" '
                f'--id={device_id} '
                f'--server={server_url} '
                f'--cookie="{cookie_path}" '
                f'--interval={interval}'
            )
            print("[UPDATE_CLIENT] Start new client:", cmd)
            subprocess.Popen(cmd, shell=True)

            print("[UPDATE_CLIENT] Exit old client...")
            raise SystemExit(0)

        except Exception as e:
            print("[UPDATE_CLIENT] Lỗi update:", e)

    else:
        print("[JOB] Unknown action:", action)

# =========================
# THREAD 1: REMOTE LOOP (/poll)
# =========================
def remote_loop(device_id: str, server_url: str, cookie_path: str, interval: int):
    poll_url = server_url.rstrip("/") + "/poll"
    pending_result = None

    while True:
        try:
            payload = {"id": device_id}
            if pending_result is not None:
                payload["result"] = pending_result

            print(f"[REMOTE {device_id}] Poll -> {payload}")
            resp = requests.post(poll_url, json=payload, timeout=60)
            resp.raise_for_status()
            data = resp.json()
            print(f"[REMOTE {device_id}] Response:", data)

            pending_result = None

            action = data.get("action")
            if not action or action == "none":
                time.sleep(POLL_INTERVAL)
                continue

            job_id = data.get("job_id")
            handle_job(server_url, data, cookie_path, device_id, interval)

            if job_id is not None:
                pending_result = {"job_id": job_id, "status": "ok"}

        except Exception as e:
            print(f"[REMOTE {device_id}] Lỗi:", e)
            time.sleep(POLL_INTERVAL)

# =========================
# THREAD 2: COOKIE LOOP (/sync)
# =========================
def cookie_loop(device_id: str, server_url: str, cookie_path: str, interval: int):
    sync_url = server_url.rstrip("/") + "/sync"
    print(f"[COOKIE {device_id}] Bắt đầu loop. file={cookie_path}, interval={interval}s")

    while True:
        try:
            current_count = count_cookies(cookie_path)
            print(f"[COOKIE {device_id}] Hiện có {current_count} cookie.")

            payload = {
                "device_id": device_id,
                "cookie_count": current_count,
            }

            try:
                resp = requests.post(sync_url, json=payload, timeout=30)
                resp.raise_for_status()
            except Exception as e:
                print(f"[COOKIE {device_id}] Không kết nối được server: {e}")
                time.sleep(interval)
                continue

            data = resp.json()
            status = data.get("status", "unknown")
            add_cookies = data.get("add_cookies", [])

            print(f"[COOKIE {device_id}] Server status={status}, nhận {len(add_cookies)} cookie.")

            if add_cookies:
                append_cookies(cookie_path, add_cookies)
                new_count = count_cookies(cookie_path)
                print(f"[COOKIE {device_id}] Sau khi append: {new_count} cookie.")

            time.sleep(interval)

        except Exception as e:
            print(f"[COOKIE {device_id}] Lỗi:", e)
            time.sleep(interval)

# =========================
# MAIN
# =========================
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--id", required=True, help="device_id, ví dụ: 36")
    parser.add_argument("--server", default=DEFAULT_SERVER_URL,
                        help="URL server, vd: http://160.25.73.213:5000")
    parser.add_argument("--cookie", default=DEFAULT_COOKIE_PATH,
                        help="Đường dẫn cookie.txt")
    parser.add_argument("--interval", type=int, default=COOKIE_SYNC_INTERVAL,
                        help="Thời gian nghỉ (giây) giữa mỗi lần /sync")
    args = parser.parse_args()

    device_id = args.id
    server_url = args.server.rstrip("/")
    cookie_path = args.cookie
    interval = args.interval

    print(f"[MAIN {device_id}] Server = {server_url}")
    print(f"[MAIN {device_id}] Cookie file = {cookie_path}")
    print(f"[MAIN {device_id}] Cookie sync interval = {interval}s")
    print(f"[MAIN {device_id}] Poll interval = {POLL_INTERVAL}s\n")

    t1 = threading.Thread(target=remote_loop,
                          args=(device_id, server_url, cookie_path, interval),
                          daemon=True)
    t2 = threading.Thread(target=cookie_loop,
                          args=(device_id, server_url, cookie_path, interval),
                          daemon=True)

    t1.start()
    t2.start()

    try:
        while True:
            time.sleep(60)
    except KeyboardInterrupt:
        print(f"[MAIN {device_id}] Dừng bởi người dùng.")


if __name__ == "__main__":
    main()
