# Google Analytics 4 Setup Guide for ACNHS Website

## Overview
Comprehensive analytics tracking with GDPR/CCPA compliance has been implemented across the ACNHS website.

## What's Included

### ✅ Components Implemented
1. **Google Analytics 4 Tracking** - Core analytics platform with IP anonymization
2. **Custom Event Tracking** - Advanced tracking for user interactions
3. **Cookie Consent Banner** - GDPR/CCPA compliant consent management
4. **Privacy Policy** - Complete legal documentation
5. **Automatic Tracking** - Scroll depth, time on page, form submissions, external links

### 📂 Files Created
- `js/analytics-config.js` - Custom event tracking framework
- `js/cookie-consent.js` - Cookie consent management
- `css/cookie-consent.css` - Cookie banner styling
- `privacy-policy.html` - Privacy policy page

### 📄 Files Modified
- `index.html` - Added GA4 script, analytics config, cookie consent

---

## Setup Instructions

### Step 1: Create Google Analytics 4 Property

1. **Go to Google Analytics**: https://analytics.google.com/
2. **Create Account**:
   - Click "Admin" (gear icon, bottom left)
   - Click "+ Create Account"
   - Account name: "Armenian College of Nurses"
   - Uncheck all data sharing options (for privacy)

3. **Create Property**:
   - Property name: "ACNHS Website"
   - Reporting time zone: "(GMT+04:00) Yerevan" (Armenia)
   - Currency: "Armenian Dram (AMD)"
   - Click "Next"

4. **Business Details**:
   - Industry: "Education"
   - Business size: "Small" (1-10 employees)
   - Business objectives: Select relevant options
   - Click "Create"

5. **Data Collection**:
   - Platform: "Web"
   - Website URL: "https://acnhs.am"
   - Stream name: "ACNHS Main Site"
   - Click "Create stream"

6. **Get Measurement ID**:
   - You'll see a **Measurement ID** like: `G-ABC1234XYZ`
   - **COPY THIS ID** - you'll need it in Step 2

---

### Step 2: Replace Placeholder ID in Code

**Find and replace `G-XXXXXXXXXX` with your actual Measurement ID in these files:**

#### index.html (Line 9 and 14)
```html
<!-- BEFORE -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  gtag('config', 'G-XXXXXXXXXX', {

<!-- AFTER -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-ABC1234XYZ"></script>
<script>
  gtag('config', 'G-ABC1234XYZ', {
```

**Search command** (Terminal):
```bash
cd /path/to/DIPLOMA
grep -r "G-XXXXXXXXXX" .
```

Replace in all found files using VS Code find/replace:
- Find: `G-XXXXXXXXXX`
- Replace: `G-ABC1234XYZ` (your actual ID)

---

### Step 3: Deploy Analytics to Other Pages

**Add these lines to the `<head>` section of each HTML page:**

#### Pages to Update:
- `Student-page.html`
- `hub.html`
- `teacher.html`
- `admission-form.html`
- `about.html`
- `help-*.html` files
- Any other HTML pages

#### Code to Add (after `<meta>` tags, before CSS):
```html
<!-- Google Analytics 4 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-ABC1234XYZ"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-ABC1234XYZ', {
    'anonymize_ip': true,
    'cookie_flags': 'SameSite=None;Secure'
  });
</script>
```

#### CSS to Add (in `<head>`):
```html
<link rel="stylesheet" href="css/cookie-consent.css">
```

#### Scripts to Add (before `</body>`):
```html
<!-- Analytics & Cookie Consent -->
<script src="js/analytics-config.js"></script>
<script src="js/cookie-consent.js"></script>
```

---

### Step 4: Add Privacy Policy Link to Footer

**Add to footer of ALL pages:**
```html
<footer>
  <!-- Existing footer content -->
  <div class="footer-links">
    <a href="privacy-policy.html" target="_blank">Privacy Policy</a>
    <a href="#" onclick="CookieConsent.showPreferences(); return false;">Cookie Preferences</a>
  </div>
</footer>
```

---

### Step 5: Configure GA4 Dashboard

1. **Go to GA4 Admin** → **Data Display** → **Data Settings**
2. **Enable Google Signals**: Admin → Data Settings → Data Collection → Turn ON
3. **Set Up Demographics**: Admin → Property Settings → Demographics and interests reports → Enable

#### Create Custom Reports

**Recommended Reports**:

1. **Visitor Overview**:
   - Go to "Reports" → "Library" → "+ Create new report"
   - Metrics: Users, New Users, Sessions, Bounce Rate, Avg Session Duration
   - Dimensions: Country, City, Device Category, Browser

2. **Page Performance**:
   - Metrics: Page Views, Average Engagement Time, Exits
   - Dimensions: Page Title, Page Path, Landing Page

3. **Conversion Funnel**:
   - Go to "Explore" → "Blank"
   - Add segments: All Users → Application Started → Application Submitted → Application Approved
   - Visualize as Funnel

4. **Traffic Sources**:
   - Metrics: Users, Sessions, Conversions
   - Dimensions: Source/Medium, Campaign, Referrer

---

### Step 6: Set Up Conversion Goals

1. **Go to Admin** → **Events**
2. **Mark as Conversions**:
   - `form_submission` (Application submissions)
   - `button_click` (Apply Now clicks)
   - `file_download` (Document downloads)
   - `conversion` (Custom conversion events)

3. **Create Custom Events**:
   - Admin → Events → "Create event"
   - Name: `application_completed`
   - Conditions: `event_name = form_submission` AND `form_name = Admission Application`

---

### Step 7: Test Analytics

#### 1. Real-Time Testing
1. Open website: https://acnhs.am
2. GA4 Dashboard → "Reports" → "Realtime"
3. Should see 1 active user (you)
4. Click around, scroll, submit forms
5. Verify events appear in real-time

#### 2. Debug Mode
```html
<!-- Add to any page for detailed debugging -->
<script>
  gtag('config', 'G-ABC1234XYZ', {
    'debug_mode': true
  });
</script>
```
Then open Chrome DevTools → Console to see debug logs.

#### 3. GA4 DebugView
- GA4 Admin → "DebugView"
- Open website in Incognito/Private mode
- See live event stream with parameter details

#### 4. Cookie Consent Testing
1. Clear browser cookies: DevTools → Application → Cookies → Clear All
2. Refresh page
3. Cookie banner should appear at bottom
4. Test buttons:
   - "Accept All" → Should set consent and hide banner
   - "Reject Optional" → Should disable analytics tracking
   - "Manage Preferences" → Should open modal with checkboxes

5. Check localStorage:
   - DevTools → Application → Local Storage → acnhs.am
   - Should see: `acnhs_cookie_consent` and `acnhs_consent_date`

---

## Custom Event Tracking Usage

### Tracking Form Submissions
```javascript
// Automatically tracked for all forms
// Or manually track:
ACNHS_ANALYTICS.trackFormSubmission('Contact Form', {
  email: 'user@example.com',
  subject: 'Inquiry'
});
```

### Tracking Button Clicks
```javascript
ACNHS_ANALYTICS.trackButtonClick('Apply Now', 'Homepage Hero');
```

### Tracking Downloads
```javascript
ACNHS_ANALYTICS.trackDownload('Curriculum.pdf', 'PDF');
```

### Tracking Conversions
```javascript
ACNHS_ANALYTICS.trackConversion('Application Submitted', 'Admission Form');
```

### Tracking Errors
```javascript
ACNHS_ANALYTICS.trackError('Form Validation', 'Email field required');
```

---

## Data Privacy & Compliance

### IP Anonymization
✅ **Enabled** - Last octet of IP addresses removed before storage

### Cookie Consent
✅ **Implemented** - Users can accept/reject analytics cookies

### Data Retention
- **GA4 Data**: 14 months (configurable in GA4 settings)
- **User Preferences**: Stored in localStorage indefinitely
- **Server Logs**: 30 days (configured separately)

### User Rights
Users can:
- **View Privacy Policy**: `privacy-policy.html`
- **Manage Cookie Preferences**: Click footer link or banner button
- **Delete Their Data**: Contact privacy@acnhs.am

### GDPR/CCPA Compliance
- ✅ Cookie consent banner
- ✅ Privacy policy with retention schedules
- ✅ User opt-out mechanism
- ✅ Data access/deletion procedures
- ✅ IP anonymization

---

## Monitoring & Reports

### Daily Checks (5 minutes)
1. GA4 → Reports → Realtime (verify tracking is working)
2. Check for anomalies in user count
3. Monitor bounce rate (should be 40-60% for educational sites)

### Weekly Analysis (30 minutes)
1. **Traffic Report**:
   - Users, Sessions, New Users
   - Compare to previous week
   - Identify traffic sources

2. **Page Performance**:
   - Top pages by views
   - Pages with high exit rates
   - Average engagement time

3. **Conversion Funnel**:
   - Application start rate
   - Application completion rate
   - Drop-off points

### Monthly Reports (2 hours)
1. **Comprehensive Dashboard**:
   - Export PDF from GA4 → Reports → Snapshot
   - Include: Users, Sessions, Bounce Rate, Top Pages, Top Sources

2. **Insights**:
   - Geographic breakdown (Armenia vs. international)
   - Device usage (mobile vs. desktop)
   - Peak traffic times
   - Conversion rates

3. **Action Items**:
   - Optimize underperforming pages
   - Fix high exit pages
   - Improve conversion funnel bottlenecks

### CSV Export
GA4 → Explore → Create new exploration → Export → CSV

---

## Troubleshooting

### Issue: No data in GA4
**Solutions**:
1. Verify Measurement ID is correct in code
2. Check browser console for errors
3. Disable ad blockers
4. Wait 24-48 hours for data to populate
5. Use DebugView for real-time verification

### Issue: Cookie banner not appearing
**Solutions**:
1. Clear browser cookies and localStorage
2. Check browser console for JavaScript errors
3. Verify `cookie-consent.js` and `cookie-consent.css` are loaded
4. Check file paths are correct

### Issue: Events not tracking
**Solutions**:
1. Verify `analytics-config.js` is loaded after gtag
2. Check console for errors
3. Use `debug_mode: true` in GA4 config
4. Ensure user has accepted analytics cookies

### Issue: High bounce rate (>80%)
**Possible causes**:
1. Slow page load time
2. Poor mobile experience
3. Irrelevant traffic sources
4. Broken links or errors

**Solutions**:
- Optimize images and scripts
- Improve mobile responsiveness
- Review traffic sources and keywords
- Fix broken links

---

## Maintenance Tasks

### Monthly
- Review and update privacy policy if data practices change
- Check for GA4 updates or new features
- Review conversion goals and adjust if needed
- Analyze reports and create action items

### Quarterly
- Deep dive into user behavior analysis
- A/B test improvements based on analytics
- Review and optimize conversion funnels
- Update tracking for new features or pages

### Annually
- Comprehensive analytics audit
- Review data retention policies
- Update privacy policy review date
- Assess GA4 subscription plan (if upgraded from free tier)

---

## Support & Resources

### Documentation
- **Google Analytics 4**: https://support.google.com/analytics/answer/10089681
- **GA4 Event Reference**: https://developers.google.com/analytics/devguides/collection/ga4/events
- **GDPR Compliance**: https://support.google.com/analytics/answer/9019185

### ACNHS Contacts
- **Technical Issues**: info@acnhs.am
- **Privacy Questions**: privacy@acnhs.am
- **WhatsApp Support**: +374 93 79 88 79

### Quick Reference
- **GA4 Dashboard**: https://analytics.google.com/
- **Privacy Policy**: https://acnhs.am/privacy-policy.html
- **Cookie Preferences**: Footer link on any page

---

## Summary Checklist

Before going live, ensure:
- [ ] GA4 property created
- [ ] Measurement ID replaced in all files
- [ ] Analytics scripts added to all pages
- [ ] Cookie consent banner added to all pages
- [ ] Privacy policy linked in footer
- [ ] Conversion goals configured in GA4
- [ ] Real-time tracking tested
- [ ] Cookie consent tested
- [ ] Team trained on GA4 dashboard
- [ ] Monthly reporting schedule established

---

**Status**: ⏳ Awaiting GA4 Measurement ID from user to activate tracking

**Last Updated**: February 2026
