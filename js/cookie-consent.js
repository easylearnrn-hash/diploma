/**
 * ACNHS Cookie Consent Banner
 * GDPR/CCPA Compliant Cookie Consent Management
 */

const CookieConsent = {
  // Cookie consent preferences
  preferences: {
    essential: true, // Always required
    analytics: false,
    functional: false,
    marketing: false
  },
  
  // Check if consent has been given
  hasConsent: function() {
    return localStorage.getItem('acnhs_cookie_consent') !== null;
  },
  
  // Get saved preferences
  getPreferences: function() {
    const saved = localStorage.getItem('acnhs_cookie_consent');
    if (saved) {
      return JSON.parse(saved);
    }
    return this.preferences;
  },
  
  // Save preferences
  savePreferences: function(prefs) {
    this.preferences = prefs;
    localStorage.setItem('acnhs_cookie_consent', JSON.stringify(prefs));
    localStorage.setItem('acnhs_consent_date', new Date().toISOString());
    
    // Apply preferences
    this.applyPreferences();
  },
  
  // Apply cookie preferences
  applyPreferences: function() {
    const prefs = this.getPreferences();
    
    // Analytics cookies (Google Analytics)
    if (prefs.analytics) {
      this.enableAnalytics();
    } else {
      this.disableAnalytics();
    }
    
    // Trigger custom event for other scripts
    window.dispatchEvent(new CustomEvent('cookieConsentUpdated', {
      detail: prefs
    }));
  },
  
  // Enable Google Analytics
  enableAnalytics: function() {
    if (typeof gtag !== 'undefined') {
      gtag('consent', 'update', {
        'analytics_storage': 'granted'
      });
      console.log('Analytics cookies enabled');
    }
  },
  
  // Disable Google Analytics
  disableAnalytics: function() {
    if (typeof gtag !== 'undefined') {
      gtag('consent', 'update', {
        'analytics_storage': 'denied'
      });
      console.log('Analytics cookies disabled');
    }
  },
  
  // Accept all cookies
  acceptAll: function() {
    this.savePreferences({
      essential: true,
      analytics: true,
      functional: true,
      marketing: true
    });
    this.hideBanner();
  },
  
  // Reject optional cookies
  rejectOptional: function() {
    this.savePreferences({
      essential: true,
      analytics: false,
      functional: false,
      marketing: false
    });
    this.hideBanner();
  },
  
  // Show banner
  showBanner: function() {
    if (!this.hasConsent()) {
      const banner = document.getElementById('cookie-consent-banner');
      if (banner) {
        banner.style.display = 'block';
        setTimeout(() => {
          banner.classList.add('show');
        }, 100);
      }
    }
  },
  
  // Hide banner
  hideBanner: function() {
    const banner = document.getElementById('cookie-consent-banner');
    if (banner) {
      banner.classList.remove('show');
      setTimeout(() => {
        banner.style.display = 'none';
      }, 300);
    }
  },
  
  // Show preferences modal
  showPreferences: function() {
    const modal = document.getElementById('cookie-preferences-modal');
    if (modal) {
      modal.style.display = 'flex';
      setTimeout(() => {
        modal.classList.add('show');
      }, 10);
      
      // Load current preferences
      const prefs = this.getPreferences();
      document.getElementById('analytics-cookies').checked = prefs.analytics;
      document.getElementById('functional-cookies').checked = prefs.functional;
      document.getElementById('marketing-cookies').checked = prefs.marketing;
    }
  },
  
  // Hide preferences modal
  hidePreferences: function() {
    const modal = document.getElementById('cookie-preferences-modal');
    if (modal) {
      modal.classList.remove('show');
      setTimeout(() => {
        modal.style.display = 'none';
      }, 300);
    }
  },
  
  // Save custom preferences
  saveCustomPreferences: function() {
    const prefs = {
      essential: true,
      analytics: document.getElementById('analytics-cookies').checked,
      functional: document.getElementById('functional-cookies').checked,
      marketing: document.getElementById('marketing-cookies').checked
    };
    this.savePreferences(prefs);
    this.hidePreferences();
    this.hideBanner();
  },
  
  // Initialize
  init: function() {
    // Create banner HTML if it doesn't exist
    if (!document.getElementById('cookie-consent-banner')) {
      this.createBanner();
      this.createPreferencesModal();
    }
    
    // Show banner if no consent
    if (!this.hasConsent()) {
      this.showBanner();
    } else {
      // Apply saved preferences
      this.applyPreferences();
    }
    
    // Set up event listeners
    this.setupEventListeners();
  },
  
  // Create banner HTML
  createBanner: function() {
    const banner = document.createElement('div');
    banner.id = 'cookie-consent-banner';
    banner.innerHTML = `
      <div class="cookie-banner-content">
        <div class="cookie-banner-text">
          <h3>We Use Cookies</h3>
          <p>We use cookies and similar technologies to improve your experience, analyze traffic, and personalize content. By clicking "Accept All," you consent to our use of cookies.</p>
          <a href="privacy-policy.html" target="_blank">Privacy Policy</a>
        </div>
        <div class="cookie-banner-actions">
          <button onclick="CookieConsent.showPreferences()" class="btn-preferences">Manage Preferences</button>
          <button onclick="CookieConsent.rejectOptional()" class="btn-reject">Reject Optional</button>
          <button onclick="CookieConsent.acceptAll()" class="btn-accept">Accept All</button>
        </div>
      </div>
    `;
    document.body.appendChild(banner);
  },
  
  // Create preferences modal
  createPreferencesModal: function() {
    const modal = document.createElement('div');
    modal.id = 'cookie-preferences-modal';
    modal.innerHTML = `
      <div class="cookie-modal-content">
        <div class="cookie-modal-header">
          <h2>Cookie Preferences</h2>
          <button onclick="CookieConsent.hidePreferences()" class="modal-close">&times;</button>
        </div>
        <div class="cookie-modal-body">
          <p>We use different types of cookies to optimize your experience on our website. Choose which cookies you want to allow:</p>
          
          <div class="cookie-category">
            <div class="cookie-category-header">
              <input type="checkbox" id="essential-cookies" checked disabled>
              <label for="essential-cookies">
                <strong>Essential Cookies</strong>
                <span class="required-badge">Required</span>
              </label>
            </div>
            <p class="cookie-category-desc">These cookies are necessary for the website to function and cannot be disabled. They enable core functionality such as security, authentication, and accessibility.</p>
          </div>
          
          <div class="cookie-category">
            <div class="cookie-category-header">
              <input type="checkbox" id="analytics-cookies">
              <label for="analytics-cookies">
                <strong>Analytics Cookies</strong>
              </label>
            </div>
            <p class="cookie-category-desc">These cookies help us understand how visitors interact with our website by collecting and reporting information anonymously. We use Google Analytics with IP anonymization enabled.</p>
          </div>
          
          <div class="cookie-category">
            <div class="cookie-category-header">
              <input type="checkbox" id="functional-cookies">
              <label for="functional-cookies">
                <strong>Functional Cookies</strong>
              </label>
            </div>
            <p class="cookie-category-desc">These cookies enable enhanced functionality and personalization, such as remembering your preferences and settings.</p>
          </div>
          
          <div class="cookie-category">
            <div class="cookie-category-header">
              <input type="checkbox" id="marketing-cookies">
              <label for="marketing-cookies">
                <strong>Marketing Cookies</strong>
              </label>
            </div>
            <p class="cookie-category-desc">These cookies may be set by our advertising partners to build a profile of your interests and show you relevant ads on other sites.</p>
          </div>
        </div>
        <div class="cookie-modal-footer">
          <button onclick="CookieConsent.saveCustomPreferences()" class="btn-save">Save Preferences</button>
          <button onclick="CookieConsent.acceptAll()" class="btn-accept-all">Accept All</button>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
  },
  
  // Setup event listeners
  setupEventListeners: function() {
    // Close modal on outside click
    const modal = document.getElementById('cookie-preferences-modal');
    if (modal) {
      modal.addEventListener('click', (e) => {
        if (e.target === modal) {
          this.hidePreferences();
        }
      });
    }
  }
};

// Auto-initialize on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    CookieConsent.init();
  });
} else {
  CookieConsent.init();
}

// Make available globally
window.CookieConsent = CookieConsent;
