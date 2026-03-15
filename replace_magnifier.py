"""
Replaces the drawMagnifier function in all EKG strip HTML files.
New approach:
- 3x zoom (was 5x)
- Reads pixels directly from the main canvas (ctx) via drawImage — pixel-perfect quality
- Correct vertical centering: follows magY exactly, not hardcoded to BASE
- Clean grid drawn on top of the zoomed image
- DPR handled correctly throughout
"""

import os
import re

EKG_DIR = "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/Cardiovascular System/EKG HTML"

# The new drawMagnifier function + constants (replaces everything from MAG_R to end of old magnifier)
NEW_MAG_BLOCK = r"""// ── 7. Magnifier (active only when paused) ──────────────────────
const magCanvas = document.getElementById('mag');
const magCtx    = magCanvas.getContext('2d');

const MAG_R     = 80;   // lens radius in CSS px
const MAG_SCALE = 3;    // zoom factor

function resizeMag() {
  magCanvas.width  = Math.round(CW * DPR);
  magCanvas.height = Math.round(CH * DPR);
  magCanvas.style.width  = CW + 'px';
  magCanvas.style.height = CH + 'px';
}
resizeMag();
window.addEventListener('resize', resizeMag);

let magX = -1, magY = -1, magVisible = false;

function drawMagnifier() {
  magCtx.clearRect(0, 0, magCanvas.width, magCanvas.height);
  if (!magVisible || !paused || magX < 0) return;

  // All geometry in physical canvas pixels (multiplied by DPR)
  const cx = magX * DPR;
  const cy = magY * DPR;
  const r  = MAG_R * DPR;

  // ── Source rect on the main canvas: the region under the lens at 1:1 ──
  // srcW/srcH is what we'll zoom — a window of the main canvas centred on (cx,cy)
  const srcW = (r * 2) / MAG_SCALE;   // physical px
  const srcH = (r * 2) / MAG_SCALE;
  let srcX = cx - srcW / 2;
  let srcY = cy - srcH / 2;

  // Clamp source rect so we never read outside the canvas
  srcX = Math.max(0, Math.min(canvas.width  - srcW, srcX));
  srcY = Math.max(0, Math.min(canvas.height - srcH, srcY));

  // ── Clip to circle ──
  magCtx.save();
  magCtx.beginPath();
  magCtx.arc(cx, cy, r, 0, Math.PI * 2);
  magCtx.clip();

  // ── Draw zoomed section of the main canvas (pixel-perfect, uses imageSmoothingQuality) ──
  magCtx.imageSmoothingEnabled = true;
  magCtx.imageSmoothingQuality = 'high';
  magCtx.drawImage(
    canvas,
    srcX, srcY, srcW, srcH,   // source rect (physical px on main canvas)
    cx - r, cy - r, r * 2, r * 2  // dest rect (fills the lens)
  );

  // ── Draw zoomed grid lines on top ──
  // Grid spacing at 3x zoom: 3.78mm * MAG_SCALE * DPR physical px
  const sm = 3.78 * MAG_SCALE * DPR;
  const lg = sm * 5;

  // The grid origin in the zoomed view:
  // A point at physical srcX,srcY maps to cx-r,cy-r in the dest.
  // Scale factor = r*2 / srcW = MAG_SCALE
  // So a source grid line at x=n*3.78 (physical) maps to dest = (cx-r) + (n*3.78 - srcX)*MAG_SCALE
  // Equivalently: offset = (cx - r) - srcX * MAG_SCALE
  const gox = (cx - r) - srcX * MAG_SCALE;
  const goy = (cy - r) - srcY * MAG_SCALE;

  magCtx.strokeStyle = 'rgba(0, 160, 0, 0.20)';
  magCtx.lineWidth = DPR;
  const x0 = Math.floor((cx - r - gox) / sm) * sm + gox;
  for (let x = x0; x <= cx + r; x += sm) {
    magCtx.beginPath(); magCtx.moveTo(x, cy - r); magCtx.lineTo(x, cy + r); magCtx.stroke();
  }
  const y0 = Math.floor((cy - r - goy) / sm) * sm + goy;
  for (let y = y0; y <= cy + r; y += sm) {
    magCtx.beginPath(); magCtx.moveTo(cx - r, y); magCtx.lineTo(cx + r, y); magCtx.stroke();
  }
  magCtx.strokeStyle = 'rgba(0, 255, 120, 0.35)';
  const lx0 = Math.floor((cx - r - gox) / lg) * lg + gox;
  for (let x = lx0; x <= cx + r; x += lg) {
    magCtx.beginPath(); magCtx.moveTo(x, cy - r); magCtx.lineTo(x, cy + r); magCtx.stroke();
  }
  const ly0 = Math.floor((cy - r - goy) / lg) * lg + goy;
  for (let y = ly0; y <= cy + r; y += lg) {
    magCtx.beginPath(); magCtx.moveTo(cx - r, y); magCtx.lineTo(cx + r, y); magCtx.stroke();
  }

  magCtx.restore();

  // ── Lens border ──
  magCtx.beginPath();
  magCtx.arc(cx, cy, r, 0, Math.PI * 2);
  magCtx.strokeStyle = 'rgba(43, 255, 107, 0.65)';
  magCtx.lineWidth = 2 * DPR;
  magCtx.stroke();

  // ── Crosshair ──
  const gap = 8 * DPR;
  magCtx.strokeStyle = 'rgba(43, 255, 107, 0.30)';
  magCtx.lineWidth = DPR;
  magCtx.beginPath();
  magCtx.moveTo(cx - r + gap, cy); magCtx.lineTo(cx + r - gap, cy); magCtx.stroke();
  magCtx.beginPath();
  magCtx.moveTo(cx, cy - r + gap); magCtx.lineTo(cx, cy + r - gap); magCtx.stroke();
}

// ── Input handlers ───────────────────────────────────────────────
function updateMagPos(clientX, clientY) {
  const rect = canvas.getBoundingClientRect();
  magX = clientX - rect.left;
  magY = clientY - rect.top;
}

canvas.addEventListener('mousemove', e => {
  if (!paused) { magVisible = false; magCtx.clearRect(0, 0, magCanvas.width, magCanvas.height); return; }
  updateMagPos(e.clientX, e.clientY);
  magVisible = true;
  drawMagnifier();
});
canvas.addEventListener('mouseleave', () => {
  magVisible = false;
  magCtx.clearRect(0, 0, magCanvas.width, magCanvas.height);
});
canvas.addEventListener('touchmove', e => {
  if (!paused) return;
  e.preventDefault();
  updateMagPos(e.touches[0].clientX, e.touches[0].clientY);
  magVisible = true;
  drawMagnifier();
}, { passive: false });
canvas.addEventListener('touchend', () => {
  magVisible = false;
  magCtx.clearRect(0, 0, magCanvas.width, magCanvas.height);
});

// Hide magnifier when unpausing (capture phase so it fires before paused toggles)
pauseBtn.addEventListener('click', () => {
  if (!paused) {
    magVisible = false;
    magCtx.clearRect(0, 0, magCanvas.width, magCanvas.height);
  }
}, true);
"""

# Regex: match everything from the magnifier comment through the final pauseBtn capture listener
MAG_PATTERN = re.compile(
    r'// ── 7\. Magnifier.*?// capture=true.*?\n',
    re.DOTALL
)

def patch_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        html = f.read()

    if '// ── 7. Magnifier' not in html:
        print(f"  SKIP (no magnifier block): {os.path.basename(path)}")
        return

    new_html, count = MAG_PATTERN.subn(NEW_MAG_BLOCK, html)
    if count == 0:
        print(f"  WARN (pattern not matched): {os.path.basename(path)}")
        return

    with open(path, 'w', encoding='utf-8') as f:
        f.write(new_html)
    print(f"  PATCHED: {os.path.basename(path)}")


files = sorted(f for f in os.listdir(EKG_DIR) if f.endswith('.html'))
print(f"Processing {len(files)} files...\n")
for fn in files:
    patch_file(os.path.join(EKG_DIR, fn))
print("\nDone.")
