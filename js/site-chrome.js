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
          <a href="academic-catalog.html" role="menuitem">Academic Catalog</a>
          <a href="index.html#programs" role="menuitem">Programs</a>
          <a href="#" role="menuitem" data-action="open-curriculum">Curriculum</a>
          <a href="index.html#simulation" role="menuitem">Simulation</a>
        </div>
      </div>

      <a href="index.html#global-network" style="color:var(--gold-400);font-weight:600;">Global Network</a>

      <div class="help-dropdown" id="helpDropdown">
        <button class="help-btn" type="button" data-action="toggle-help">
          Help
          <span class="help-arrow" aria-hidden="true"></span>
        </button>
        <div class="help-dropdown-content" role="menu">
          <a href="help-handbook.html" role="menuitem">Student Handbook</a>
          <a href="help-grading.html" role="menuitem">Grading</a>
          <a href="help-appeals.html" role="menuitem" data-login-required="true">Appeals &amp; Remediation</a>
          <a href="#" role="menuitem" data-action="coming-soon" data-label="Attendance" data-login-required="true">Attendance</a>
          <a href="help-clinical.html" role="menuitem">Clinical</a>
          <a href="help-support.html" role="menuitem">Support</a>
        </div>
      </div>
    </nav>

    <div class="nav-actions">
      <button class="btn btn-ghost" type="button" data-action="student-login">Login</button>
      <button class="btn btn-primary" type="button" data-action="apply-now">Apply Now</button>
    </div>
  </div>
</header>
`;

const ACNHS_FOOTER_HTML = `
<footer class="site-footer">
  <div class="footer-inner">
    <div class="footer-brand">
      <div class="footer-name">Armenian College of Nursing &amp; Health Sciences</div>
      <div class="footer-sub">Yerevan, Armenia · Ministry-Aligned · NCLEX-RN Curriculum · International Transcript Ready</div>
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

  // Student login
  root.querySelectorAll('[data-action="student-login"]').forEach(btn => {
    btn.addEventListener('click', () => {
      window.location.href = 'login.html';
    });
  });

  // Apply now
  root.querySelectorAll('[data-action="apply-now"]').forEach(btn => {
    btn.addEventListener('click', () => {
      // Fire GA4 key event
      if (typeof gtag !== 'undefined') {
        gtag('event', 'apply_now_click', {
          button_location: 'header',
          page_path: window.location.pathname
        });
      }
      // Match index behavior: open in popup window.
      window.open('admission-form.html', '_blank', 'width=1200,height=900,scrollbars=yes,resizable=yes');
    });
  });

  // Optional: hide login-required links when not logged in.
  const isLoggedIn = sessionStorage.getItem('isLoggedIn') === 'true' || localStorage.getItem('isLoggedIn') === 'true';
  if (!isLoggedIn) {
    root.querySelectorAll('[data-login-required="true"]').forEach(el => {
      el.style.display = 'none';
    });
  }
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

