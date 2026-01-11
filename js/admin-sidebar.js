// Admin Sidebar Navigation Component
// Include this script in all admin pages
// Updated: 2026-01-12 - Added Permission-Based Access Control

(function() {
  'use strict';

  // Get user permissions from localStorage/sessionStorage
  function getUserPermissions() {
    try {
      const permissionsStr = sessionStorage.getItem('userPermissions') || localStorage.getItem('userPermissions');
      return permissionsStr ? JSON.parse(permissionsStr) : null;
    } catch (e) {
      console.error('Error parsing permissions:', e);
      return null;
    }
  }

  // Check if user has a specific permission
  function hasPermission(permissionKey) {
    const permissions = getUserPermissions();
    if (!permissions) {
      // If no permissions found, check if user is main admin
      const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail');
      const ADMIN_EMAILS = ['Hrachfilm@gmail.com', 'hrachfilm@gmail.com'];
      return ADMIN_EMAILS.some(email => email.toLowerCase() === userEmail?.toLowerCase());
    }
    return permissions[permissionKey] === true;
  }

  // Check if user is main admin
  function isMainAdmin() {
    const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail');
    const ADMIN_EMAILS = ['Hrachfilm@gmail.com', 'hrachfilm@gmail.com'];
    return ADMIN_EMAILS.some(email => email.toLowerCase() === userEmail?.toLowerCase());
  }

  // Create sidebar HTML
  function createAdminSidebar() {
    const currentPage = window.location.pathname.split('/').pop();
    const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail') || 'Admin';
    const userName = sessionStorage.getItem('userName') || localStorage.getItem('userName') || userEmail;
    const userRole = sessionStorage.getItem('userRole') || localStorage.getItem('userRole') || 'Administrator';
    const initials = userName.split(' ').map(n => n.charAt(0)).join('').toUpperCase().slice(0, 2);

    // Define menu items with their required permissions
    const menuItems = [
      { 
        href: 'admin-home.html', 
        icon: '🏠', 
        text: 'Dashboard', 
        permission: null // Always visible
      },
      { 
        href: 'admin-applications.html', 
        icon: '📋', 
        text: 'Applications', 
        permission: 'view_applications'
      },
      { 
        href: 'email-system.html', 
        icon: '💬', 
        text: 'Email System', 
        permission: 'send_emails'
      },
      { 
        href: 'verify-transcript.html', 
        icon: '✓', 
        text: 'Verification', 
        permission: 'view_applications' // Same as applications
      },
      { 
        href: 'help-handbook.html', 
        icon: '📖', 
        text: 'Students', 
        permission: 'view_applications'
      },
      { 
        href: 'admin-users.html', 
        icon: '👥', 
        text: 'User Management', 
        permission: 'manage_users'
      },
      { 
        href: 'help-grading.html', 
        icon: '📊', 
        text: 'Grading Calc', 
        permission: 'view_reports'
      },
      { 
        href: 'help-appeals.html', 
        icon: '⚖️', 
        text: 'Appeals', 
        permission: 'edit_applications'
      }
    ];

    // Filter menu items based on permissions
    const navItemsHTML = menuItems
      .filter(item => !item.permission || hasPermission(item.permission) || isMainAdmin())
      .map(item => `
        <a href="${item.href}" class="nav-item ${currentPage === item.href ? 'active' : ''}" data-tooltip="${item.text}">
          <span class="icon">${item.icon}</span>
          <span class="text">${item.text}</span>
        </a>
      `).join('');

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
          ${navItemsHTML}
        </nav>
        
        <div class="sidebar-footer">
          <div class="admin-info">
            <div class="admin-avatar">${initials}</div>
            <div class="admin-details">
              <div class="name">${userName}</div>
              <div class="role">${userRole}</div>
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
