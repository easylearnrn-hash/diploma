# Analytics Deployment Checklist

## Quick Start (5 Steps to Go Live)

### 1. Get Your Google Analytics ID
- Go to https://analytics.google.com/
- Create GA4 property for "ACNHS Website"
- Copy Measurement ID (format: `G-ABC1234XYZ`)

### 2. Replace Placeholder ID
Search and replace in ALL files:
- **Find**: `G-XXXXXXXXXX`
- **Replace**: `G-ABC1234XYZ` (your actual ID)

**Terminal command**:
```bash
cd /Users/richyf/Library/Mobile\ Documents/com~apple~CloudDocs/DIPLOMA
find . -name "*.html" -exec sed -i '' 's/G-XXXXXXXXXX/G-ABC1234XYZ/g' {} +
```

### 3. Add Analytics to Remaining Pages

**Pages needing update**:
- [ ] Student-page.html
- [ ] hub.html
- [ ] teacher.html
- [ ] admission-form.html
- [ ] about.html
- [ ] All help-*.html pages
- [ ] acceptance-letter.html
- [ ] verify-transcript.html

**Add to `<head>` of each page**:
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

<!-- Cookie Consent CSS -->
<link rel="stylesheet" href="css/cookie-consent.css">
```

**Add before `</body>` of each page**:
```html
<!-- Analytics & Cookie Consent -->
<script src="js/analytics-config.js"></script>
<script src="js/cookie-consent.js"></script>
```

### 4. Add Privacy Policy Links

**Add to footer of ALL pages**:
```html
<div class="footer-links">
  <a href="privacy-policy.html" target="_blank">Privacy Policy</a>
  <a href="#" onclick="CookieConsent.showPreferences(); return false;">Cookie Preferences</a>
</div>
```

### 5. Test Everything

**Cookie Consent Test**:
1. Open https://acnhs.am in Incognito
2. Cookie banner should appear at bottom
3. Click "Accept All" → Banner disappears
4. Reload → Banner should NOT appear (consent saved)

**Analytics Tracking Test**:
1. Go to GA4 → Reports → Realtime
2. Navigate website pages
3. Should see yourself as active user
4. Events should appear (page_view, scroll, etc.)

**Privacy Policy Test**:
1. Click footer "Privacy Policy" link
2. Page should load: `privacy-policy.html`
3. All sections should be readable and styled

---

## Current Status

### ✅ Completed
- [x] GA4 script added to index.html
- [x] Custom analytics framework created (analytics-config.js)
- [x] Cookie consent banner created (cookie-consent.js)
- [x] Cookie consent styling created (cookie-consent.css)
- [x] Privacy policy page created (privacy-policy.html)
- [x] Setup documentation written (ANALYTICS-SETUP-GUIDE.md)

### ⏳ Pending
- [ ] **GET GA4 MEASUREMENT ID** ← **DO THIS FIRST**
- [ ] Replace `G-XXXXXXXXXX` with actual ID
- [ ] Deploy analytics to remaining 15+ pages
- [ ] Add privacy policy links to all footers
- [ ] Configure GA4 conversion goals
- [ ] Test tracking across all pages
- [ ] Train team on GA4 dashboard

---

## Files Created/Modified

### New Files
- `js/analytics-config.js` - Custom event tracking (213 lines)
- `js/cookie-consent.js` - Cookie consent management (329 lines)
- `css/cookie-consent.css` - Cookie banner styles (378 lines)
- `privacy-policy.html` - Privacy policy page (472 lines)
- `ANALYTICS-SETUP-GUIDE.md` - Complete setup guide (400+ lines)
- `ANALYTICS-DEPLOYMENT-CHECKLIST.md` - This file

### Modified Files
- `index.html` - Added GA4 + analytics scripts

---

## Quick Commands

### Find all HTML files
```bash
find . -name "*.html" -not -path "./node_modules/*"
```

### Search for placeholder ID
```bash
grep -r "G-XXXXXXXXXX" . --include="*.html"
```

### Replace placeholder in all files (macOS)
```bash
find . -name "*.html" -exec sed -i '' 's/G-XXXXXXXXXX/G-YOUR-ACTUAL-ID/g' {} +
```

### Replace placeholder in all files (Linux)
```bash
find . -name "*.html" -exec sed -i 's/G-XXXXXXXXXX/G-YOUR-ACTUAL-ID/g' {} +
```

### Start local server for testing
```bash
python3 start-server.py
# Then open: http://localhost:8000
```

---

## Next Steps Priority

1. **URGENT**: Get GA4 Measurement ID (5 minutes)
2. **HIGH**: Replace placeholder ID in all files (2 minutes)
3. **HIGH**: Deploy to Student-page.html, hub.html, teacher.html (30 minutes)
4. **MEDIUM**: Deploy to remaining pages (1 hour)
5. **MEDIUM**: Add footer links to all pages (30 minutes)
6. **LOW**: Configure GA4 goals and reports (30 minutes)
7. **LOW**: Test and verify tracking (15 minutes)

---

## Support

### Documentation
- **Full Setup Guide**: `ANALYTICS-SETUP-GUIDE.md`
- **Privacy Policy**: `privacy-policy.html`

### Google Resources
- **GA4 Setup**: https://support.google.com/analytics/answer/9304153
- **Event Tracking**: https://developers.google.com/analytics/devguides/collection/ga4/events

### ACNHS Contacts
- **Technical**: info@acnhs.am
- **Privacy**: privacy@acnhs.am
- **WhatsApp**: +374 93 79 88 79

---

**Estimated Time to Complete**: 2-3 hours
**Status**: 40% Complete - Awaiting GA4 Measurement ID
