/* Shared header/footer injection for ACNHS static site (no build tools). */

async function acnhsFetchPartial(path) {
  const res = await fetch(path, { cache: 'no-store' });
  if (!res.ok) throw new Error(`Failed to load ${path}: ${res.status}`);
  return await res.text();
}

function once(fn) {
  let ran = false;
  return (...args) => {
    if (ran) return;
    ran = true;
    return fn(...args);
  };
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
      if (typeof window.toggleHelpDropdown === 'function') {
        window.toggleHelpDropdown();
        return;
      }
      const dropdown = root.querySelector('#helpDropdown');
      dropdown?.classList.toggle('active');
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
  if (!headerMount && !footerMount) return;

  const tasks = [];

  if (headerMount) {
    tasks.push(
      acnhsFetchPartial('partials/site-header.html')
        .then(html => {
          headerMount.innerHTML = html;
          wireHeaderInteractions(headerMount);
        })
        .catch((err) => {
          console.warn('Header injection failed:', err);
        })
    );
  }

  if (footerMount) {
    tasks.push(
      acnhsFetchPartial('partials/site-footer.html')
        .then(html => {
          footerMount.innerHTML = html;
        })
        .catch((err) => {
          console.warn('Footer injection failed:', err);
        })
    );
  }

  await Promise.all(tasks);
});

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', injectSiteChrome);
} else {
  injectSiteChrome();
}
