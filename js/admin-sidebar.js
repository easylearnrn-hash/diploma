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
    
    // Debug logging
    console.log('🔍 Checking permission:', permissionKey);
    console.log('📋 User permissions:', permissions);
    
    if (!permissions) {
      // If no permissions found, check if user is main admin
      const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail');
      const ADMIN_EMAILS = ['Hrachfilm@gmail.com', 'hrachfilm@gmail.com'];
      const isAdmin = ADMIN_EMAILS.some(email => email.toLowerCase() === userEmail?.toLowerCase());
      console.log('⚠️ No permissions object found, checking if main admin:', isAdmin);
      return isAdmin;
    }
    
    const hasAccess = permissions[permissionKey] === true;
    console.log(`${hasAccess ? '✅' : '❌'} Permission "${permissionKey}":`, hasAccess);
    return hasAccess;
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
        href: 'info.html', 
        icon: '🗂️', 
        text: 'All Applicants', 
        permission: 'view_applications'
      },
      { 
        href: 'admin-forms.html', 
        icon: '📝', 
        text: 'Student Services', 
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
        href: 'admin-students.html', 
        icon: '📖', 
        text: 'Students', 
        permission: 'view_applications'
      },
      { 
        href: 'admin-payments.html', 
        icon: '💳', 
        text: 'Payments', 
        permission: 'view_applications'
      },
      { 
        href: 'admin-hub.html', 
        icon: '🎯', 
        text: 'Admin Hub', 
        permission: null, // Checks internally for specific admins
        allowedEmails: ['hrachfilm@gmail.com', 's.gharibyan@acnhs.am']
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
        href: 'admin-test-grades.html', 
        icon: '🏆', 
        text: 'Test Grades', 
        permission: 'view_reports'
      },
      { 
        href: 'certificate.html', 
        icon: '🏅', 
        text: 'Certificates', 
        permission: 'view_reports'
      },
      { 
        href: 'documents.html', 
        icon: '📜', 
        text: 'Documents', 
        permission: 'view_reports'
      }, 
      {
        href: 'Export.html',
        icon: '📤',
        text: 'Export',
        permission: 'view_reports'
      },
      { 
        href: 'admin-analytics.html', 
        icon: '📈', 
        text: 'Analytics', 
        permission: null, // Admin-only via email check
        allowedEmails: ['hrachfilm@gmail.com', 's.gharibyan@acnhs.am', 'Hrachfilm@gmail.com']
      },
      { 
        href: 'help-appeals.html', 
        icon: '⚖️', 
        text: 'Appeals', 
        permission: 'edit_applications'
      },
      { 
        href: 'notes.html', 
        icon: '📚', 
        text: 'All Notes', 
        permission: null,
        allowedEmails: ['hrachfilm@gmail.com', 'Hrachfilm@gmail.com']
      },
      { 
        href: '#', 
        icon: '⚙️', 
        text: 'Settings', 
        permission: null, // Always visible
        id: 'settingsMenuItem'
      }
    ];

    // Filter menu items based on permissions
    console.log('🔧 Filtering menu items...');
    const navItemsHTML = menuItems
      .filter(item => {
        // Check for email-specific access
        if (item.allowedEmails) {
          const currentEmail = (sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail') || '').toLowerCase();
          const hasEmailAccess = item.allowedEmails.some(email => email.toLowerCase() === currentEmail);
          console.log(`${hasEmailAccess ? '✅' : '❌'} ${item.text}: ${hasEmailAccess ? 'VISIBLE' : 'HIDDEN'} (email check: ${currentEmail})`);
          return hasEmailAccess;
        }
        
        if (!item.permission) {
          console.log(`✅ ${item.text}: Always visible (no permission required)`);
          return true;
        }
        const hasAccess = hasPermission(item.permission) || isMainAdmin();
        console.log(`${hasAccess ? '✅' : '❌'} ${item.text}: ${hasAccess ? 'VISIBLE' : 'HIDDEN'} (requires: ${item.permission})`);
        return hasAccess;
      })
      .map(item => `
        <a href="${item.href}" class="nav-item ${currentPage === item.href ? 'active' : ''}" data-tooltip="${item.text}" ${item.id ? `id="${item.id}"` : ''}>
          <span class="icon">${item.icon}</span>
          <span class="text">${item.text}</span>
          ${item.href === 'admin-forms.html' ? '<span class="nav-badge" id="formsNavBadge" style="display:none">0</span>' : ''}
        </a>
      `).join('');

    const logoSrc = window.ACNHS_LOGO_DATA_URL
      || window.ACNHS_LOGO_EMAIL_URL
      || (window.ACNHS_LOGO_BASE64 ? `data:image/png;base64,${window.ACNHS_LOGO_BASE64}` : '');

    const sidebarHTML = `
      <!-- Mobile Menu Button -->
      <button class="mobile-menu-btn" id="mobileMenuBtn">☰</button>
      
      <!-- Sidebar Overlay (Mobile) -->
      <div class="sidebar-overlay" id="sidebarOverlay"></div>
      
      <!-- Admin Sidebar -->
      <aside class="admin-sidebar" id="adminSidebar">
        <button class="sidebar-toggle" id="sidebarToggle">◀</button>
        
        <div class="sidebar-logo">
          <img src="${logoSrc}" alt="ACNHS Logo" data-acnhs-logo>
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
      
      <!-- Logout Confirmation Modal -->
      <div class="modal" id="logoutModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(2,8,20,0.78); z-index: 10000; align-items: center; justify-content: center; backdrop-filter: blur(8px);">
        <div style="
          width: 100%; max-width: 400px;
          border-radius: 20px;
          background: linear-gradient(180deg, #071b30 0%, #04111f 100%);
          border: 1px solid rgba(201,168,76,0.28);
          box-shadow: 0 32px 80px rgba(0,0,0,0.60), 0 0 0 1px rgba(201,168,76,0.06) inset;
          overflow: hidden;
        ">
          <!-- Gold accent bar -->
          <div style="height: 3px; background: linear-gradient(90deg, transparent 0%, #c9a84c 40%, #d4b56a 60%, transparent 100%);"></div>

          <!-- Header -->
          <div style="padding: 32px 32px 24px; text-align: center; position: relative;">
            <!-- Close button -->
            <button class="close-btn" id="closeLogoutModal" style="
              position: absolute; top: 16px; right: 16px;
              width: 28px; height: 28px; border-radius: 8px;
              background: rgba(201,168,76,0.08); border: 1px solid rgba(201,168,76,0.28);
              color: #8a8070; font-size: 16px; line-height: 1;
              cursor: pointer; display: flex; align-items: center; justify-content: center;
              transition: all 0.2s; padding: 0;
            ">×</button>

            <!-- Icon -->
            <div style="
              width: 64px; height: 64px; margin: 0 auto 18px;
              border-radius: 18px;
              background: linear-gradient(145deg, rgba(201,168,76,0.18) 0%, rgba(201,168,76,0.06) 100%);
              border: 1px solid rgba(201,168,76,0.28);
              box-shadow: 0 8px 24px rgba(201,168,76,0.12), 0 0 0 6px rgba(201,168,76,0.05);
              display: flex; align-items: center; justify-content: center;
              font-size: 28px;
            ">🚪</div>

            <!-- Institution label -->
            <div style="
              font-size: 10px; font-weight: 800; letter-spacing: 0.12em;
              text-transform: uppercase; color: #c9a84c;
              margin-bottom: 8px;
            ">ARMENIAN COLLEGE OF NURSING &amp; HEALTH SCIENCES</div>

            <!-- Title -->
            <h2 style="font-size: 20px; font-weight: 900; letter-spacing: -0.03em; color: #f0ece3; margin: 0 0 10px;">Confirm Logout</h2>

            <!-- Subtitle -->
            <p style="font-size: 13px; color: #c8bfb2; line-height: 1.6; margin: 0;">You are about to end your session.<br>Any unsaved changes will be lost.</p>
          </div>

          <!-- Divider -->
          <div style="height: 1px; margin: 0 32px; background: linear-gradient(90deg, transparent, rgba(201,168,76,0.28), transparent);"></div>

          <!-- Buttons -->
          <div style="padding: 20px 32px 28px; display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <button id="cancelLogoutBtn" style="
              height: 44px; border-radius: 12px;
              background: rgba(201,168,76,0.06); color: #c8bfb2;
              border: 1px solid rgba(201,168,76,0.28);
              font-size: 13.5px; font-weight: 700;
              cursor: pointer; transition: all 0.2s ease;
            ">Cancel</button>
            <button id="confirmLogoutBtn" style="
              height: 44px; border-radius: 12px;
              background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%);
              color: #fff; border: none;
              font-size: 13.5px; font-weight: 700;
              cursor: pointer; transition: all 0.2s ease;
              box-shadow: 0 4px 16px rgba(239,68,68,0.28);
            ">Logout</button>
          </div>
        </div>
      </div>
      
      <!-- Settings Modal -->
      <div class="modal" id="settingsModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.7); z-index: 10000; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
        <div class="modal-content" style="max-width: 520px; border-radius: 12px; overflow: hidden; background: #1e293b; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);">
          <div class="modal-header" style="border: none; background: transparent; padding: 0; position: relative;">
            <button class="close-btn" id="closeSettingsModal" style="position: absolute; top: 12px; right: 12px; z-index: 10; background: rgba(15, 23, 42, 0.5); width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 20px; line-height: 1; padding: 0; backdrop-filter: blur(10px); border: none; cursor: pointer; transition: all 0.2s;">×</button>
            <div style="text-align: center; padding: 24px 28px 16px 28px; background: linear-gradient(135deg, rgba(99, 102, 241, 0.08), rgba(79, 70, 229, 0.05));">
              <div style="width: 56px; height: 56px; background: linear-gradient(135deg, #6366f1, #4f46e5); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 30px; margin: 0 auto 12px auto; box-shadow: 0 6px 20px rgba(99, 102, 241, 0.3);">
                ⚙️
              </div>
              <h2 style="font-size: 18px; font-weight: 600; color: #f1f5f9; margin: 0; letter-spacing: -0.02em;">Settings</h2>
            </div>
          </div>
          <div style="padding: 24px 28px; background: #1e293b;">
            <!-- Email Notifications Section -->
            <div style="margin-bottom: 20px;">
              <h3 style="font-size: 14px; font-weight: 600; color: #f1f5f9; margin: 0 0 16px 0; display: flex; align-items: center; gap: 8px;">
                <span style="font-size: 18px;">📧</span> Email Notifications
              </h3>
              
              <!-- BCC Recipients List -->
              <div id="bccRecipientsList" style="display: flex; flex-direction: column; gap: 12px;">
                <!-- Recipients will be dynamically loaded here -->
              </div>
              
              <!-- Add New Recipient Button -->
              <button id="addBccRecipientBtn" style="width: 100%; margin-top: 12px; padding: 12px; background: rgba(99, 102, 241, 0.1); border: 1px dashed rgba(99, 102, 241, 0.3); border-radius: 8px; color: #818cf8; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; gap: 8px;">
                <span style="font-size: 16px;">➕</span> Add Email Recipient
              </button>
            </div>
            
            <div style="padding-top: 16px; border-top: 1px solid rgba(71, 85, 105, 0.3);">
              <div style="font-size: 12px; color: #64748b; display: flex; align-items: start; gap: 6px; line-height: 1.5;">
                <span style="font-size: 14px; margin-top: 1px;">💡</span>
                <div>
                  <div style="margin-bottom: 4px;">Each recipient can choose which email types to receive:</div>
                  <div style="padding-left: 12px; margin-top: 4px;">
                    <div>📝 <strong>Application Submissions</strong> - New student applications</div>
                    <div>📋 <strong>Status Changes</strong> - Application status updates</div>
                    <div>🔐 <strong>Password Resets</strong> - Student password reset notifications</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
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

    // Always start collapsed on page load/refresh
    localStorage.setItem('sidebarCollapsed', 'true');
    sidebar.classList.add('collapsed');

    // Initialize submission badge
    initFormsBadge();
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
        const modal = document.getElementById('logoutModal');
        if (modal) modal.style.display = 'flex';
      });
    }
    
    // Logout modal event listeners
    const logoutModal = document.getElementById('logoutModal');
    const closeLogoutModal = document.getElementById('closeLogoutModal');
    const cancelLogoutBtn = document.getElementById('cancelLogoutBtn');
    const confirmLogoutBtn = document.getElementById('confirmLogoutBtn');
    
    // Close modal function
    function hideModal() {
      if (logoutModal) logoutModal.style.display = 'none';
    }
    
    // X button closes modal
    if (closeLogoutModal) {
      closeLogoutModal.addEventListener('click', hideModal);
      closeLogoutModal.addEventListener('mouseenter', function() {
        this.style.background = 'rgba(201,168,76,0.18)';
        this.style.color = '#e2cc92';
      });
      closeLogoutModal.addEventListener('mouseleave', function() {
        this.style.background = 'rgba(201,168,76,0.08)';
        this.style.color = '#8a8070';
      });
    }
    
    // Cancel button closes modal
    if (cancelLogoutBtn) {
      cancelLogoutBtn.addEventListener('click', hideModal);
      cancelLogoutBtn.addEventListener('mouseenter', function() {
        this.style.background = 'rgba(201,168,76,0.14)';
        this.style.color = '#e2cc92';
        this.style.transform = 'translateY(-1px)';
      });
      cancelLogoutBtn.addEventListener('mouseleave', function() {
        this.style.background = 'rgba(201,168,76,0.06)';
        this.style.color = '#c8bfb2';
        this.style.transform = 'translateY(0)';
      });
    }
    
    // Confirm button performs logout
    if (confirmLogoutBtn) {
      confirmLogoutBtn.addEventListener('click', function() {
        sessionStorage.clear();
        localStorage.removeItem('isLoggedIn');
        localStorage.removeItem('isAdmin');
        localStorage.removeItem('userEmail');
        localStorage.removeItem('userId');
        window.location.href = 'login.html';
      });
      confirmLogoutBtn.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-2px)';
        this.style.boxShadow = '0 8px 28px rgba(239,68,68,0.42)';
      });
      confirmLogoutBtn.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0)';
        this.style.boxShadow = '0 4px 16px rgba(239,68,68,0.28)';
      });
    }
    
    // Close on backdrop click
    if (logoutModal) {
      logoutModal.addEventListener('click', function(e) {
        if (e.target === logoutModal) hideModal();
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
    
    // Settings modal functionality
    const settingsMenuItem = document.getElementById('settingsMenuItem');
    const settingsModal = document.getElementById('settingsModal');
    const closeSettingsModal = document.getElementById('closeSettingsModal');
    const bccRecipientsList = document.getElementById('bccRecipientsList');
    const addBccRecipientBtn = document.getElementById('addBccRecipientBtn');
    
    // Default BCC recipients
    const defaultRecipients = [
      { 
        email: 'hrachfilm@gmail.com', 
        enabled: true, 
        label: 'Main Admin',
        emailTypes: {
          applicationSubmission: true,
          statusChange: true,
          passwordReset: true
        }
      }
    ];
    
    // Get BCC recipients from localStorage
    function getBccRecipients() {
      try {
        const stored = localStorage.getItem('bccRecipients');
        return stored ? JSON.parse(stored) : defaultRecipients;
      } catch (e) {
        console.error('Error loading BCC recipients:', e);
        return defaultRecipients;
      }
    }
    
    // Save BCC recipients to localStorage
    function saveBccRecipients(recipients) {
      localStorage.setItem('bccRecipients', JSON.stringify(recipients));
      console.log('💾 BCC Recipients saved:', recipients);
    }
    
    // Create recipient card HTML
    function createRecipientCard(recipient, index) {
      // Ensure emailTypes exists with defaults
      const emailTypes = recipient.emailTypes || {
        applicationSubmission: true,
        statusChange: true,
        passwordReset: true
      };
      
      return `
        <div class="bcc-recipient-card" data-index="${index}" style="background: rgba(51, 65, 85, 0.5); padding: 14px; border-radius: 8px; border: 1px solid rgba(71, 85, 105, 0.3);">
          <div style="display: flex; gap: 12px; align-items: flex-start; margin-bottom: 12px;">
            <label style="position: relative; display: inline-block; width: 48px; height: 26px; flex-shrink: 0; margin-top: 20px;">
              <input type="checkbox" class="recipient-toggle" data-index="${index}" ${recipient.enabled ? 'checked' : ''} style="opacity: 0; width: 0; height: 0;">
              <span style="position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: ${recipient.enabled ? '#10b981' : '#475569'}; transition: 0.3s; border-radius: 26px; box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2);"></span>
              <span style="position: absolute; content: ''; height: 20px; width: 20px; left: ${recipient.enabled ? '25px' : '3px'}; bottom: 3px; background-color: white; transition: 0.3s; border-radius: 50%; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);"></span>
            </label>
            <div style="flex: 1;">
              <input type="text" class="recipient-label" data-index="${index}" value="${recipient.label || ''}" placeholder="Label (e.g., Admin, HR)" style="width: 100%; padding: 6px 10px; background: rgba(15, 23, 42, 0.5); border: 1px solid rgba(71, 85, 105, 0.3); border-radius: 6px; color: #e2e8f0; font-size: 12px; font-weight: 600; margin-bottom: 6px;">
              <input type="email" class="recipient-email" data-index="${index}" value="${recipient.email}" placeholder="email@example.com" style="width: 100%; padding: 6px 10px; background: rgba(15, 23, 42, 0.5); border: 1px solid rgba(71, 85, 105, 0.3); border-radius: 6px; color: #94a3b8; font-size: 12px; font-family: monospace; margin-bottom: 10px;">
              
              <!-- Email Type Checkboxes -->
              <div style="display: flex; flex-direction: column; gap: 6px; padding: 10px; background: rgba(15, 23, 42, 0.3); border-radius: 6px; border: 1px solid rgba(71, 85, 105, 0.2);">
                <div style="font-size: 11px; font-weight: 700; color: #94a3b8; margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.5px;">Receive Copies Of:</div>
                
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 4px; border-radius: 4px; transition: background 0.2s;" onmouseover="this.style.background='rgba(71,85,105,0.2)'" onmouseout="this.style.background='transparent'">
                  <input type="checkbox" class="email-type-checkbox" data-index="${index}" data-type="applicationSubmission" ${emailTypes.applicationSubmission ? 'checked' : ''} style="width: 16px; height: 16px; cursor: pointer; accent-color: #10b981;">
                  <span style="font-size: 12px; color: #cbd5e1; flex: 1;">📝 Application Submissions</span>
                </label>
                
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 4px; border-radius: 4px; transition: background 0.2s;" onmouseover="this.style.background='rgba(71,85,105,0.2)'" onmouseout="this.style.background='transparent'">
                  <input type="checkbox" class="email-type-checkbox" data-index="${index}" data-type="statusChange" ${emailTypes.statusChange ? 'checked' : ''} style="width: 16px; height: 16px; cursor: pointer; accent-color: #10b981;">
                  <span style="font-size: 12px; color: #cbd5e1; flex: 1;">📋 Status Changes</span>
                </label>
                
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 4px; border-radius: 4px; transition: background 0.2s;" onmouseover="this.style.background='rgba(71,85,105,0.2)'" onmouseout="this.style.background='transparent'">
                  <input type="checkbox" class="email-type-checkbox" data-index="${index}" data-type="passwordReset" ${emailTypes.passwordReset ? 'checked' : ''} style="width: 16px; height: 16px; cursor: pointer; accent-color: #10b981;">
                  <span style="font-size: 12px; color: #cbd5e1; flex: 1;">🔐 Password Resets</span>
                </label>
              </div>
            </div>
            <button class="delete-recipient-btn" data-index="${index}" style="width: 32px; height: 32px; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); border-radius: 6px; color: #f87171; font-size: 16px; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; padding: 0; flex-shrink: 0;">🗑️</button>
          </div>
        </div>
      `;
    }
    
    // Render all recipients
    function renderBccRecipients() {
      const recipients = getBccRecipients();
      if (bccRecipientsList) {
        bccRecipientsList.innerHTML = recipients.map((r, i) => createRecipientCard(r, i)).join('');
        attachRecipientEventListeners();
      }
    }
    
    // Attach event listeners to recipient cards
    function attachRecipientEventListeners() {
      const recipients = getBccRecipients();
      
      // Toggle switches
      document.querySelectorAll('.recipient-toggle').forEach(toggle => {
        toggle.addEventListener('change', function() {
          const index = parseInt(this.dataset.index);
          recipients[index].enabled = this.checked;
          saveBccRecipients(recipients);
          showNotification(this.checked ? '✅ Recipient enabled' : '🔕 Recipient disabled');
          renderBccRecipients(); // Re-render to update toggle color
        });
      });
      
      // Email type checkboxes
      document.querySelectorAll('.email-type-checkbox').forEach(checkbox => {
        checkbox.addEventListener('change', function() {
          const index = parseInt(this.dataset.index);
          const type = this.dataset.type;
          
          // Ensure emailTypes object exists
          if (!recipients[index].emailTypes) {
            recipients[index].emailTypes = {
              applicationSubmission: true,
              statusChange: true,
              passwordReset: true
            };
          }
          
          recipients[index].emailTypes[type] = this.checked;
          saveBccRecipients(recipients);
          
          const typeNames = {
            applicationSubmission: 'Application Submissions',
            statusChange: 'Status Changes',
            passwordReset: 'Password Resets'
          };
          
          showNotification(
            this.checked 
              ? `✅ ${typeNames[type]} enabled` 
              : `🔕 ${typeNames[type]} disabled`
          );
        });
      });
      
      // Email inputs
      document.querySelectorAll('.recipient-email').forEach(input => {
        input.addEventListener('blur', function() {
          const index = parseInt(this.dataset.index);
          const email = this.value.trim();
          if (email && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            recipients[index].email = email;
            saveBccRecipients(recipients);
            showNotification('💾 Email updated');
          } else if (email) {
            showNotification('❌ Invalid email format', true);
            this.value = recipients[index].email; // Revert to saved value
          }
        });
      });
      
      // Label inputs
      document.querySelectorAll('.recipient-label').forEach(input => {
        input.addEventListener('blur', function() {
          const index = parseInt(this.dataset.index);
          recipients[index].label = this.value.trim();
          saveBccRecipients(recipients);
        });
      });
      
      // Delete buttons
      document.querySelectorAll('.delete-recipient-btn').forEach(btn => {
        btn.addEventListener('click', function() {
          const index = parseInt(this.dataset.index);
          if (confirm(`Remove ${recipients[index].email} from BCC recipients?`)) {
            recipients.splice(index, 1);
            saveBccRecipients(recipients);
            renderBccRecipients();
            showNotification('🗑️ Recipient removed');
          }
        });
        
        btn.addEventListener('mouseenter', function() {
          this.style.background = 'rgba(239, 68, 68, 0.2)';
          this.style.transform = 'scale(1.05)';
        });
        
        btn.addEventListener('mouseleave', function() {
          this.style.background = 'rgba(239, 68, 68, 0.1)';
          this.style.transform = 'scale(1)';
        });
      });
    }
    
    // Add new recipient
    if (addBccRecipientBtn) {
      addBccRecipientBtn.addEventListener('click', function() {
        const recipients = getBccRecipients();
        recipients.push({
          email: '',
          enabled: true,
          label: 'New Recipient',
          emailTypes: {
            applicationSubmission: true,
            statusChange: true,
            passwordReset: true
          }
        });
        saveBccRecipients(recipients);
        renderBccRecipients();
        showNotification('➕ New recipient added');
        
        // Focus on the new email input
        setTimeout(() => {
          const emailInputs = document.querySelectorAll('.recipient-email');
          if (emailInputs.length > 0) {
            emailInputs[emailInputs.length - 1].focus();
          }
        }, 100);
      });
      
      addBccRecipientBtn.addEventListener('mouseenter', function() {
        this.style.background = 'rgba(99, 102, 241, 0.15)';
        this.style.borderColor = 'rgba(99, 102, 241, 0.5)';
        this.style.transform = 'translateY(-1px)';
      });
      
      addBccRecipientBtn.addEventListener('mouseleave', function() {
        this.style.background = 'rgba(99, 102, 241, 0.1)';
        this.style.borderColor = 'rgba(99, 102, 241, 0.3)';
        this.style.transform = 'translateY(0)';
      });
    }
    
    // Show notification helper
    function showNotification(message, isError = false) {
      const notification = document.createElement('div');
      notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${isError ? 'linear-gradient(135deg, #ef4444, #dc2626)' : 'linear-gradient(135deg, #10b981, #059669)'};
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        box-shadow: 0 4px 12px ${isError ? 'rgba(239, 68, 68, 0.3)' : 'rgba(16, 185, 129, 0.3)'};
        z-index: 10001;
        animation: slideInRight 0.3s ease;
      `;
      notification.textContent = message;
      document.body.appendChild(notification);
      
      setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => notification.remove(), 300);
      }, 2500);
    }
    
    // Open settings modal
    if (settingsMenuItem) {
      settingsMenuItem.addEventListener('click', function(e) {
        e.preventDefault();
        if (settingsModal) {
          settingsModal.style.display = 'flex';
          renderBccRecipients(); // Load and render recipients
        }
        // Close mobile menu if open
        if (window.innerWidth <= 768) {
          sidebar.classList.remove('mobile-open');
          overlay.classList.remove('show');
        }
      });
    }
    
    // Close settings modal
    function hideSettingsModal() {
      if (settingsModal) settingsModal.style.display = 'none';
    }
    
    if (closeSettingsModal) {
      closeSettingsModal.addEventListener('click', hideSettingsModal);
      closeSettingsModal.addEventListener('mouseenter', function() {
        this.style.transform = 'rotate(90deg)';
        this.style.background = 'rgba(71, 85, 105, 0.5)';
      });
      closeSettingsModal.addEventListener('mouseleave', function() {
        this.style.transform = 'rotate(0deg)';
        this.style.background = 'rgba(15, 23, 42, 0.5)';
      });
    }
    
    // Close on backdrop click
    if (settingsModal) {
      settingsModal.addEventListener('click', function(e) {
        if (e.target === settingsModal) hideSettingsModal();
      });
    }
    
    // Add CSS animation styles if not present
    if (!document.getElementById('sidebarAnimationStyles')) {
      const style = document.createElement('style');
      style.id = 'sidebarAnimationStyles';
      style.textContent = `
        @keyframes slideInRight {
          from { transform: translateX(400px); opacity: 0; }
          to { transform: translateX(0); opacity: 1; }
        }
        @keyframes slideOutRight {
          from { transform: translateX(0); opacity: 1; }
          to { transform: translateX(400px); opacity: 0; }
        }
        .nav-badge {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          min-width: 18px;
          height: 18px;
          padding: 0 5px;
          border-radius: 9px;
          background: #ef4444;
          color: #fff;
          font-size: 11px;
          font-weight: 700;
          line-height: 1;
          margin-left: auto;
          flex-shrink: 0;
          box-shadow: 0 2px 6px rgba(239,68,68,0.45);
        }
      `;
      document.head.appendChild(style);
    }
  }

  /* ============================================================
     FORMS BADGE — unread submission count
     ============================================================ */
  function initFormsBadge() {
    const currentPage = window.location.pathname.split('/').pop();

    if (currentPage === 'admin-forms.html') {
      // Mark seen and hide badge
      localStorage.setItem('formsLastSeen', new Date().toISOString());
      const badge = document.getElementById('formsNavBadge');
      if (badge) badge.style.display = 'none';
      return;
    }

    // Fetch count on other pages, then poll every 60 s
    fetchFormsBadgeCount();
    setInterval(fetchFormsBadgeCount, 60000);
  }

  async function fetchFormsBadgeCount() {
    try {
      if (typeof initSupabase !== 'function') return;
      const sbClient = initSupabase();
      if (!sbClient) return;

      const lastSeen = localStorage.getItem('formsLastSeen');
      let query = sbClient
        .from('student_form_submissions')
        .select('id', { count: 'exact', head: true });

      if (lastSeen) {
        query = query.gt('submitted_at', lastSeen);
      }

      const { count, error } = await query;
      if (error) return;

      const badge = document.getElementById('formsNavBadge');
      if (!badge) return;

      if (count && count > 0) {
        badge.textContent = count > 99 ? '99+' : String(count);
        badge.style.display = 'inline-flex';
      } else {
        badge.style.display = 'none';
      }
    } catch(e) {
      console.warn('Forms badge fetch failed:', e);
    }
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
