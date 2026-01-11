// Permission Check - Page Level Access Control
// Include this script in admin pages that require specific permissions

(function() {
  'use strict';

  // Check if user has a specific permission
  function hasPermission(permissionKey) {
    try {
      const permissionsStr = sessionStorage.getItem('userPermissions') || localStorage.getItem('userPermissions');
      const permissions = permissionsStr ? JSON.parse(permissionsStr) : null;
      
      if (!permissions) {
        // If no permissions found, check if user is main admin
        const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail');
        const ADMIN_EMAILS = ['Hrachfilm@gmail.com', 'hrachfilm@gmail.com'];
        return ADMIN_EMAILS.some(email => email.toLowerCase() === userEmail?.toLowerCase());
      }
      
      return permissions[permissionKey] === true;
    } catch (e) {
      console.error('Error checking permissions:', e);
      return false;
    }
  }

  // Check if user is main admin (bypass all restrictions)
  function isMainAdmin() {
    const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail');
    const ADMIN_EMAILS = ['Hrachfilm@gmail.com', 'hrachfilm@gmail.com'];
    return ADMIN_EMAILS.some(email => email.toLowerCase() === userEmail?.toLowerCase());
  }

  // Define page permissions
  const pagePermissions = {
    'admin-applications.html': 'view_applications',
    'email-system.html': 'send_emails',
    'admin-users.html': 'manage_users',
    'help-grading.html': 'view_reports',
    'help-appeals.html': 'edit_applications',
    'verify-transcript.html': 'view_applications',
    'help-handbook.html': 'view_applications'
  };

  // Check page access on load
  function checkPageAccess() {
    const currentPage = window.location.pathname.split('/').pop();
    const requiredPermission = pagePermissions[currentPage];

    // If page doesn't require specific permission or user is main admin, allow access
    if (!requiredPermission || isMainAdmin()) {
      return true;
    }

    // Check if user has the required permission
    if (!hasPermission(requiredPermission)) {
      console.warn('⛔ Access denied: Missing permission', requiredPermission);
      
      // Show access denied message
      document.body.innerHTML = `
        <div style="display: flex; align-items: center; justify-content: center; min-height: 100vh; background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); font-family: 'Segoe UI', sans-serif;">
          <div style="text-align: center; max-width: 500px; padding: 40px; background: rgba(255,255,255,0.05); border-radius: 20px; border: 1px solid rgba(255,255,255,0.1);">
            <div style="font-size: 64px; margin-bottom: 20px;">🚫</div>
            <h1 style="color: #f87171; font-size: 28px; margin-bottom: 16px;">Access Denied</h1>
            <p style="color: #94a3b8; font-size: 16px; margin-bottom: 32px;">
              You don't have permission to access this page.
            </p>
            <a href="admin-home.html" style="display: inline-block; background: linear-gradient(135deg, #2dd4bf, #14b8a6); color: white; padding: 14px 32px; border-radius: 12px; text-decoration: none; font-weight: 600; transition: transform 0.2s;">
              ← Back to Dashboard
            </a>
          </div>
        </div>
      `;
      
      return false;
    }

    return true;
  }

  // Run check when DOM is loaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', checkPageAccess);
  } else {
    checkPageAccess();
  }

  // Export functions for use by other scripts
  window.hasPermission = hasPermission;
  window.isMainAdmin = isMainAdmin;

})();
