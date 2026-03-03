/**
 * ACNHS Note Copy Protection
 * Blocks text selection, copy, right-click context menu, and
 * keyboard copy/select-all shortcuts on all student-facing note pages.
 * This file is injected into every note HTML file automatically.
 */
(function () {
  'use strict';

  /* ── 1. CSS: disable text selection everywhere ── */
  const style = document.createElement('style');
  style.textContent = [
    '*, *::before, *::after {',
    '  -webkit-user-select: none !important;',
    '  -moz-user-select:    none !important;',
    '  -ms-user-select:     none !important;',
    '  user-select:         none !important;',
    '}',
    /* Allow selecting inside <input> / <textarea> so forms still work */
    'input, textarea, [contenteditable="true"] {',
    '  -webkit-user-select: text !important;',
    '  -moz-user-select:    text !important;',
    '  user-select:         text !important;',
    '}',
  ].join('\n');
  (document.head || document.documentElement).appendChild(style);

  /* ── 2. Block right-click context menu ── */
  document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  }, true);

  /* ── 3. Block copy / cut events ── */
  document.addEventListener('copy',  function (e) { e.preventDefault(); e.stopPropagation(); }, true);
  document.addEventListener('cut',   function (e) { e.preventDefault(); e.stopPropagation(); }, true);

  /* ── 4. Block selectstart (drag-to-select) ── */
  document.addEventListener('selectstart', function (e) {
    // Allow selection inside inputs/textareas
    const tag = (e.target || {}).tagName;
    if (tag === 'INPUT' || tag === 'TEXTAREA') return;
    e.preventDefault();
    e.stopPropagation();
    return false;
  }, true);

  /* ── 5. Block keyboard shortcuts: Ctrl/Cmd + C / X / A / U / S / P ── */
  document.addEventListener('keydown', function (e) {
    const ctrl = e.ctrlKey || e.metaKey;
    if (!ctrl) return;
    const key = e.key ? e.key.toLowerCase() : '';
    // Block copy(c), cut(x), select-all(a), view-source(u), save(s), print(p)
    if (['c', 'x', 'a', 'u', 's', 'p'].includes(key)) {
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
  }, true);

  /* ── 6. Block drag-start (drag text out) ── */
  document.addEventListener('dragstart', function (e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  }, true);

})();
