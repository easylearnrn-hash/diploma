/**
 * ACNHS Analytics Configuration
 * Google Analytics 4 + Custom Event Tracking
 * 
 * SETUP INSTRUCTIONS:
 * 1. Replace 'G-XXXXXXXXXX' with your actual GA4 Measurement ID
 * 2. Create GA4 property at: https://analytics.google.com/
 * 3. Add this measurement ID to all HTML pages
 * 4. Enable IP anonymization (already configured below)
 * 5. Set up custom reports in GA4 dashboard
 */

const ACNHS_ANALYTICS = {
  // Replace with your actual GA4 Measurement ID
  MEASUREMENT_ID: 'G-XXXXXXXXXX',
  
  // Track custom events
  trackEvent: function(eventName, eventParams = {}) {
    if (typeof gtag !== 'undefined') {
      gtag('event', eventName, {
        ...eventParams,
        page_path: window.location.pathname,
        page_title: document.title,
        timestamp: new Date().toISOString()
      });
    }
  },
  
  // Track form submissions
  trackFormSubmission: function(formName, formData = {}) {
    this.trackEvent('form_submission', {
      form_name: formName,
      ...formData
    });
  },
  
  // Track button clicks
  trackButtonClick: function(buttonName, buttonLocation = '') {
    this.trackEvent('button_click', {
      button_name: buttonName,
      button_location: buttonLocation
    });
  },
  
  // Track file downloads
  trackDownload: function(fileName, fileType = '') {
    this.trackEvent('file_download', {
      file_name: fileName,
      file_type: fileType
    });
  },
  
  // Track external link clicks
  trackExternalLink: function(url, linkText = '') {
    this.trackEvent('external_link_click', {
      link_url: url,
      link_text: linkText
    });
  },
  
  // Track video interactions
  trackVideo: function(action, videoName = '') {
    this.trackEvent('video_interaction', {
      video_action: action,
      video_name: videoName
    });
  },
  
  // Track user engagement (time on page)
  trackEngagement: function(timeSpent, scrollDepth) {
    this.trackEvent('user_engagement', {
      time_spent_seconds: timeSpent,
      scroll_depth_percent: scrollDepth
    });
  },
  
  // Track conversions (application submissions, payments)
  trackConversion: function(conversionType, conversionValue = '') {
    this.trackEvent('conversion', {
      conversion_type: conversionType,
      conversion_value: conversionValue
    });
  },
  
  // Track errors
  trackError: function(errorType, errorMessage = '') {
    this.trackEvent('error_occurred', {
      error_type: errorType,
      error_message: errorMessage
    });
  },
  
  // Track page view with custom data
  trackPageView: function(additionalData = {}) {
    this.trackEvent('page_view', {
      ...additionalData
    });
  },
  
  // Initialize analytics tracking
  init: function() {
    console.log('ACNHS Analytics initialized');
    
    // Track initial page load
    this.trackPageView({
      referrer: document.referrer,
      user_agent: navigator.userAgent,
      screen_resolution: `${screen.width}x${screen.height}`,
      viewport: `${window.innerWidth}x${window.innerHeight}`
    });
    
    // Track scroll depth
    this.initScrollTracking();
    
    // Track time on page
    this.initTimeTracking();
    
    // Track outbound links
    this.initOutboundLinkTracking();
    
    // Track form submissions
    this.initFormTracking();
  },
  
  // Initialize scroll depth tracking
  initScrollTracking: function() {
    let maxScroll = 0;
    let scrollCheckpoints = [25, 50, 75, 90, 100];
    let reachedCheckpoints = new Set();
    
    window.addEventListener('scroll', () => {
      const scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
      const scrollPercent = Math.round((window.scrollY / scrollHeight) * 100);
      
      if (scrollPercent > maxScroll) {
        maxScroll = scrollPercent;
      }
      
      scrollCheckpoints.forEach(checkpoint => {
        if (scrollPercent >= checkpoint && !reachedCheckpoints.has(checkpoint)) {
          reachedCheckpoints.add(checkpoint);
          this.trackEvent('scroll_depth', {
            scroll_percentage: checkpoint,
            page_path: window.location.pathname
          });
        }
      });
    });
    
    // Track final scroll on page exit
    window.addEventListener('beforeunload', () => {
      this.trackEvent('page_exit', {
        max_scroll_depth: maxScroll,
        time_on_page: Math.round((Date.now() - window.pageLoadTime) / 1000)
      });
    });
  },
  
  // Initialize time tracking
  initTimeTracking: function() {
    window.pageLoadTime = Date.now();
    
    // Track engagement every 30 seconds
    setInterval(() => {
      const timeSpent = Math.round((Date.now() - window.pageLoadTime) / 1000);
      const scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
      const scrollPercent = Math.round((window.scrollY / scrollHeight) * 100);
      
      this.trackEngagement(timeSpent, scrollPercent);
    }, 30000);
  },
  
  // Initialize outbound link tracking
  initOutboundLinkTracking: function() {
    document.addEventListener('click', (e) => {
      const link = e.target.closest('a');
      if (link && link.href) {
        const url = new URL(link.href, window.location.href);
        if (url.hostname !== window.location.hostname) {
          this.trackExternalLink(link.href, link.textContent.trim());
        }
      }
    });
  },
  
  // Initialize form tracking
  initFormTracking: function() {
    document.addEventListener('submit', (e) => {
      const form = e.target;
      if (form.tagName === 'FORM') {
        const formName = form.name || form.id || 'unnamed_form';
        const formData = {
          form_action: form.action,
          form_method: form.method
        };
        this.trackFormSubmission(formName, formData);
      }
    });
  }
};

// Initialize on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    ACNHS_ANALYTICS.init();
  });
} else {
  ACNHS_ANALYTICS.init();
}

// Make available globally
window.ACNHS_ANALYTICS = ACNHS_ANALYTICS;
