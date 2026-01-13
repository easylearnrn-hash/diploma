/**
 * BCC Utilities for Email System
 * Shared helper functions to get BCC recipients based on email type
 */

(function(window) {
  'use strict';

  /**
   * Get BCC email addresses for a specific email type
   * @param {string} emailType - One of: 'applicationSubmission', 'statusChange', 'passwordReset'
   * @returns {string|null} Comma-separated email addresses or null if none
   */
  function getBccEmailsByType(emailType) {
    try {
      const recipients = JSON.parse(localStorage.getItem('bccRecipients') || '[]');
      
      // Filter to only enabled recipients with valid emails who want this email type
      const enabledEmails = recipients
        .filter(r => {
          // Must be enabled and have valid email
          if (!r.enabled || !r.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(r.email)) {
            return false;
          }
          
          // Check if they want this specific email type (default to true for backwards compatibility)
          const emailTypes = r.emailTypes || {
            applicationSubmission: true,
            statusChange: true,
            passwordReset: true
          };
          
          return emailTypes[emailType] !== false;
        })
        .map(r => r.email);
      
      const result = enabledEmails.length > 0 ? enabledEmails.join(',') : null;
      console.log(`📧 BCC Recipients for ${emailType}:`, result || 'None');
      return result;
      
    } catch (e) {
      console.error('Error loading BCC recipients:', e);
      
      // Fallback to old setting for backwards compatibility
      if (emailType === 'applicationSubmission') {
        return localStorage.getItem('bccApplicationEmails') !== 'false' ? 'hrachfilm@gmail.com' : null;
      }
      
      // For other email types, default to hrachfilm@gmail.com if old setting was enabled
      return localStorage.getItem('bccApplicationEmails') !== 'false' ? 'hrachfilm@gmail.com' : null;
    }
  }

  /**
   * Get all BCC recipients (regardless of email type filters)
   * Useful for admin display purposes
   */
  function getAllBccRecipients() {
    try {
      return JSON.parse(localStorage.getItem('bccRecipients') || '[]');
    } catch (e) {
      console.error('Error loading BCC recipients:', e);
      return [];
    }
  }

  /**
   * Get count of enabled recipients for a specific email type
   */
  function getEnabledCount(emailType) {
    const emails = getBccEmailsByType(emailType);
    return emails ? emails.split(',').length : 0;
  }

  // Export to global scope
  window.BccUtils = {
    getBccEmailsByType,
    getAllBccRecipients,
    getEnabledCount
  };

})(window);
