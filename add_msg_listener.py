import os

EKG_DIR = "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/Cardiovascular System/EKG HTML"

listener = (
    "\n// ── Viewport pause/play from parent page ────────────────────────\n"
    "window.addEventListener('message', e => {\n"
    "  if (e.data === 'ekgPause' && !paused) {\n"
    "    paused = true;\n"
    "    pauseBtn.textContent = '\u25b6';\n"
    "    pauseBtn.setAttribute('aria-label', 'Play strip');\n"
    "    pauseStart = performance.now();\n"
    "    if (rafId) cancelAnimationFrame(rafId);\n"
    "  } else if (e.data === 'ekgPlay' && paused) {\n"
    "    paused = false;\n"
    "    pauseBtn.textContent = '\u23f8';\n"
    "    pauseBtn.setAttribute('aria-label', 'Pause strip');\n"
    "    if (pauseStart) t0 += performance.now() - pauseStart;\n"
    "    rafId = requestAnimationFrame(frame);\n"
    "  }\n"
    "});\n"
)

patched = 0
for fn in sorted(os.listdir(EKG_DIR)):
    if not fn.endswith(".html"):
        continue
    path = os.path.join(EKG_DIR, fn)
    with open(path) as f:
        html = f.read()
    if "ekgPause" in html:
        print("SKIP:", fn)
        continue
    idx = html.rfind("</script>")
    if idx == -1:
        print("WARN no </script>:", fn)
        continue
    html = html[:idx] + listener + html[idx:]
    with open(path, "w") as f:
        f.write(html)
    print("PATCHED:", fn)
    patched += 1

print(f"\nDone. {patched} files patched.")
