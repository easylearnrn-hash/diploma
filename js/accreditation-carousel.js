/**
 * Accreditation Certificate Carousel
 * Makes elements containing Ministry/accreditation sentences clickable.
 * No visual change - just cursor:pointer. Clicking opens a full-size
 * two-image lightbox: RN certificate first, LVN second.
 */
(function () {
  'use strict';

  const IMAGES = [
    { src: 'assets/License/Accreditation-RN.jpg',  caption: 'State Accreditation Certificate No. 213 — Nursing (RN)' },
    { src: 'assets/License/Accreditation-LVN.jpg', caption: 'State Accreditation Certificate No. 212 — Nursing (LVN)' },
  ];

  // All HTML pages are at the project root, so the path is always relative from there.
  // On file:// just use the path as-is; on localhost it's also correct.
  function imgPath(rel) { return rel; }

  // ── CSS ──────────────────────────────────────────────────────────────
  const style = document.createElement('style');
  style.textContent = `
    .accred-clickable { cursor: pointer; }

    #accred-overlay {
      display: none;
      position: fixed;
      inset: 0;
      z-index: 99999;
      background: rgba(0,0,0,0.92);
      align-items: center;
      justify-content: center;
      padding: 24px;
    }
    #accred-overlay.open { display: flex; }

    #accred-modal {
      position: relative;
      width: min(860px, 95vw);
      background: #0f1b2d;
      border: 1px solid rgba(201,168,76,0.4);
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 32px 80px rgba(0,0,0,0.8);
      display: flex;
      flex-direction: column;
    }

    #accred-img-wrap {
      position: relative;
      background: #fff;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 200px;
    }

    #accred-img {
      display: block;
      width: 100%;
      max-height: 80vh;
      object-fit: contain;
    }

    #accred-caption {
      padding: 16px 24px 8px;
      font-size: 14px;
      font-weight: 600;
      color: #c9a84c;
      text-align: center;
      letter-spacing: .4px;
      font-family: 'Inter', sans-serif;
    }

    #accred-dots {
      display: flex;
      justify-content: center;
      gap: 10px;
      padding: 0 24px 20px;
    }
    .accred-dot {
      width: 9px; height: 9px;
      border-radius: 50%;
      background: rgba(201,168,76,0.25);
      cursor: pointer;
      transition: background 0.2s;
    }
    .accred-dot.active { background: #c9a84c; }

    #accred-close {
      position: absolute;
      top: 12px; right: 14px;
      background: rgba(0,0,0,0.55);
      border: none;
      color: #fff;
      font-size: 18px;
      width: 34px; height: 34px;
      border-radius: 50%;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      z-index: 10;
      transition: background 0.2s;
    }
    #accred-close:hover { background: rgba(201,168,76,0.8); }

    .accred-nav {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      background: rgba(0,0,0,0.45);
      border: none;
      color: #fff;
      font-size: 22px;
      width: 46px; height: 46px;
      border-radius: 50%;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      z-index: 10;
      transition: background 0.2s;
    }
    .accred-nav:hover { background: rgba(201,168,76,0.75); }
    #accred-prev { left: 14px; }
    #accred-next { right: 14px; }
  `;
  document.head.appendChild(style);

  // ── Modal DOM ─────────────────────────────────────────────────────────
  const overlay = document.createElement('div');
  overlay.id = 'accred-overlay';
  overlay.innerHTML = `
    <div id="accred-modal">
      <button id="accred-close" aria-label="Close">✕</button>
      <div id="accred-img-wrap">
        <button class="accred-nav" id="accred-prev" aria-label="Previous">&#8592;</button>
        <img id="accred-img" src="" alt="Accreditation Certificate" />
        <button class="accred-nav" id="accred-next" aria-label="Next">&#8594;</button>
      </div>
      <div id="accred-caption"></div>
      <div id="accred-dots"></div>
    </div>`;
  document.body.appendChild(overlay);

  const imgEl   = document.getElementById('accred-img');
  const caption = document.getElementById('accred-caption');
  const dotsEl  = document.getElementById('accred-dots');
  let current = 0;

  IMAGES.forEach((_, i) => {
    const d = document.createElement('span');
    d.className = 'accred-dot' + (i === 0 ? ' active' : '');
    d.addEventListener('click', () => showSlide(i));
    dotsEl.appendChild(d);
  });

  function showSlide(idx) {
    current = (idx + IMAGES.length) % IMAGES.length;
    imgEl.src = imgPath(IMAGES[current].src);
    caption.textContent = IMAGES[current].caption;
    dotsEl.querySelectorAll('.accred-dot').forEach((d, i) =>
      d.classList.toggle('active', i === current));
  }

  function open() {
    showSlide(0);
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function close() {
    overlay.classList.remove('open');
    document.body.style.overflow = '';
  }

  document.getElementById('accred-close').addEventListener('click', close);
  document.getElementById('accred-prev').addEventListener('click', e => { e.stopPropagation(); showSlide(current - 1); });
  document.getElementById('accred-next').addEventListener('click', e => { e.stopPropagation(); showSlide(current + 1); });
  overlay.addEventListener('click', e => { if (e.target === overlay) close(); });
  document.addEventListener('keydown', e => {
    if (!overlay.classList.contains('open')) return;
    if (e.key === 'Escape')      close();
    if (e.key === 'ArrowLeft')   showSlide(current - 1);
    if (e.key === 'ArrowRight')  showSlide(current + 1);
  });

  // ── Element-level targeting ───────────────────────────────────────────
  // Matches sentences about official Ministry accreditation of ACNHS
  const MINISTRY_PATTERN = /ministry\s+of\s+education|ministry\s+recognition|aligned\s+with\s+ministry|accredit\w+\s+by\s+the\s+ministry|accredit\w+.*republic\s+of\s+armenia|state\s+accredit/i;

  function attachTriggers(root) {
    // 1. Any .accreditation-cell that contains "ministry" text → whole cell clickable
    root.querySelectorAll('.accreditation-cell').forEach(cell => {
      if (/ministry/i.test(cell.textContent)) {
        cell.classList.add('accred-clickable');
        cell.addEventListener('click', e => { e.stopPropagation(); open(); });
      }
    });

    // 2. paragraphs / headings / list items / tds containing Ministry accreditation sentences
    const candidates = root.querySelectorAll('p, h2, h3, h4, li, td, .dc-stat-row');
    candidates.forEach(el => {
      // skip if already inside an .accreditation-cell we've already handled
      if (el.closest('.accred-clickable')) return;
      if (MINISTRY_PATTERN.test(el.textContent)) {
        el.classList.add('accred-clickable');
        el.addEventListener('click', e => { e.stopPropagation(); open(); });
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => attachTriggers(document));
  } else {
    attachTriggers(document);
  }
})();


  const IMAGES = [
    { src: 'assets/License/Accreditation-RN.jpg',  caption: 'State Accreditation Certificate No. 213 — Nursing (RN)' },
    { src: 'assets/License/Accreditation-LVN.jpg', caption: 'State Accreditation Certificate No. 212 — Nursing (LVN)' },
  ];

  // ── Resolve correct asset path relative to current page ──────────────
  function resolvePath(rel) {
    // Walk up until we're at the project root (where assets/ lives)
    const depth = (window.location.pathname.match(/\//g) || []).length - 1;
    const prefix = depth > 0 ? '../'.repeat(depth) : '';
    return prefix + rel;
  }

  // ── Inject CSS ────────────────────────────────────────────────────────
  const style = document.createElement('style');
  style.textContent = `
    .accred-trigger {
      cursor: pointer;
      border-bottom: 1px dotted currentColor;
      transition: color 0.2s, border-color 0.2s;
    }
    .accred-trigger:hover { color: #c9a84c; border-color: #c9a84c; }

    #accred-overlay {
      display: none;
      position: fixed;
      inset: 0;
      z-index: 99999;
      background: rgba(0, 0, 0, 0.88);
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    #accred-overlay.open { display: flex; }

    #accred-modal {
      position: relative;
      max-width: 680px;
      width: 100%;
      background: #0f1b2d;
      border: 1px solid rgba(201, 168, 76, 0.35);
      border-radius: 14px;
      overflow: hidden;
      box-shadow: 0 24px 64px rgba(0,0,0,0.7);
    }

    #accred-modal img {
      display: block;
      width: 100%;
      max-height: 75vh;
      object-fit: contain;
      background: #fff;
    }

    #accred-caption {
      padding: 14px 20px;
      font-size: 13px;
      font-weight: 600;
      color: #c9a84c;
      text-align: center;
      letter-spacing: .4px;
      font-family: 'Inter', sans-serif;
    }

    #accred-dots {
      display: flex;
      justify-content: center;
      gap: 8px;
      padding: 0 20px 16px;
    }
    .accred-dot {
      width: 8px; height: 8px;
      border-radius: 50%;
      background: rgba(201,168,76,0.3);
      cursor: pointer;
      transition: background 0.2s;
    }
    .accred-dot.active { background: #c9a84c; }

    #accred-close {
      position: absolute;
      top: 10px; right: 14px;
      background: rgba(0,0,0,0.55);
      border: none;
      color: #fff;
      font-size: 20px;
      line-height: 1;
      width: 32px; height: 32px;
      border-radius: 50%;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      z-index: 2;
      transition: background 0.2s;
    }
    #accred-close:hover { background: rgba(201,168,76,0.7); }

    .accred-nav {
      position: absolute;
      top: 50%;
      transform: translateY(-60%);
      background: rgba(0,0,0,0.5);
      border: none;
      color: #fff;
      font-size: 22px;
      width: 40px; height: 40px;
      border-radius: 50%;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      z-index: 2;
      transition: background 0.2s;
    }
    .accred-nav:hover { background: rgba(201,168,76,0.7); }
    #accred-prev { left: 10px; }
    #accred-next { right: 10px; }
  `;
  document.head.appendChild(style);

  // ── Build modal DOM ───────────────────────────────────────────────────
  const overlay = document.createElement('div');
  overlay.id = 'accred-overlay';
  overlay.innerHTML = `
    <div id="accred-modal">
      <button id="accred-close" aria-label="Close">✕</button>
      <button class="accred-nav" id="accred-prev" aria-label="Previous">&#8592;</button>
      <button class="accred-nav" id="accred-next" aria-label="Next">&#8594;</button>
      <img id="accred-img" src="" alt="Accreditation Certificate" />
      <div id="accred-caption"></div>
      <div id="accred-dots"></div>
    </div>`;
  document.body.appendChild(overlay);

  const img     = document.getElementById('accred-img');
  const caption = document.getElementById('accred-caption');
  const dotsEl  = document.getElementById('accred-dots');
  let current = 0;

  // Build dots
  IMAGES.forEach((_, i) => {
    const d = document.createElement('span');
    d.className = 'accred-dot' + (i === 0 ? ' active' : '');
    d.addEventListener('click', () => showSlide(i));
    dotsEl.appendChild(d);
  });

  function showSlide(idx) {
    current = (idx + IMAGES.length) % IMAGES.length;
    img.src = resolvePath(IMAGES[current].src);
    caption.textContent = IMAGES[current].caption;
    dotsEl.querySelectorAll('.accred-dot').forEach((d, i) =>
      d.classList.toggle('active', i === current));
  }

  function open() {
    showSlide(0);
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function close() {
    overlay.classList.remove('open');
    document.body.style.overflow = '';
  }

  document.getElementById('accred-close').addEventListener('click', close);
  document.getElementById('accred-prev').addEventListener('click', () => showSlide(current - 1));
  document.getElementById('accred-next').addEventListener('click', () => showSlide(current + 1));
  overlay.addEventListener('click', e => { if (e.target === overlay) close(); });
  document.addEventListener('keydown', e => { 
    if (!overlay.classList.contains('open')) return;
    if (e.key === 'Escape') close();
    if (e.key === 'ArrowLeft')  showSlide(current - 1);
    if (e.key === 'ArrowRight') showSlide(current + 1);
  });

  // ── Wrap text nodes ───────────────────────────────────────────────────
  const PATTERN = /accredit\w*/gi;
  const SKIP_TAGS = new Set(['SCRIPT','STYLE','NOSCRIPT','TEXTAREA','INPUT','A','BUTTON','SELECT','OPTION']);

  function wrapTextNodes(root) {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode(node) {
        if (SKIP_TAGS.has(node.parentElement?.tagName)) return NodeFilter.FILTER_REJECT;
        if (!PATTERN.test(node.textContent)) { PATTERN.lastIndex = 0; return NodeFilter.FILTER_REJECT; }
        PATTERN.lastIndex = 0;
        return NodeFilter.FILTER_ACCEPT;
      }
    });

    const nodes = [];
    while (walker.nextNode()) nodes.push(walker.currentNode);

    nodes.forEach(node => {
      const frag = document.createDocumentFragment();
      let last = 0;
      let m;
      PATTERN.lastIndex = 0;
      while ((m = PATTERN.exec(node.textContent)) !== null) {
        if (m.index > last) frag.appendChild(document.createTextNode(node.textContent.slice(last, m.index)));
        const span = document.createElement('span');
        span.className = 'accred-trigger';
        span.textContent = m[0];
        span.title = 'View accreditation certificates';
        span.addEventListener('click', e => { e.stopPropagation(); open(); });
        frag.appendChild(span);
        last = PATTERN.lastIndex;
      }
      if (last < node.textContent.length) frag.appendChild(document.createTextNode(node.textContent.slice(last)));
      node.replaceWith(frag);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => wrapTextNodes(document.body));
  } else {
    wrapTextNodes(document.body);
  }
})();
