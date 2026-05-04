/* Shared header/footer injection for ACNHS static site (no build tools). */
/* UPDATED: Direct string injection to avoiding file:// protocol CORS issues */

const ACNHS_HEADER_HTML = `
<header class="site-header">
  <div class="nav">
    <a href="index.html" class="acn-logo" aria-label="Armenian College of Nursing &amp; Health Sciences">
      <img class="acn-logo-seal" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==" alt="ACNHS Seal" data-acnhs-logo>
      <div class="acn-logo-text">
        <span class="line-1">Armenian College of Nursing</span>
        <span class="line-2">&amp; Health Sciences</span>
      </div>
    </a>

    <nav class="main-nav" aria-label="Primary">
      <div class="help-dropdown" id="academicsDropdown">
        <button class="help-btn" type="button" data-action="toggle-academics">
          Academics
          <span class="help-arrow" aria-hidden="true"></span>
        </button>
        <div class="help-dropdown-content" role="menu">
          <a href="academic-catalog.html" role="menuitem" data-action="open-catalog-picker">Academic Catalog</a>
          <a href="index.html#programs" role="menuitem">Programs</a>
          <a href="#" role="menuitem" data-action="open-curriculum">Curriculum</a>
          <a href="index.html#simulation" role="menuitem">Simulation</a>
        </div>
      </div>

      <a href="index.html#global-network" style="color:var(--gold-400);font-weight:600;">Global Network</a>

      <div class="help-dropdown" id="aboutDropdown">
        <button class="help-btn" type="button" data-action="toggle-about">
          About
          <span class="help-arrow" aria-hidden="true"></span>
        </button>
        <div class="help-dropdown-content" role="menu">
          <a href="about.html" role="menuitem">About the College</a>
          <a href="staff.html" role="menuitem">Faculty &amp; Staff</a>
          <a href="contact.html" role="menuitem">Contact Us</a>
        </div>
      </div>

      <div class="help-dropdown" id="helpDropdown">
        <button class="help-btn" type="button" data-action="toggle-help">
          Help
          <span class="help-arrow" aria-hidden="true"></span>
        </button>
        <div class="help-dropdown-content" role="menu">
          <a href="help-handbook.html" role="menuitem">Student Handbook</a>
          <a href="help-grading.html" role="menuitem">Grading</a>
          <a href="help-appeals.html" role="menuitem" data-login-required="true">Appeals &amp; Remediation</a>
          <a href="help-clinical.html" role="menuitem">Clinical</a>
          <a href="help-support.html" role="menuitem">Support</a>
        </div>
      </div>
    </nav>

    <div class="nav-actions">
      <button class="btn btn-ghost" type="button" data-action="student-login">Login</button>
    </div>

    <!-- Mobile hamburger -->
    <button class="mobile-menu-btn" type="button" aria-label="Open menu" data-action="toggle-mobile-menu">
      <span></span><span></span><span></span>
    </button>
  </div>
</header>

<!-- Mobile drawer -->
<div class="mobile-drawer" id="mobileDrawer" aria-hidden="true">
  <div class="mobile-drawer-header">
    <span class="mobile-drawer-title">Menu</span>
    <button class="mobile-drawer-close" type="button" aria-label="Close menu" data-action="close-mobile-menu">✕</button>
  </div>
  <nav class="mobile-nav">
    <div class="mobile-nav-section">
      <div class="mobile-nav-label">Academics</div>
      <a href="academic-catalog.html" data-action="open-catalog-picker">Academic Catalog</a>
      <a href="index.html#programs">Programs</a>
      <a href="index.html#simulation">Simulation</a>
    </div>
    <div class="mobile-nav-section">
      <a href="index.html#global-network" class="mobile-nav-highlight">Global Network</a>
    </div>
    <div class="mobile-nav-section">
      <div class="mobile-nav-label">About</div>
      <a href="about.html">About the College</a>
      <a href="staff.html">Faculty &amp; Staff</a>
      <a href="contact.html">Contact Us</a>
    </div>
    <div class="mobile-nav-section">
      <div class="mobile-nav-label">Help</div>
      <a href="help-handbook.html">Student Handbook</a>
      <a href="help-grading.html">Grading</a>
      <a href="help-clinical.html">Clinical</a>
      <a href="help-support.html">Support</a>
    </div>
    <div class="mobile-nav-section">
      <button class="btn btn-primary mobile-login-btn" type="button" data-action="student-login">Login to Portal</button>
    </div>
  </nav>
</div>
<div class="mobile-drawer-overlay" id="mobileDrawerOverlay" data-action="close-mobile-menu"></div>
`;

const ACNHS_FOOTER_HTML = `
<footer class="site-footer">
  <div class="footer-inner">
    <div class="footer-brand">
      <div class="footer-name">Armenian College of Nursing &amp; Health Sciences</div>
      <div class="footer-sub">Yerevan, Armenia · Ministry-Aligned · NCLEX-RN Curriculum · International Transcript Ready</div>
    </div>
    <div class="footer-contact">
      <div class="footer-contact-heading">Contact</div>
      <a class="footer-contact-item" href="tel:+17077174440">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.64 3.4 2 2 0 0 1 3.61 1.24h3a2 2 0 0 1 2 1.72c.127.96.362 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.82a16 16 0 0 0 6.29 6.29l.96-.96a2 2 0 0 1 2.11-.45c.907.338 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
        +1 (707) 717-4440
      </a>
      <div class="footer-contact-divider"></div>
      <a class="footer-contact-item" href="https://wa.me/37493798879" target="_blank" rel="noopener">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>
        +374 93 798 879
        <span class="footer-contact-badge">WhatsApp</span>
      </a>
    </div>
    <div class="footer-links">
      <div class="footer-link-group">
        <h4>Academic</h4>
        <a href="help-handbook.html">Student Handbook</a>
        <a href="help-grading.html">Grading Policy</a>
        <a href="help-appeals.html">Appeals &amp; Remediation</a>
      </div>
      <div class="footer-link-group">
        <h4>Institution</h4>
        <a href="about.html">About the College</a>
        <a href="contact.html">Contact Us</a>
        <a href="academic-catalog.html">Academic Catalog</a>
      </div>
    </div>
  </div>

  <div class="footer-bottom">
    <p>© 2025–2026 Armenian College of Nursing &amp; Health Sciences. All rights reserved.</p>
    <div class="footer-bottom-links">
      <a href="privacy-policy.html">Privacy Policy</a>
    </div>
  </div>
</footer>
`;

function once(fn) {
  let ran = false;
  return (...args) => {
    if (ran) return;
    ran = true;
    return fn(...args);
  };
}

// Helper to handle closing dropdowns when clicking outside
function setupDropdownClose_Chrome(dropdown, triggerBtn) {
  const closeHandler = (ev) => {
      if (!dropdown.contains(ev.target) && !triggerBtn.contains(ev.target)) {
          dropdown.classList.remove('active');
          document.removeEventListener('click', closeHandler);
      }
  };
  // Add minimal delay to avoid immediate closure
  if (dropdown.classList.contains('active')) {
       setTimeout(() => document.addEventListener('click', closeHandler), 0);
  }
}

function wireHeaderInteractions(root) {
  if (!root) return;

  ensureCatalogPickerOverlay();

  // Curriculum modal is only on index.html; fall back to the catalog page elsewhere.
  root.querySelectorAll('[data-action="open-curriculum"]').forEach(a => {
    a.addEventListener('click', (e) => {
      e.preventDefault();
      if (typeof window.openCurriculumModal === 'function') {
        window.openCurriculumModal();
      } else {
        window.location.href = 'academic-catalog.html';
      }
    });
  });

  // Academic catalog picker (header + footer)
  root.querySelectorAll('[data-action="open-catalog-picker"]').forEach(a => {
    a.addEventListener('click', (e) => {
      if (typeof window.openCatalogPicker === 'function') {
        e.preventDefault();
        window.openCatalogPicker();
      }
    });
  });

  // Help dropdown behavior: if a page already defines toggleHelpDropdown(), use it.
  root.querySelectorAll('[data-action="toggle-help"]').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      
      const dropdown = root.querySelector('#helpDropdown');
      // If another dropdown is open (like academics), close it
      root.querySelectorAll('.help-dropdown').forEach(d => {
        if (d !== dropdown) d.classList.remove('active');
      });

      if (typeof window.toggleHelpDropdown === 'function') {
        window.toggleHelpDropdown();
        return;
      }
      
      if (dropdown) {
        dropdown.classList.toggle('active');
        setupDropdownClose_Chrome(dropdown, btn);
      }
    });
  });

  // Academics dropdown behavior
  root.querySelectorAll('[data-action="toggle-academics"]').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const dropdown = root.querySelector('#academicsDropdown');
      
      // If another dropdown is open (like help), close it
      root.querySelectorAll('.help-dropdown').forEach(d => {
        if (d !== dropdown) d.classList.remove('active');
      });

      if (dropdown) {
        dropdown.classList.toggle('active');
        setupDropdownClose_Chrome(dropdown, btn);
      }
    });
  });

  // About dropdown behavior
  root.querySelectorAll('[data-action="toggle-about"]').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const dropdown = root.querySelector('#aboutDropdown');

      root.querySelectorAll('.help-dropdown').forEach(d => {
        if (d !== dropdown) d.classList.remove('active');
      });

      if (dropdown) {
        dropdown.classList.toggle('active');
        setupDropdownClose_Chrome(dropdown, btn);
      }
    });
  });

  // Coming soon links
  root.querySelectorAll('[data-action="coming-soon"]').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const label = link.getAttribute('data-label') || 'This page';
      if (typeof window.showComingSoon === 'function') {
        window.showComingSoon(e, label);
      } else {
        alert(`${label} is coming soon.`);
      }
    });
  });

  // Apply Now — qualifier prompt
  root.querySelectorAll('[data-action="apply-now"]').forEach(btn => {
    btn.addEventListener('click', () => {
      openQualifierPrompt();
    });
  });

  // Student login
  root.querySelectorAll('[data-action="student-login"]').forEach(btn => {
    btn.addEventListener('click', () => {
      window.location.href = 'login.html';
    });
  });

  // Mobile drawer open/close
  function openMobileDrawer() {
    const drawer = document.getElementById('mobileDrawer');
    const overlay = document.getElementById('mobileDrawerOverlay');
    if (drawer) { drawer.classList.add('open'); drawer.setAttribute('aria-hidden', 'false'); }
    if (overlay) overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function closeMobileDrawer() {
    const drawer = document.getElementById('mobileDrawer');
    const overlay = document.getElementById('mobileDrawerOverlay');
    if (drawer) { drawer.classList.remove('open'); drawer.setAttribute('aria-hidden', 'true'); }
    if (overlay) overlay.classList.remove('open');
    document.body.style.overflow = '';
  }
  document.querySelectorAll('[data-action="toggle-mobile-menu"]').forEach(btn => {
    btn.addEventListener('click', openMobileDrawer);
  });
  document.querySelectorAll('[data-action="close-mobile-menu"]').forEach(el => {
    el.addEventListener('click', closeMobileDrawer);
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      closeMobileDrawer();
      closeQualifierPrompt();
    }
  });

  // Optional: hide login-required links when not logged in.
  const isLoggedIn = sessionStorage.getItem('isLoggedIn') === 'true' || localStorage.getItem('isLoggedIn') === 'true';
  if (!isLoggedIn) {
    root.querySelectorAll('[data-login-required="true"]').forEach(el => {
      el.style.display = 'none';
    });
  }
}

// ── Qualifier Prompt Modal ───────────────────────────────────
function ensureQualifierPromptOverlay() {
  if (document.getElementById('qualifierPromptOverlay')) return;

  const css = `
    #qualifierPromptOverlay {
      position: fixed; inset: 0; z-index: 9999;
      display: flex; align-items: center; justify-content: center;
      background: rgba(4, 17, 31, 0.82);
      backdrop-filter: blur(6px);
      -webkit-backdrop-filter: blur(6px);
      opacity: 0; pointer-events: none;
      transition: opacity 0.25s;
      padding: 20px;
    }
    #qualifierPromptOverlay.qp-open {
      opacity: 1; pointer-events: all;
    }
    .qp-modal {
      background: linear-gradient(160deg, #071b30 0%, #0c2444 100%);
      border: 1px solid rgba(201,168,76,0.32);
      border-top: 2px solid #c9a84c;
      border-radius: 20px;
      padding: 44px 44px 36px;
      max-width: 480px;
      width: 100%;
      text-align: center;
      box-shadow: 0 24px 60px rgba(0,0,0,0.55), 0 0 0 1px rgba(201,168,76,0.06);
      transform: translateY(14px) scale(0.98);
      transition: transform 0.3s cubic-bezier(0.4,0,0.2,1);
      position: relative;
    }
    #qualifierPromptOverlay.qp-open .qp-modal {
      transform: translateY(0) scale(1);
    }
    .qp-icon {
      width: 58px; height: 58px;
      border-radius: 50%;
      background: rgba(201,168,76,0.1);
      border: 1.5px solid rgba(201,168,76,0.4);
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 22px;
    }
    .qp-title {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: 22px;
      font-weight: 700;
      color: #f0ece3;
      line-height: 1.3;
      margin-bottom: 12px;
    }
    .qp-subtitle {
      font-family: 'Inter', sans-serif;
      font-size: 14px;
      color: #b8b0a0;
      line-height: 1.7;
      margin-bottom: 32px;
    }
    .qp-actions {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }
    .qp-btn-yes {
      padding: 15px 20px;
      background: linear-gradient(135deg, #c9a84c, #e2cc92);
      color: #04111f;
      font-family: 'Inter', sans-serif;
      font-size: 14px;
      font-weight: 700;
      border: none;
      border-radius: 12px;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center; gap: 8px;
      transition: opacity 0.2s, box-shadow 0.2s, transform 0.15s;
      box-shadow: 0 4px 18px rgba(201,168,76,0.28);
    }
    .qp-btn-yes:hover { opacity: 0.9; box-shadow: 0 6px 24px rgba(201,168,76,0.42); transform: translateY(-1px); }
    .qp-btn-no {
      padding: 15px 20px;
      background: transparent;
      color: #b8b0a0;
      font-family: 'Inter', sans-serif;
      font-size: 14px;
      font-weight: 600;
      border: 1px solid rgba(255,255,255,0.14);
      border-radius: 12px;
      cursor: pointer;
      transition: border-color 0.2s, background 0.2s, color 0.2s;
    }
    .qp-btn-no:hover { border-color: rgba(255,255,255,0.28); background: rgba(255,255,255,0.05); color: #f0ece3; }
    .qp-close {
      position: absolute; top: 14px; right: 16px;
      background: none; border: none;
      color: rgba(240,236,227,0.35); font-size: 20px; line-height: 1;
      cursor: pointer; padding: 4px 8px; border-radius: 6px;
      transition: color 0.2s;
    }
    .qp-close:hover { color: rgba(240,236,227,0.7); }
    @media (max-width: 480px) {
      .qp-modal { padding: 32px 22px 26px; }
      .qp-actions { grid-template-columns: 1fr; }
    }
  `;
  const style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);

  const html = `
    <div id="qualifierPromptOverlay" role="dialog" aria-modal="true" aria-labelledby="qpTitle">
      <div class="qp-modal">
        <button class="qp-close" onclick="closeQualifierPrompt()" aria-label="Close">&#x2715;</button>
        <div class="qp-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9 12l2 2 4-4"/><path d="M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2z"/>
          </svg>
        </div>
        <div class="qp-title" id="qpTitle">Before You Apply</div>
        <p class="qp-subtitle">Would you like to take a quick qualifier test to check your eligibility before submitting an application?</p>
        <div class="qp-actions">
          <button class="qp-btn-yes" onclick="closeQualifierPrompt(); window.location.href='Qualifier.html';">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12l2 2 4-4"/><circle cx="12" cy="12" r="10"/></svg>
            Yes, Take the Qualifier
          </button>
          <button class="qp-btn-no" onclick="closeQualifierPrompt(); window.open('admission-form.html','_blank','width=1200,height=900,scrollbars=yes,resizable=yes');">
            No, Apply Directly
          </button>
        </div>
      </div>
    </div>
  `;
  document.body.insertAdjacentHTML('beforeend', html);

  // Close on backdrop click
  document.getElementById('qualifierPromptOverlay').addEventListener('click', function(e) {
    if (e.target === this) closeQualifierPrompt();
  });
}

function openQualifierPrompt() {
  ensureQualifierPromptOverlay();
  requestAnimationFrame(() => {
    document.getElementById('qualifierPromptOverlay').classList.add('qp-open');
    document.body.style.overflow = 'hidden';
  });
}

function closeQualifierPrompt() {
  const overlay = document.getElementById('qualifierPromptOverlay');
  if (overlay) overlay.classList.remove('qp-open');
  document.body.style.overflow = '';
}

if (typeof window.openQualifierPrompt !== 'function') {
  window.openQualifierPrompt = openQualifierPrompt;
}
if (typeof window.closeQualifierPrompt !== 'function') {
  window.closeQualifierPrompt = closeQualifierPrompt;
}

function ensureCatalogPickerOverlay() {
  if (document.getElementById('catalogPickerOverlay')) return;

  const pickerHtml = `
    <div class="picker-overlay hidden" id="catalogPickerOverlay" aria-label="Select a program catalog">
      <div class="picker-modal">
        <div class="picker-eyebrow">Official Institutional Publication</div>
        <h2>Academic Catalog</h2>
        <p>Armenian College of Nursing &amp; Health Sciences<br>Select the program catalog you'd like to view.</p>
        <div class="picker-cards">
          <button class="picker-card" onclick="openCatalogProgram('bsn')" aria-label="View BSN Catalog">
            <div class="picker-card-badge">BSN</div>
            <h3>Bachelor of Science in Nursing</h3>
            <div class="pick-meta">4 Academic Years · 124 Credits<br>~960–1,050 Clinical Hours</div>
            <span class="pick-cta">View BSN Catalog</span>
          </button>
          <button class="picker-card" onclick="openCatalogProgram('asn')" aria-label="View ASN Catalog">
            <div class="picker-card-badge">ASN</div>
            <h3>Associate of Science in Nursing</h3>
            <div class="pick-meta">3 Academic Years · 72–78 Credits<br>~810–850 Clinical Hours</div>
            <span class="pick-cta">View ASN Catalog</span>
          </button>
        </div>
      </div>
    </div>
  `;
  document.body.insertAdjacentHTML('beforeend', pickerHtml);
}

let catalogPickerWired = false;

function openCatalogPicker() {
  ensureCatalogPickerOverlay();
  const overlay = document.getElementById('catalogPickerOverlay');
  if (overlay) {
    overlay.classList.remove('hidden');
    document.body.classList.add('picker-open');
  }
}

function closeCatalogPicker() {
  const overlay = document.getElementById('catalogPickerOverlay');
  if (overlay) {
    overlay.classList.add('hidden');
    document.body.classList.remove('picker-open');
  }
  if (typeof window.setCatalogProgram === 'function') {
    const storedProgram = sessionStorage.getItem('acnhs_catalog_program');
    if (storedProgram === 'bsn' || storedProgram === 'asn') {
      window.setCatalogProgram(storedProgram, false);
    } else {
      // No program chosen — navigate back to where the user came from
      if (window.location.pathname.includes('academic-catalog')) {
        if (document.referrer && !document.referrer.includes('academic-catalog')) {
          history.back();
        } else {
          window.location.href = 'index.html';
        }
      }
    }
  }
}

function openCatalogProgram(program) {
  closeCatalogPicker();
  sessionStorage.setItem('acnhs_catalog_program', program);
  if (typeof window.setCatalogProgram === 'function') {
    window.setCatalogProgram(program, true);
    const url = new URL(window.location.href);
    url.searchParams.set('program', program);
    window.history.replaceState({}, '', url.toString());
    return;
  }
  window.location.href = `academic-catalog.html?program=${program}`;
}

if (typeof window.openCatalogPicker !== 'function') {
  window.openCatalogPicker = openCatalogPicker;
}

if (typeof window.openCatalogProgram !== 'function') {
  window.openCatalogProgram = openCatalogProgram;
}

if (!catalogPickerWired) {
  document.addEventListener('mousedown', (event) => {
    const overlay = document.getElementById('catalogPickerOverlay');
    if (!overlay || overlay.classList.contains('hidden')) return;
    if (event.target === overlay) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  document.addEventListener('mouseup', (event) => {
    const overlay = document.getElementById('catalogPickerOverlay');
    if (!overlay || overlay.classList.contains('hidden')) return;
    if (event.target === overlay) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  document.addEventListener('touchstart', (event) => {
    const overlay = document.getElementById('catalogPickerOverlay');
    if (!overlay || overlay.classList.contains('hidden')) return;
    if (event.target === overlay) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, { capture: true, passive: false });

  document.addEventListener('touchend', (event) => {
    const overlay = document.getElementById('catalogPickerOverlay');
    if (!overlay || overlay.classList.contains('hidden')) return;
    if (event.target === overlay) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, { capture: true, passive: false });

  document.addEventListener('click', (event) => {
    const overlay = document.getElementById('catalogPickerOverlay');
    if (!overlay || overlay.classList.contains('hidden')) return;
    if (event.target === overlay) {
      event.preventDefault();
      event.stopPropagation();
      setTimeout(() => closeCatalogPicker(), 0);
    }
  });

  document.addEventListener('keydown', (event) => {
    if (event.key !== 'Escape') return;
    const overlay = document.getElementById('catalogPickerOverlay');
    if (overlay && !overlay.classList.contains('hidden')) closeCatalogPicker();
  });
  catalogPickerWired = true;
}

const injectSiteChrome = once(async function injectSiteChrome() {
  const headerMount = document.querySelector('[data-acnhs-header]');
  const footerMount = document.querySelector('[data-acnhs-footer]');

  // Always try to load logo if the script is present
  if (typeof window.applyAcnshLogo === 'function') {
    window.applyAcnshLogo();
  } else if (typeof applyAcnshLogo === 'function') {
    applyAcnshLogo();
  }

  if (!headerMount && !footerMount) return;

  if (headerMount) {
    // Direct injection - No fetch needed
    headerMount.innerHTML = ACNHS_HEADER_HTML;
    wireHeaderInteractions(headerMount);
    
    // Re-apply logo if it was inside the injected header
    if (typeof window.applyAcnshLogo === 'function') {
      window.applyAcnshLogo();
    }
  }

  if (footerMount) {
    // Direct injection - No fetch needed
    footerMount.innerHTML = ACNHS_FOOTER_HTML;
  }
});

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', injectSiteChrome);
} else {
  injectSiteChrome();
}

