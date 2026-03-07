/**
 * ACNHS Content Protection
 * - Disables right-click context menu
 * - Blocks Ctrl/Cmd+C (copy), Ctrl/Cmd+P (print), Ctrl/Cmd+S (save),
 *   Ctrl/Cmd+A (select all), Ctrl/Cmd+U (view source)
 * - Blocks F12, PrintScreen
 * - Disables text selection via CSS
 * - Blocks print via CSS @media print
 * - Shows a warning overlay when a violation is attempted
 */
(function () {
  'use strict';

  /* ── CSS: no selection + hide on print ── */
  const style = document.createElement('style');
  style.textContent = `
    body, body * {
      -webkit-user-select: none !important;
      -moz-user-select: none !important;
      -ms-user-select: none !important;
      user-select: none !important;
    }
    @media print {
      html, body { display: none !important; visibility: hidden !important; }
    }
  `;
  document.head.appendChild(style);

  /* ── Warning overlay ── */
  function showWarning() {
    if (document.getElementById('_acnhs_warn')) return;
    const overlay = document.createElement('div');
    overlay.id = '_acnhs_warn';
    overlay.style.cssText = `
      position:fixed;inset:0;z-index:999999;
      background:rgba(2,13,26,0.96);
      display:flex;flex-direction:column;align-items:center;justify-content:center;
      font-family:'Segoe UI',sans-serif;color:#e2e8f0;text-align:center;padding:2rem;
    `;
    overlay.innerHTML = `
      <div style="font-size:3rem;margin-bottom:1rem;">🔒</div>
      <div style="font-size:1.4rem;font-weight:700;color:#f87171;margin-bottom:.5rem;">
        Content Protected
      </div>
      <div style="font-size:.95rem;color:#94a3b8;max-width:380px;line-height:1.6;">
        Copying, printing, and saving of ACNHS course materials is not permitted.
      </div>
      <button onclick="document.getElementById('_acnhs_warn').remove()"
        style="margin-top:1.5rem;padding:.5rem 1.5rem;background:#2dd4bf;color:#020d1a;
               border:none;border-radius:8px;font-weight:700;cursor:pointer;font-size:.9rem;">
        Dismiss
      </button>
    `;
    document.body.appendChild(overlay);
    setTimeout(() => { if (overlay.parentNode) overlay.remove(); }, 3000);
  }

  /* ── Block right-click ── */
  document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
    showWarning();
  });

  /* ── Block keyboard shortcuts ── */
  document.addEventListener('keydown', function (e) {
    const ctrl = e.ctrlKey || e.metaKey;

    // Ctrl/Cmd + C, P, S, A, U
    if (ctrl && ['c', 'p', 's', 'a', 'u'].includes(e.key.toLowerCase())) {
      e.preventDefault();
      showWarning();
      return;
    }

    // F12
    if (e.key === 'F12') {
      e.preventDefault();
      showWarning();
      return;
    }

    // PrintScreen
    if (e.key === 'PrintScreen') {
      e.preventDefault();
      showWarning();
    }
  });

  /* ── Block window.print() ── */
  window.print = function () { showWarning(); };

  /* ── Block drag-to-copy ── */
  document.addEventListener('dragstart', function (e) { e.preventDefault(); });

})();
