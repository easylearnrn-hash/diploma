# ACNHS Analytics Admin Guide

## Overview

The **Analytics** page (`admin-analytics.html`) provides the ACNHS admin team with a live dashboard of website traffic, user engagement, conversion events, and content performance — all styled within the existing admin hub.

**Access:** Admin Hub → 📈 Analytics (visible to: `hrachfilm@gmail.com`, `s.gharibyan@acnhs.am`)

---

## GA4 Measurement ID

| Property | Value |
|---|---|
| Measurement ID | `G-0DJ1793XW8` |
| Platform | Google Analytics 4 |
| Config file | `js/analytics-config.js` |

The ID is embedded in these pages:
- `admission-form.html`
- `login.html`
- `contact.html`
- `teacher.html`
- `acceptance-letter.html`
- `Student-page.html`
- `about.html`
- `hub.html`
- `index.html`

To add GA4 to a new page, paste this into `<head>` (after the favicon tags):
```html
<!-- GA4 — Armenian College of Nursing & Health Sciences -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-0DJ1793XW8"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-0DJ1793XW8', { anonymize_ip: true });
</script>
```

---

## Phase 1 — Looker Studio Embed

> ⚠️ **Required account:** All Looker Studio steps must be performed while signed in as **acnhs.2026@gmail.com** — report creation, GA4 data source connection, and share settings.

### Setup (3 steps)

1. **Build the report** at [lookerstudio.google.com](https://lookerstudio.google.com) **signed in as `acnhs.2026@gmail.com`**
   - Connect your GA4 data source (`G-0DJ1793XW8`)
   - Add the date range control + charts you want
2. **Get the embed URL**
   - Share → Embed → copy the `src` URL from the `<iframe>` code
   - Set access to **"Anyone with the link can view"** (or restrict to `acnhs.2026@gmail.com`)
   - URL format: `https://lookerstudio.google.com/embed/reporting/<REPORT_ID>/page/<PAGE_ID>`
3. **Paste into the admin page**
   - Open Admin Hub → Analytics
   - Click **⚙️ Configure** in the Looker Studio section
   - Paste the URL → **💾 Save & Embed**
   - The URL is stored in `localStorage` under key `acnhs_looker_embed_url` and survives page refreshes

> If the embedded iframe shows an access error, open the report in Looker Studio under `acnhs.2026@gmail.com` and confirm the sharing settings are correct.

To clear an existing embed: click **⚙️ Configure** → **✕ Clear**.

---

## GA4 Key Events (Conversions)

These events are tracked as **GA4 Key Events** (previously called Conversions). Mark each one as a Key Event in the GA4 console: GA4 → Admin → Events → toggle "Mark as key event".

| Event name | Fires when | Parameters | File |
|---|---|---|---|
| `apply_now_click` | User clicks **Apply Now** in the site header | `button_location`, `page_path` | `js/site-chrome.js` |
| `apply_now_click` | Admission form submitted | `button_location: "admission_form"`, `form_step: "submit"` | `admission-form.html` |
| `login_submit` | Student/admin login form submitted | `method`, `role`, `page_path` | `login.html` |
| `login_submit` | Application status login submitted | `method: "application_credentials"`, `role: "applicant"` | `login.html` |
| `contact_submit` | Contact inquiry form submitted | `form_location`, `topic`, `page_path` | `contact.html` |
| `whatsapp_click` | WhatsApp link clicked | `phone_number`, `page_path` | `contact.html` |
| `call_click` | Phone call link clicked | `phone_number`, `page_path` | `contact.html` |

### Helper functions in `js/analytics-config.js`

```javascript
// Fire from any page that has GA4 loaded
ACNHS_ANALYTICS.trackApplyNowClick('hero_section');
ACNHS_ANALYTICS.trackRequestInfoClick('homepage');
ACNHS_ANALYTICS.trackLoginSubmit('email_password', 'student');
ACNHS_ANALYTICS.trackContactSubmit('Admissions');
ACNHS_ANALYTICS.trackCallClick('+17077174440');
ACNHS_ANALYTICS.trackWhatsAppClick('+37493798879');
```

### Adding a new tracked event

1. Fire the event inline or via `ACNHS_ANALYTICS.trackEvent()`:
   ```javascript
   // Inline (simplest)
   onclick="if(typeof gtag!=='undefined') gtag('event','my_event_name',{param:'value'})"

   // Via helper
   ACNHS_ANALYTICS.trackEvent('my_event_name', { param: 'value' });
   ```
2. If it's a conversion, add a helper method to `js/analytics-config.js` alongside `trackApplyNowClick`.
3. Add the event name to the conversions table in `admin-analytics.html` (search for `DEMO_CONV`).
4. Mark it as a Key Event in GA4 console.

---

## Date Range Filters

The analytics page has pre-built date range pills: **Today / 7 days / 28 days / 90 days / Custom**.

Currently all data shown is **demo data** (see `DEMO_KPI`, `DEMO_CONV`, `DEMO_CHANNELS`, `DEMO_TOP_PAGES` objects in `admin-analytics.html`). Once Phase 2 is live, these will be replaced by real GA4 Data API responses.

---

## Phase 2 — Native GA4 Data API (Upgrade Path)

Phase 2 replaces demo data with live GA4 Data API calls routed through a Supabase Edge Function to keep service account credentials server-side.

### Architecture

```
admin-analytics.html
  → POST /functions/v1/ga4-report
      → Google Analytics Data API v1
          (authenticates with service account JSON)
  ← JSON { rows, totals, ... }
```

### Steps to implement

1. **Create a Google Cloud service account**
   - Google Cloud Console → IAM → Service Accounts → Create
   - Role: `Viewer` on the GA4 property
   - Download JSON key file

2. **Create Supabase Edge Function** `supabase/functions/ga4-report/index.ts`
   ```typescript
   import { GoogleAuth } from 'google-auth-library';
   
   const GA4_PROPERTY_ID = 'properties/YOUR_PROPERTY_ID';
   
   Deno.serve(async (req) => {
     const { dateRange, metrics, dimensions } = await req.json();
     const auth = new GoogleAuth({
       credentials: JSON.parse(Deno.env.get('GA4_SERVICE_ACCOUNT_JSON')!),
       scopes: ['https://www.googleapis.com/auth/analytics.readonly']
     });
     const client = await auth.getClient();
     const token = await client.getAccessToken();
     
     const response = await fetch(
       `https://analyticsdata.googleapis.com/v1beta/${GA4_PROPERTY_ID}:runReport`,
       {
         method: 'POST',
         headers: { Authorization: `Bearer ${token.token}`, 'Content-Type': 'application/json' },
         body: JSON.stringify({ dateRanges: [dateRange], metrics, dimensions })
       }
     );
     
     const data = await response.json();
     return new Response(JSON.stringify(data), { headers: { 'Content-Type': 'application/json' } });
   });
   ```

3. **Deploy and set secrets**
   ```bash
   supabase functions deploy ga4-report
   supabase secrets set GA4_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
   ```

4. **Wire into `admin-analytics.html`**
   - Replace the `DEMO_KPI` / `DEMO_CONV` references in `refreshData()` with a `fetch()` call to `/functions/v1/ga4-report`
   - The Phase 2 panel in the page already lists the API calls needed

### GA4 Property ID

Find it at: GA4 → Admin → Property Settings → Property ID (numeric, e.g. `123456789`).  
Use as `properties/123456789` in all API calls.

---

## Adding New KPI Cards

In `admin-analytics.html`, find the `DEMO_KPI` object and `renderKPIs(range)` function:

```javascript
// 1. Add demo data
const DEMO_KPI = {
  '7d': [
    // ... existing cards ...
    { icon:'🆕', label:'My New Metric', value:'42', trend:'+5%', up:true, sub:'description' },
  ],
  // repeat for '28d', '90d', 'today'
};

// 2. The renderKPIs() function automatically creates a card for each entry — no HTML changes needed.
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Analytics sidebar item missing | `userEmail` not in `allowedEmails` | Add email to the Analytics item in `js/admin-sidebar.js` |
| Looker embed shows "refused to connect" | Looker Studio report isn't set to "Anyone with the link can view" | Share settings → Public access on |
| GA4 events not appearing | `gtag` not loaded on that page | Add GA4 script snippet to `<head>` (see above) |
| `apply_now_click` not firing | Page uses `site-chrome.js` header | Confirm `js/site-chrome.js` is loaded after the GA4 `<script>` block |
| Phase 2 API returns 403 | Service account not added to GA4 property | GA4 → Admin → Account Access Management → Add service account email |
