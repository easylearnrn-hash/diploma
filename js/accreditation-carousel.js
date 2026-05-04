/**
 * ACNHS Accreditation & License Carousel
 * Premium lightbox — navy/gold design system, Playfair Display + Inter
 * Clickable triggers: all accredit* words + Ministry/accreditation sentences
 */
(function () {
  'use strict';

  var SLIDES = [
    {
      src:     'assets/images/IMG_1167.jpg',
      label:   'Operating License',
      caption: 'Official Operating License — Series А No. 0153',
      sub:     'Ministry of Education, Science, Culture and Sport of the Republic of Armenia'
    },
    {
      src:     'assets/License/Accreditation-RN.jpg',
      label:   'RN Accreditation',
      caption: 'State Accreditation Certificate No. 213',
      sub:     'Professional Nursing Program — B.S.N. · Republic of Armenia · April 16, 2007'
    },
    {
      src:     'assets/License/Accreditation-LVN.jpg',
      label:   'LVN Accreditation',
      caption: 'State Accreditation Certificate No. 212',
      sub:     'Practical Nursing Program · Republic of Armenia · April 16, 2007'
    }
  ];

  /* ── Google Fonts (Playfair Display) ─────────────────────────────── */
  if (!document.querySelector('link[href*="Playfair+Display"]')) {
    var gf = document.createElement('link');
    gf.rel = 'stylesheet';
    gf.href = 'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&display=swap';
    document.head.appendChild(gf);
  }

  /* ── CSS ─────────────────────────────────────────────────────────── */
  var style = document.createElement('style');
  style.textContent = [
    '.accred-clickable{cursor:pointer}',

    /* overlay */
    '#accred-overlay{',
    '  display:none;position:fixed;inset:0;z-index:99999;',
    '  background:rgba(4,12,24,0.96);',
    '  align-items:center;justify-content:center;padding:20px;box-sizing:border-box;',
    '  backdrop-filter:blur(6px);-webkit-backdrop-filter:blur(6px);',
    '}',
    '#accred-overlay.open{display:flex}',

    /* modal shell */
    '#accred-modal{',
    '  position:relative;',
    '  width:min(620px,96vw);',
    '  background:linear-gradient(160deg,#0a1628 0%,#0d1f3c 100%);',
    '  border:1px solid rgba(201,168,76,0.45);',
    '  border-radius:20px;',
    '  overflow:hidden;',
    '  box-shadow:0 0 0 1px rgba(201,168,76,0.12),0 40px 100px rgba(0,0,0,0.85);',
    '  display:flex;flex-direction:column;',
    '}',

    /* header bar */
    '#accred-header{',
    '  display:flex;align-items:center;justify-content:space-between;',
    '  padding:18px 24px 16px;',
    '  border-bottom:1px solid rgba(201,168,76,0.2);',
    '  background:rgba(201,168,76,0.04);',
    '}',
    '#accred-institution{',
    '  display:flex;align-items:center;gap:12px;',
    '}',
    '#accred-crest{',
    '  width:36px;height:36px;',
    '  background:rgba(201,168,76,0.12);',
    '  border:1px solid rgba(201,168,76,0.35);',
    '  border-radius:8px;',
    '  display:flex;align-items:center;justify-content:center;',
    '}',
    '#accred-inst-name{',
    '  font-family:"Playfair Display",Georgia,serif;',
    '  font-size:13px;font-weight:700;',
    '  color:rgba(201,168,76,0.9);',
    '  letter-spacing:.3px;',
    '}',
    '#accred-inst-sub{',
    '  font-size:10px;',
    '  color:rgba(255,255,255,0.35);',
    '  margin-top:1px;',
    '  font-family:"Inter",sans-serif;',
    '  letter-spacing:.5px;text-transform:uppercase;',
    '}',
    '#accred-close{',
    '  background:rgba(255,255,255,0.06);',
    '  border:1px solid rgba(255,255,255,0.12);',
    '  color:rgba(255,255,255,0.7);',
    '  font-size:16px;',
    '  width:32px;height:32px;',
    '  border-radius:50%;',
    '  cursor:pointer;',
    '  display:flex;align-items:center;justify-content:center;',
    '  transition:all .2s;flex-shrink:0;',
    '}',
    '#accred-close:hover{background:rgba(201,168,76,0.25);border-color:rgba(201,168,76,0.5);color:#fff}',

    /* tab bar */
    '#accred-tabs{',
    '  display:flex;gap:0;flex-shrink:0;',
    '  border-bottom:1px solid rgba(201,168,76,0.15);',
    '  padding:0 24px;',
    '  background:rgba(0,0,0,0.15);',
    '  position:relative;z-index:5;pointer-events:auto;',
    '}',
    '.accred-tab{',
    '  padding:11px 18px;',
    '  font-family:"Inter",sans-serif;',
    '  font-size:11px;font-weight:700;',
    '  letter-spacing:.7px;text-transform:uppercase;',
    '  color:rgba(255,255,255,0.35);',
    '  cursor:pointer;',
    '  border-bottom:2px solid transparent;',
    '  transition:all .2s;',
    '  white-space:nowrap;',
    '}',
    '.accred-tab:hover{color:rgba(201,168,76,0.7)}',
    '.accred-tab.active{color:#c9a84c;border-bottom-color:#c9a84c}',

    /* image area */
    '#accred-img-wrap{',
    '  position:relative;',
    '  background:#1a1a1a;',
    '  display:flex;align-items:center;justify-content:center;',
    '  overflow:hidden;',
    '}',
    '#accred-img{',
    '  display:block;',
    '  width:100%;',
    '  max-height:70vh;',
    '  object-fit:scale-down;',
    '  transition:opacity .25s ease;',
    '  pointer-events:none;',
    '  -webkit-user-drag:none;',
    '  user-select:none;',
    '  -webkit-touch-callout:none;',
    '}',
    '#accred-img.fading{opacity:0}',

    /* nav arrows */
    '.accred-nav{',
    '  position:absolute;top:50%;transform:translateY(-50%);',
    '  background:rgba(4,12,24,0.65);',
    '  border:1px solid rgba(201,168,76,0.3);',
    '  color:#c9a84c;font-size:18px;',
    '  width:44px;height:44px;border-radius:50%;',
    '  cursor:pointer;',
    '  display:flex;align-items:center;justify-content:center;',
    '  z-index:10;transition:all .2s;',
    '  backdrop-filter:blur(4px);-webkit-backdrop-filter:blur(4px);',
    '}',
    '.accred-nav:hover{background:rgba(201,168,76,0.2);border-color:rgba(201,168,76,0.7)}',
    '#accred-prev{left:14px}',
    '#accred-next{right:14px}',

    /* caption footer */
    '#accred-footer{',
    '  padding:18px 24px 22px;',
    '  background:rgba(0,0,0,0.2);',
    '  border-top:1px solid rgba(201,168,76,0.15);',
    '}',
    '#accred-caption-title{',
    '  font-family:"Playfair Display",Georgia,serif;',
    '  font-size:16px;font-weight:700;',
    '  color:#c9a84c;',
    '  margin-bottom:4px;',
    '}',
    '#accred-caption-sub{',
    '  font-family:"Inter",sans-serif;',
    '  font-size:11px;',
    '  color:rgba(255,255,255,0.4);',
    '  letter-spacing:.3px;',
    '}',
    '#accred-footer-row{',
    '  display:flex;align-items:center;justify-content:space-between;',
    '  margin-top:12px;',
    '}',
    '#accred-dots{display:flex;gap:8px;align-items:center}',
    '.accred-dot{',
    '  width:6px;height:6px;border-radius:50%;',
    '  background:rgba(201,168,76,0.2);',
    '  cursor:pointer;transition:all .2s;',
    '}',
    '.accred-dot.active{background:#c9a84c;width:20px;border-radius:3px}',
    '#accred-counter{',
    '  font-family:"Inter",sans-serif;',
    '  font-size:11px;',
    '  color:rgba(255,255,255,0.25);',
    '  letter-spacing:.5px;',
    '}'
  ].join('');
  document.head.appendChild(style);

  /* ── Modal HTML ──────────────────────────────────────────────────── */
  var overlay = document.createElement('div');
  overlay.id = 'accred-overlay';
  overlay.innerHTML =
    '<div id="accred-modal">' +

      '<div id="accred-header">' +
        '<div id="accred-institution">' +
          '<div id="accred-crest">' +
            '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>' +
          '</div>' +
          '<div>' +
            '<div id="accred-inst-name">Armenian College of Nursing &amp; Health Sciences</div>' +
            '<div id="accred-inst-sub">Official Credentials &amp; Accreditation Documents</div>' +
          '</div>' +
        '</div>' +
        '<button id="accred-close" aria-label="Close">&#x2715;</button>' +
      '</div>' +

      '<div id="accred-tabs"></div>' +

      '<div id="accred-img-wrap">' +
        '<button class="accred-nav" id="accred-prev" aria-label="Previous">&#8592;</button>' +
        '<img id="accred-img" src="" alt="Official Certificate" />' +
        '<button class="accred-nav" id="accred-next" aria-label="Next">&#8594;</button>' +
      '</div>' +

      '<div id="accred-footer">' +
        '<div id="accred-caption-title"></div>' +
        '<div id="accred-caption-sub"></div>' +
        '<div id="accred-footer-row">' +
          '<div id="accred-dots"></div>' +
          '<div id="accred-counter"></div>' +
        '</div>' +
      '</div>' +

    '</div>';
  document.body.appendChild(overlay);

  var imgEl      = document.getElementById('accred-img');
  var titleEl    = document.getElementById('accred-caption-title');
  var subEl      = document.getElementById('accred-caption-sub');
  var dotsWrap   = document.getElementById('accred-dots');
  var counterEl  = document.getElementById('accred-counter');
  var tabsWrap   = document.getElementById('accred-tabs');
  var current    = 0;

  /* build tabs + dots */
  SLIDES.forEach(function(s, i) {
    var tab = document.createElement('span');
    tab.className = 'accred-tab' + (i === 0 ? ' active' : '');
    tab.textContent = s.label;
    tab.addEventListener('click', function(e) { e.stopPropagation(); showSlide(i); });
    tabsWrap.appendChild(tab);

    var dot = document.createElement('span');
    dot.className = 'accred-dot' + (i === 0 ? ' active' : '');
    dot.addEventListener('click', function() { showSlide(i); });
    dotsWrap.appendChild(dot);
  });

  function showSlide(idx) {
    current = (idx + SLIDES.length) % SLIDES.length;
    var s = SLIDES[current];

    imgEl.classList.add('fading');
    setTimeout(function() {
      function show() { imgEl.classList.remove('fading'); }
      imgEl.onload = show;
      imgEl.src = s.src;
      if (imgEl.complete) show();
    }, 150);

    titleEl.textContent   = s.caption;
    subEl.textContent     = s.sub;
    counterEl.textContent = (current + 1) + ' of ' + SLIDES.length;

    tabsWrap.querySelectorAll('.accred-tab').forEach(function(t, i) {
      t.classList.toggle('active', i === current);
    });
    dotsWrap.querySelectorAll('.accred-dot').forEach(function(d, i) {
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

  document.getElementById('accred-img-wrap').addEventListener('contextmenu', function(e) { e.preventDefault(); });
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

  /* ── Attach click triggers ──────────────────────────────────────── */
  var SENTENCE_PATTERN = /ministry\s+of\s+education|ministry\s+recognition|aligned\s+with\s+ministry|accredited\s+by\s+the\s+ministry|accredit\w+.*republic\s+of\s+armenia|state\s+accredit/i;
  var WORD_PATTERN     = /\baccredit\w*/gi;
  var SKIP_TAGS        = {SCRIPT:1,STYLE:1,NOSCRIPT:1,TEXTAREA:1,INPUT:1,A:1,BUTTON:1,SELECT:1,OPTION:1};

  function attachTriggers() {
    /* 1. Whole .accreditation-cell if it mentions Ministry */
    document.querySelectorAll('.accreditation-cell').forEach(function(cell) {
      if (/ministry/i.test(cell.textContent)) {
        cell.classList.add('accred-clickable');
        cell.addEventListener('click', function(e) { e.stopPropagation(); openCarousel(); });
      }
    });

    /* 2. Paragraphs / headings containing Ministry/accreditation sentences */
    document.querySelectorAll('p, h2, h3, h4, li, td').forEach(function(el) {
      if (el.closest('.accred-clickable')) return;
      if (SENTENCE_PATTERN.test(el.textContent)) {
        el.classList.add('accred-clickable');
        el.addEventListener('click', function(e) { e.stopPropagation(); openCarousel(); });
      }
    });

    /* 3. Wrap individual accredit* words in text nodes */
    var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
    var nodes  = [];
    var n;
    while ((n = walker.nextNode())) {
      if (SKIP_TAGS[n.parentElement && n.parentElement.tagName]) continue;
      if (n.parentElement && n.parentElement.closest('.accred-clickable')) continue;
      if (n.parentElement && n.parentElement.closest('#accred-overlay')) continue;
      WORD_PATTERN.lastIndex = 0;
      if (WORD_PATTERN.test(n.textContent)) nodes.push(n);
    }

    nodes.forEach(function(node) {
      var frag = document.createDocumentFragment();
      var text = node.textContent;
      var last = 0, m;
      WORD_PATTERN.lastIndex = 0;
      while ((m = WORD_PATTERN.exec(text)) !== null) {
        if (m.index > last) frag.appendChild(document.createTextNode(text.slice(last, m.index)));
        var span = document.createElement('span');
        span.className = 'accred-clickable';
        span.textContent = m[0];
        span.addEventListener('click', function(e) { e.stopPropagation(); openCarousel(); });
        frag.appendChild(span);
        last = WORD_PATTERN.lastIndex;
      }
      if (last < text.length) frag.appendChild(document.createTextNode(text.slice(last)));
      if (node.parentNode) node.parentNode.replaceChild(frag, node);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', attachTriggers);
  } else {
    attachTriggers();
  }
})();
