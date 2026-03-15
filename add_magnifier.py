"""
Adds a 5× magnifier lens to every EKG strip HTML file.
- Only active when the strip is paused
- Follows mouse/touch position
- Circular lens, 140px diameter, drawn on an overlay canvas
- Uses the already-baked wfTile OffscreenCanvas for the zoomed source
"""

import os
import re

EKG_DIR = "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/Cardiovascular System/EKG HTML"

# ── CSS to inject inside <style> (before </style>) ───────────────────────────
MAG_CSS = """
    /* Magnifier overlay canvas */
    #mag {
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
      pointer-events: none;
      z-index: 4;
    }
"""

# ── HTML: overlay canvas (after <canvas id="c"></canvas>) ────────────────────
MAG_CANVAS = '\n<canvas id="mag"></canvas>'

# ── JS to inject just before the closing </script> tag ───────────────────────
# Requires: canvas, ctx, wfTile, TILE_W, CH, CW, DPR (all already defined)
# Requires: paused, scrollPx — scrollPx must be promoted to module-level var
MAG_JS = """
// ── 7. Magnifier (active only when paused) ──────────────────────
const magCanvas = document.getElementById('mag');
const magCtx    = magCanvas.getContext('2d');

const MAG_R      = 70;   // lens radius px (CSS pixels)
const MAG_SCALE  = 5;    // zoom factor

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

  const scale = DPR;
  const cx = magX * scale;   // centre in canvas pixels
  const cy = magY * scale;
  const r  = MAG_R * scale;

  // ── clip to circle ──
  magCtx.save();
  magCtx.beginPath();
  magCtx.arc(cx, cy, r, 0, Math.PI * 2);
  magCtx.clip();

  // ── dark green background (matches grid bg) ──
  magCtx.fillStyle = '#000b00';
  magCtx.fillRect(cx - r, cy - r, r * 2, r * 2);

  // ── draw zoomed grid inside lens ──
  const sm = 3.78 * MAG_SCALE * scale;
  const lg = sm * 5;
  const ox = cx - magX * MAG_SCALE * scale;   // origin offset
  const oy = cy - magY * MAG_SCALE * scale;

  magCtx.strokeStyle = 'rgba(0, 160, 0, 0.18)';
  magCtx.lineWidth = 1;
  for (let x = ((cx - r - ox) / sm | 0) * sm + ox; x < cx + r; x += sm) {
    magCtx.beginPath(); magCtx.moveTo(x, cy - r); magCtx.lineTo(x, cy + r); magCtx.stroke();
  }
  for (let y = ((cy - r - oy) / sm | 0) * sm + oy; y < cy + r; y += sm) {
    magCtx.beginPath(); magCtx.moveTo(cx - r, y); magCtx.lineTo(cx + r, y); magCtx.stroke();
  }
  magCtx.strokeStyle = 'rgba(0, 255, 120, 0.30)';
  for (let x = ((cx - r - ox) / lg | 0) * lg + ox; x < cx + r; x += lg) {
    magCtx.beginPath(); magCtx.moveTo(x, cy - r); magCtx.lineTo(x, cy + r); magCtx.stroke();
  }
  for (let y = ((cy - r - oy) / lg | 0) * lg + oy; y < cy + r; y += lg) {
    magCtx.beginPath(); magCtx.moveTo(cx - r, y); magCtx.lineTo(cx + r, y); magCtx.stroke();
  }

  // ── draw zoomed waveform tile ──
  // Source region: a strip of width 2*R/MAG_SCALE centred on magX in the frozen strip
  const srcW  = (r * 2) / MAG_SCALE;
  const srcH  = CH * scale;                   // full height of the tile
  // Where in the TILE does magX fall?
  const frozenSrcX = (frozenScrollPx + magX * scale) % (TILE_W * scale);
  let tilePixelX = frozenSrcX / scale;         // tile coords (un-DPR)

  // Source centre in tile space
  const halfSrcW = srcW / (2 * scale);         // half-source-width in tile px
  let srcLeft = tilePixelX - halfSrcW;
  const dstLeft = cx - r;
  const dstTop  = cy - r;
  const dstW    = r * 2;
  const dstH    = r * 2;

  // How many pixels of the magnified canvas does CH cover?
  const zoomedCH = CH * MAG_SCALE * scale;
  // Vertical offset so the strip centre in the tile maps to the lens centre
  const srcCenterY = CH * 0.58;               // BASE in tile coords
  const dstCenterY = cy;
  const scaledSrcCY = srcCenterY * MAG_SCALE * scale;
  const tileDrawY   = dstCenterY - scaledSrcCY;

  // Draw, wrapping tile if needed
  if (srcLeft < 0) srcLeft += TILE_W;
  const rightEdge = srcLeft + srcW / scale;

  if (rightEdge <= TILE_W) {
    magCtx.drawImage(
      wfTile,
      srcLeft, 0, srcW / scale, CH,
      dstLeft, tileDrawY, dstW, zoomedCH
    );
  } else {
    // wrap: draw two segments
    const part1W = TILE_W - srcLeft;
    const part1Dst = part1W * MAG_SCALE * scale;
    magCtx.drawImage(
      wfTile,
      srcLeft, 0, part1W, CH,
      dstLeft, tileDrawY, part1Dst, zoomedCH
    );
    const part2W = (srcW / scale) - part1W;
    magCtx.drawImage(
      wfTile,
      0, 0, part2W, CH,
      dstLeft + part1Dst, tileDrawY, part2W * MAG_SCALE * scale, zoomedCH
    );
  }

  magCtx.restore();

  // ── lens border ──
  magCtx.beginPath();
  magCtx.arc(cx, cy, r, 0, Math.PI * 2);
  magCtx.strokeStyle = 'rgba(43, 255, 107, 0.55)';
  magCtx.lineWidth = 2 * scale;
  magCtx.stroke();

  // ── crosshair ──
  magCtx.strokeStyle = 'rgba(43, 255, 107, 0.25)';
  magCtx.lineWidth = scale;
  magCtx.beginPath();
  magCtx.moveTo(cx - r + 6 * scale, cy);
  magCtx.lineTo(cx + r - 6 * scale, cy);
  magCtx.stroke();
  magCtx.beginPath();
  magCtx.moveTo(cx, cy - r + 6 * scale);
  magCtx.lineTo(cx, cy + r - 6 * scale);
  magCtx.stroke();
}

// Track mouse/touch — only show when paused
canvas.addEventListener('mousemove', e => {
  if (!paused) { magVisible = false; drawMagnifier(); return; }
  const rect = canvas.getBoundingClientRect();
  magX = e.clientX - rect.left;
  magY = e.clientY - rect.top;
  magVisible = true;
  drawMagnifier();
});
canvas.addEventListener('mouseleave', () => {
  magVisible = false;
  drawMagnifier();
});
canvas.addEventListener('touchmove', e => {
  if (!paused) return;
  e.preventDefault();
  const rect = canvas.getBoundingClientRect();
  magX = e.touches[0].clientX - rect.left;
  magY = e.touches[0].clientY - rect.top;
  magVisible = true;
  drawMagnifier();
}, { passive: false });
canvas.addEventListener('touchend', () => {
  magVisible = false;
  drawMagnifier();
});
// Hide magnifier when unpausing
pauseBtn.addEventListener('click', () => {
  if (!paused) { magVisible = false; drawMagnifier(); }
}, true);  // capture=true so it fires before the main handler toggles paused
"""

# ── Patch that promotes scrollPx to module-level ──────────────────────────────
# We need `frozenScrollPx` to be accessible outside frame().
# Strategy: replace the local `const scrollPx =` with a module-level `let frozenScrollPx`
# that gets updated each frame, plus keep a local alias for the drawImage calls.

SCROLL_DECLARE = "let frozenScrollPx = 0;"   # inserted near the other let declarations

def patch_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        html = f.read()

    # ── Skip if already patched ──
    if 'magnifier' in html.lower() or 'magCanvas' in html:
        print(f"  SKIP (already patched): {os.path.basename(path)}")
        return

    changed = html

    # 1. Add CSS into <style> block (before </style>)
    if MAG_CSS.strip() not in changed:
        changed = changed.replace('  </style>', MAG_CSS + '  </style>', 1)

    # 2. Add overlay canvas after <canvas id="c"></canvas>
    changed = changed.replace('<canvas id="c"></canvas>', '<canvas id="c"></canvas>' + MAG_CANVAS, 1)

    # 3. Promote scrollPx to module-level frozenScrollPx
    #    a) Add `let frozenScrollPx = 0;` after `let rafId = null;`
    changed = changed.replace(
        'let rafId = null;',
        'let rafId = null;\nlet frozenScrollPx = 0;',
        1
    )
    #    b) Inside frame(), replace `const scrollPx = ...` with plain assignment (no keyword)
    #       so it writes to the outer `let frozenScrollPx` instead of shadowing it
    changed = re.sub(
        r'const scrollPx = ',
        'frozenScrollPx = ',
        changed,
        count=1
    )
    #    c) Replace remaining `scrollPx` usages with `frozenScrollPx`
    changed = re.sub(
        r'\bscrollPx\b',
        'frozenScrollPx',
        changed
    )

    # 4. Add magnifier JS before </script>
    changed = changed.replace('</script>', MAG_JS + '\n</script>', 1)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(changed)
    print(f"  PATCHED: {os.path.basename(path)}")


files = [os.path.join(EKG_DIR, f) for f in os.listdir(EKG_DIR) if f.endswith('.html')]
files.sort()
print(f"Processing {len(files)} files...\n")
for fp in files:
    patch_file(fp)
print("\nDone.")
