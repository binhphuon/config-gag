#!/data/data/com.termux/files/usr/bin/bash
set -e

# =========================
# EDIT Ở ĐÂY: đổi số này sẽ update cả Note và --id
# =========================
ID="1"

DOWNLOAD_DIR="/storage/emulated/0/Download"
SHOUKO_DIR="/storage/emulated/0/Download/Shouko"
AUTO_DIR="/storage/emulated/0/Delta/Autoexecute"
BOOT_DIR="$HOME/.termux/boot"

# =========================
# 0) Ensure folders exist
# =========================
mkdir -p "$DOWNLOAD_DIR" "$SHOUKO_DIR" "$AUTO_DIR" "$BOOT_DIR"

# =========================
# 1) /Download/config-change.json
# =========================
cat > "$DOWNLOAD_DIR/config-change.json" <<'EOF'
{
    "god_human": true,
    "level": 2800
}
EOF

# =========================
# 2) /Download/Shouko/server_links.txt
# =========================
cat > "$SHOUKO_DIR/server_links.txt" <<'EOF'
aaa.aaa,roblox://placeID=2753915549
aaa.bbb,roblox://placeID=2753915549
aaa.ccc,roblox://placeID=2753915549
EOF

# =========================
# 3) /Download/Shouko/config.json
# =========================
cat > "$SHOUKO_DIR/config.json" <<'EOF'
{"webhook_url": null, "device_name": null, "interval": null, "check_executor": "1", "change_acc": "1", "change_acc_cus": "0", "method 1": -60, "method 2": 5, "method 3": 0, "method 4": 600, "method 5": 80, "prefix": "com.roblox", "block": "1", "sort_tab": "0", "1_kill": "0", "ping": ""}
EOF

# =========================
# 4) Autoexecute: xóa file cũ + tạo 3 file mới
# =========================
find "$AUTO_DIR" -maxdepth 1 -type f -print -delete

cat > "$AUTO_DIR/kaitun.txt" <<'EOF'
loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/ploxfruit.lua"))() 
EOF

cat > "$AUTO_DIR/yummy.txt" <<EOF
_G.Config={UserID="8325dd55-e74a-4adc-a0ff-3541ba204ace",discord_id="861138853624283137",Note="$ID"}local s;for i=1,5 do s=pcall(function()loadstring(game:HttpGet("https://cdn.yummydata.click/scripts/trackstatblox"))()end)if s then break end wait(5)end
EOF

cat > "$AUTO_DIR/changebf.txt" <<'EOF'
loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/change%20pf.lua"))()
EOF

# =========================
# 5) Termux:Boot scripts
# =========================
cat > "$BOOT_DIR/abcd.sh" <<'EOF'
#!/bin/bash
su -c "export PATH=\$PATH:/data/data/com.termux/files/usr/bin && export TERM=xterm-256color && cd /storage/emulated/0/Download && python ./shouko.py >> /storage/emulated/0/Download/log.txt 2>&1" <<EOF2
QuangHuy-Premium-SFA4-FHJ4-CHSQ-I8GO

5
600
EOF2
EOF

cat > "$BOOT_DIR/ug.sh" <<EOF
#!/bin/bash
cd /storage/emulated/0/Download && python rqck.py --id=$ID
EOF

chmod +x "$BOOT_DIR/abcd.sh" "$BOOT_DIR/ug.sh"

echo "✅ Done FULL! (ID=$ID)"
echo "- $DOWNLOAD_DIR/config-change.json"
echo "- $SHOUKO_DIR/server_links.txt"
echo "- $SHOUKO_DIR/config.json"
echo "- $AUTO_DIR/{kaitun.txt,yummy.txt,changebf.txt}"
echo "- $BOOT_DIR/{abcd.sh,ug.sh}"
echo "- Log file: /storage/emulated/0/Download/log.txt"
ls -la "$SHOUKO_DIR"
ls -la "$AUTO_DIR"
ls -la "$BOOT_DIR"
