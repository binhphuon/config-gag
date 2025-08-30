(async () => {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));

  async function tap(el) {
    if (!el) return;
    const rect = el.getBoundingClientRect();
    const x = rect.left + rect.width / 2;
    const y = rect.top + rect.height / 2;
    const opts = { bubbles: true, cancelable: true, clientX: x, clientY: y, view: window };

    try { el.dispatchEvent(new PointerEvent('pointerdown', opts)); } catch {}
    try { el.dispatchEvent(new MouseEvent('mousedown', opts)); } catch {}
    try { el.dispatchEvent(new PointerEvent('pointerup', opts)); } catch {}
    try { el.dispatchEvent(new MouseEvent('mouseup', opts)); } catch {}
    try { el.dispatchEvent(new MouseEvent('click', opts)); } catch {}

    const topEl = document.elementFromPoint(x, y);
    if (topEl && topEl !== el) {
      try { topEl.dispatchEvent(new MouseEvent('click', opts)); } catch {}
    }
    await sleep(50);
  }

  async function waitForAppear(sel, timeout = 3000) {
    const t0 = Date.now();
    while (Date.now() - t0 < timeout) {
      const el = document.querySelector(sel);
      if (el) return el;
      await sleep(50);
    }
    return null;
  }

  async function waitForDisappear(sel, timeout = 3000) {
    const t0 = Date.now();
    while (Date.now() - t0 < timeout) {
      if (!document.querySelector(sel)) return true;
      await sleep(50);
    }
    return false;
  }

  async function closePopup() {
    const overlay = await waitForAppear('div.van-overlay[role="button"]', 1500);
    if (overlay) {
      await tap(overlay);
      if (await waitForDisappear('div.van-overlay[role="button"]', 1500)) return true;
    }
    document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', keyCode: 27, which: 27, bubbles: true}));
    document.dispatchEvent(new KeyboardEvent('keyup',   {key: 'Escape', keyCode: 27, which: 27, bubbles: true}));
    return await waitForDisappear('div.van-overlay[role="button"]', 1000);
  }

  // parse "Thời gian chia sẻ còn lại: 3d 17h 21min" -> phút
  function parseTimeToMinutes(text) {
    if (!text) return 0;
    const d = /(\d+)\s*d/i.exec(text)?.[1] ?? 0;
    const h = /(\d+)\s*h/i.exec(text)?.[1] ?? 0;
    const m = /(\d+)\s*min/i.exec(text)?.[1] ?? 0;
    return (+d)*24*60 + (+h)*60 + (+m);
  }
  // format về "XdYh" (nếu không có d/h thì hiển thị "Xmin")
  function formatDH(text) {
    const d = parseInt(/(\d+)\s*d/i.exec(text)?.[1] ?? "0", 10);
    const h = parseInt(/(\d+)\s*h/i.exec(text)?.[1] ?? "0", 10);
    const m = parseInt(/(\d+)\s*min/i.exec(text)?.[1] ?? "0", 10);
    if (d || h) return `${d ? d + "d" : ""}${h ? h + "h" : ""}` || "0h";
    return `${m}min`;
  }

  const results = [];
  const devices = document.querySelectorAll("div.device-item-box");

  for (let i = 0; i < devices.length; i++) {
    const device = devices[i];
    const deviceName = (device.querySelector(".name-bar")?.innerText || `Device ${i+1}`).trim();
    const gearBtn = device.querySelector(".setting-bar");
    if (!gearBtn) continue;

    // mở popup
    await tap(gearBtn);
    await waitForAppear('div.van-overlay[role="button"]', 2000);
    await waitForAppear('.van-action-sheet', 2000);

    const popup = document.querySelector(".van-action-sheet");

    // lấy "Thời gian chia sẻ còn lại"
    let timeLeftEl = null;
    const descs = Array.from(popup.querySelectorAll(".operate-item .desc"));
    timeLeftEl = descs.find(d => /chia\s*se|chia\s*sẻ/i.test(d.innerText)) || descs[0];
    const timeLeftText = (timeLeftEl?.innerText || "Không tìm thấy").trim();
    const timeShort = formatDH(timeLeftText);
    const minutesLeft = parseTimeToMinutes(timeLeftText);

    // lấy SỐ HIỆU THIẾT BỊ: tìm .van-cell__label có chuỗi bắt đầu bằng VM...
    let serial = "UNKNOWN";
    const labelCands = Array.from(popup.querySelectorAll(".van-cell__label, .van-cell__value, .van-cell__title"));
    const cand = labelCands.find(el => /^VM[0-9]+/i.test(el.innerText.trim()));
    if (cand) serial = cand.innerText.trim();

    const line = `${serial} - ${deviceName} - ${timeShort}`;

    // in từng dòng ngay lập tức
    console.log(line);

    results.push({ line, minutesLeft });

    // đóng popup trước khi qua thiết bị tiếp theo
    await closePopup();
    await sleep(200);
  }

  // tổng kết: sort tăng dần (sắp hết trước)
  results.sort((a, b) => a.minutesLeft - b.minutesLeft);

  console.log("📋 TỔNG KẾT (đã sort tăng dần theo thời gian còn lại):");
  console.log(results.map(r => r.line).join("\n"));
})();
