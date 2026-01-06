// Admin Sidebar Navigation Component
// Include this script in all admin pages

(function() {
  'use strict';

  // Create sidebar HTML
  function createAdminSidebar() {
    const currentPage = window.location.pathname.split('/').pop();
    const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail') || 'Admin';
    const initials = userEmail.charAt(0).toUpperCase();

    const sidebarHTML = `
      <!-- Mobile Menu Button -->
      <button class="mobile-menu-btn" id="mobileMenuBtn">☰</button>
      
      <!-- Sidebar Overlay (Mobile) -->
      <div class="sidebar-overlay" id="sidebarOverlay"></div>
      
      <!-- Admin Sidebar -->
      <aside class="admin-sidebar" id="adminSidebar">
        <button class="sidebar-toggle" id="sidebarToggle">◀</button>
        
        <div class="sidebar-logo">
          <img src="assets/images/Seal.png" alt="ACNHS Logo">
          <h2>ACNHS Admin</h2>
        </div>
        
        <nav class="sidebar-nav">
          <a href="admin-home.html" class="nav-item ${currentPage === 'admin-home.html' ? 'active' : ''}" data-tooltip="Dashboard">
            <span class="icon">🏠</span>
            <span class="text">Dashboard</span>
          </a>
          
          <a href="admin-applications.html" class="nav-item ${currentPage === 'admin-applications.html' ? 'active' : ''}" data-tooltip="Applications">
            <span class="icon">📋</span>
            <span class="text">Applications</span>
          </a>
          
          <a href="sms-demo.html" class="nav-item ${currentPage === 'sms-demo.html' ? 'active' : ''}" data-tooltip="SMS System">
            <span class="icon">💬</span>
            <span class="text">SMS System</span>
          </a>
          
          <a href="verify-transcript.html" class="nav-item ${currentPage === 'verify-transcript.html' ? 'active' : ''}" data-tooltip="Verify Transcripts">
            <span class="icon">✓</span>
            <span class="text">Verify Transcripts</span>
          </a>
          
          <a href="help-handbook.html" class="nav-item ${currentPage === 'help-handbook.html' ? 'active' : ''}" data-tooltip="Handbook">
            <span class="icon">📖</span>
            <span class="text">Handbook</span>
          </a>
          
          <a href="help-grading.html" class="nav-item ${currentPage === 'help-grading.html' ? 'active' : ''}" data-tooltip="Grading System">
            <span class="icon">📊</span>
            <span class="text">Grading System</span>
          </a>
          
          <a href="help-appeals.html" class="nav-item ${currentPage === 'help-appeals.html' ? 'active' : ''}" data-tooltip="Appeals">
            <span class="icon">⚖️</span>
            <span class="text">Appeals</span>
          </a>
        </nav>
        
        <div class="sidebar-footer">
          <div class="admin-info">
            <div class="admin-avatar">${initials}</div>
            <div class="admin-details">
              <div class="name">${userEmail}</div>
              <div class="role">Administrator</div>
            </div>
          </div>
          <button class="logout-btn" id="adminLogoutBtn">
            <span class="icon">🚪</span>
            <span class="text">Logout</span>
          </button>
        </div>
      </aside>
    `;

    return sidebarHTML;
  }

  // Initialize sidebar
  function initAdminSidebar() {
    // Check if sidebar already exists
    if (document.getElementById('adminSidebar')) {
      return;
    }

    // Insert sidebar at the beginning of body
    const sidebarHTML = createAdminSidebar();
    document.body.insertAdjacentHTML('afterbegin', sidebarHTML);

    // Wrap existing content - find the main content container
    const sidebar = document.getElementById('adminSidebar');
    const overlay = document.getElementById('sidebarOverlay');
    const mobileBtn = document.getElementById('mobileMenuBtn');
    
    // Find existing content wrapper or create one
    let contentWrapper = null;
    
    // Check if there's already a wrapper with these classes
    const existingWrappers = document.querySelectorAll('.admin-content, .container, main, .main-content');
    
    if (existingWrappers.length > 0) {
      // Content is already wrapped, just ensure it's positioned correctly
      existingWrappers.forEach(wrapper => {
        // Move wrapper after sidebar elements if needed
        if (wrapper !== sidebar && wrapper !== overlay && wrapper !== mobileBtn) {
          document.body.appendChild(wrapper);
        }
      });
    } else {
      // No wrapper found, create one and wrap all non-sidebar content
      contentWrapper = document.createElement('div');
      contentWrapper.className = 'admin-content';
      
      // Move all non-sidebar elements into wrapper
      const elementsToWrap = [];
      for (let i = 0; i < document.body.children.length; i++) {
        const child = document.body.children[i];
        if (child !== sidebar && child !== overlay && child !== mobileBtn && child !== contentWrapper) {
          elementsToWrap.push(child);
        }
      }
      
      elementsToWrap.forEach(element => {
        contentWrapper.appendChild(element);
      });
      
      document.body.appendChild(contentWrapper);
    }

    // Setup event listeners
    setupSidebarEvents();
    
    // Restore collapsed state from localStorage
    const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
    if (isCollapsed) {
      sidebar.classList.add('collapsed');
    }
  }

  // Setup event listeners
  function setupSidebarEvents() {
    const sidebar = document.getElementById('adminSidebar');
    const toggleBtn = document.getElementById('sidebarToggle');
    const logoElement = document.querySelector('.sidebar-logo');
    const logoutBtn = document.getElementById('adminLogoutBtn');
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const overlay = document.getElementById('sidebarOverlay');

    // Toggle sidebar collapse via LOGO click (desktop)
    if (logoElement) {
      logoElement.addEventListener('click', function() {
        sidebar.classList.toggle('collapsed');
        const isCollapsed = sidebar.classList.contains('collapsed');
        localStorage.setItem('sidebarCollapsed', isCollapsed);
      });
    }

    // Mobile menu toggle
    if (mobileMenuBtn) {
      mobileMenuBtn.addEventListener('click', function() {
        sidebar.classList.add('mobile-open');
        overlay.classList.add('show');
      });
    }

    // Close mobile menu
    if (overlay) {
      overlay.addEventListener('click', function() {
        sidebar.classList.remove('mobile-open');
        overlay.classList.remove('show');
      });
    }

    // Logout functionality
    if (logoutBtn) {
      logoutBtn.addEventListener('click', function() {
        if (confirm('Are you sure you want to logout?')) {
          // Clear all session data
          sessionStorage.clear();
          localStorage.removeItem('isLoggedIn');
          localStorage.removeItem('isAdmin');
          localStorage.removeItem('userEmail');
          localStorage.removeItem('userId');
          
          // Redirect to login
          window.location.href = 'login.html';
        }
      });
    }

    // Close mobile menu when clicking nav items
    const navItems = sidebar.querySelectorAll('.nav-item');
    navItems.forEach(item => {
      item.addEventListener('click', function() {
        if (window.innerWidth <= 768) {
          sidebar.classList.remove('mobile-open');
          overlay.classList.remove('show');
        }
      });
    });
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAdminSidebar);
  } else {
    initAdminSidebar();
  }

  // Export for manual initialization if needed
  window.initAdminSidebar = initAdminSidebar;
})();
