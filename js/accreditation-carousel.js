/**
 * Accreditation Certificate Carousel
 * Makes Ministry/accreditation elements clickable — no visual change.
 */
(function () {
  'use strict';

  const IMAGES = [
    { src: 'assets/License/Accreditation-RN.jpg',  caption: 'State Accreditation Certificate No. 213 — Nursing (RN)' },
    { src: 'assets/License/Accreditation-LVN.jpg', caption: 'State Accreditation Certificate No. 212 — Nursing (LVN)' },
  ];

  // ── CSS ───────────────────────────────────────────────────────────────
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
      box-sizing: border-box;
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
      top: 50%; transform: translateY(-50%);
      background: rgba(0,0,0,0.45);
      border: none; color: #fff;
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
      <button id="accred-close" aria-label="Close">&#x2715;</button>
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
  let current   = 0;

  IMAGES.forEach(function(_, i) {
    var d = document.createElement('span');
    d.className = 'accred-dot' + (i === 0 ? ' active' : '');
    d.addEventListener('click', function() { showSlide(i); });
    dotsEl.appendChild(d);
  });

  function showSlide(idx) {
    current = (idx + IMAGES.length) % IMAGES.length;
    imgEl.src = IMAGES[current].src;
    caption.textContent = IMAGES[current].caption;
    dotsEl.querySelectorAll('.accred-dot').forEach(function(d, i) {
      d.classList.toggle('active', i === current);
    });
  }

  function openCarousel() {
    showSlide(0);
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function closeCarousel() {
    overlay.classList.remove('open');
    document.body.style.overflow = '';
  }

  document.getElementById('accred-close').addEventListener('click', closeCarousel);
  document.getElementById('accred-prev').addEventListener('click', function(e) {
    e.stopPropagation(); showSlide(current - 1);
  });
  document.getElementById('accred-next').addEventListener('click', function(e) {
    e.stopPropagation(); showSlide(current + 1);
  });
  overlay.addEventListener('click', function(e) { if (e.target === overlay) closeCarousel(); });
  document.addEventListener('keydown', function(e) {
    if (!overlay.classList.contains('open')) return;
    if (e.key === 'Escape')     closeCarousel();
    if (e.key === 'ArrowLeft')  showSlide(current - 1);
    if (e.key === 'ArrowRight') showSlide(current + 1);
  });

  // ── Attach click triggers ─────────────────────────────────────────────
  var PATTERN = /ministry\s+of\s+education|ministry\s+recognition|aligned\s+with\s+ministry|accredited\s+by\s+the\s+ministry|accredit\w+.*republic\s+of\s+armenia|state\s+accredit/i;

  function attachTriggers() {
    // 1. Whole .accreditation-cell if it mentions Ministry
    document.querySelectorAll('.accreditation-cell').forEach(function(cell) {
      if (/ministry/i.test(cell.textContent)) {
        cell.classList.add('accred-clickable');
        cell.addEventListener('click', function(e) { e.stopPropagation(); openCarousel(); });
      }
    });

    // 2. p / h2 / h3 / h4 / li / td containing Ministry/accreditation sentences
    document.querySelectorAll('p, h2, h3, h4, li, td, span').forEach(function(el) {
      if (el.closest('.accred-clickable')) return; // already handled by parent
      if (PATTERN.test(el.textContent)) {
        el.classList.add('accred-clickable');
        el.addEventListener('click', function(e) { e.stopPropagation(); openCarousel(); });
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', attachTriggers);
  } else {
    attachTriggers();
  }
})();
