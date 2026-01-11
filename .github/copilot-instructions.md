# Armenian College of Nurses - Diploma Project AI Instructions

## Project Overview
**Stack:** Vanilla HTML/CSS/JS with Supabase backend, Twilio SMS, Resend email  
**Purpose:** Student admission system with admin dashboard, QR verification, and document management  
**Key Constraint:** No build tools - pure static HTML served via Python SimpleHTTPServer

## Architecture & Data Flow

### Core Components
1. **Public Forms** (`admission-form.html`, `login.html`) → Supabase `applications` & `registrations` tables
2. **Admin Dashboard** (`admin-home.html`, `admin-applications.html`) → Reads/updates via Supabase client
3. **Serverless Backend** (`supabase/functions/`) → Twilio SMS, Resend email via Edge Functions
4. **Verification System** (`verify-transcript.html`) → QR code lookup in `transcripts` table

### Database Schema (Supabase PostgreSQL)
**Critical tables** (see `supabase/schema.sql` for full DDL):
- `applications`: Student admissions with `document_id`, `control_number`, `verification_hash`, `username`, `password_hash`, `credentials_screenshot` (base64 image)
- `registrations`: Waiting list with `status` (pending/contacted/approved/rejected), `reminder_date`
- `students`: Approved applicants with `student_id` (TMP-xxxxxxx format), `application_id` FK
- `transcripts`: QR verification codes with cryptographic `verification_code` (4-char hex)
- `sms_verifications`, `sms_logs`: Phone verification codes and delivery tracking
- `email_history`: Outbound email audit trail

**RLS Policies:** Anonymous users can INSERT (forms) and SELECT (admin reads). UPDATE/DELETE allowed to `anon` for testing - **lock down in production** with `authenticated` role checks.

## Development Workflow

### Local Server Setup
```bash
python3 start-server.py  # Serves on localhost:8000
# OR
./quick-start.sh         # Auto-starts server + shows admin credentials
```
**Why Python server?** Fixes CORS/`file://` issues for html2pdf and iframe previews.

### Database Schema Changes
1. Write idempotent SQL in new `.sql` file (use `IF NOT EXISTS`, `DO $$` blocks)
2. Test in Supabase SQL Editor: https://supabase.com/dashboard → Project `zlvnxvrzotamhpezqedr`
3. Add migration guide in `<FEATURE>-SETUP.md` (see `CREDENTIALS-SCREENSHOT-SETUP.md`)
4. Update `supabase/schema.sql` master file

### Deploying Edge Functions
```bash
cd supabase/functions/<function-name>
# Edit index.ts, then:
supabase functions deploy <function-name>
```
**Secrets management:** Set via `supabase secrets set TWILIO_ACCOUNT_SID=...` (see `TWILIO-SMS-SETUP.md`)

## Code Conventions

### Authentication Pattern
Admin access is **email-based sessionStorage check**:
```javascript
const ADMIN_EMAILS = ['Hrachfilm@gmail.com', 'hrachfilm@gmail.com'];
const isAdmin = sessionStorage.getItem('isAdmin') === 'true';
if (!isAdmin) window.location.href = 'login.html';
```
Login sets `sessionStorage.setItem('isAdmin', 'true')` after email validation.

### Performance-Critical CSS
**Glassmorphism removed** from high-frequency renders (`backdrop-filter: blur()` causes GPU overload):
- Admin drawers/modals use `background: rgba(0,0,0,0.85)` instead of blur
- Enable OS "Reduce Motion" to disable remaining blurs via `@media (prefers-reduced-motion)`
- See `PERFORMANCE-OPTIMIZATIONS.md` for 50-70% GPU reduction strategies

### Barcode/QR Generation
```javascript
// Use caching to avoid redundant SVG generation
const barcodeCache = new Map();
if (!barcodeCache.has(cacheKey)) {
  JsBarcode(element, value, options);
  barcodeCache.set(cacheKey, true);
}
```

### Dynamic Library Loading
Heavy libraries (html2pdf ~500KB) loaded on-demand:
```javascript
async function loadScript(src) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = src; script.onload = resolve; script.onerror = reject;
    document.head.appendChild(script);
  });
}
// In print function:
if (typeof html2pdf === 'undefined') await loadScript('js/html2pdf.bundle.min.js');
```

### Supabase Client Initialization
```javascript
// Always use js/supabase-config.js singleton:
const supabase = initSupabase();
const { data, error } = await supabase.from('applications').select('*');
```
**Config:** `SUPABASE_CONFIG.url` and `anonKey` in `js/supabase-config.js`

## Common Pitfalls

### Missing Table Columns
Admission form detects missing DB columns (e.g., `credentials_screenshot`) and retries without them. Check console for `Column does not exist` errors → run relevant `ADD-<COLUMN>.sql` migration.

### Registrations Not Showing
**Root cause:** `registrations` table doesn't exist → Run `RUN-THIS-SQL-FIRST.md` or `SETUP-REGISTRATIONS-TABLE.md` in Supabase SQL Editor.

### PDF Generation Fails
Must run on `localhost:8000` (not `file://`) due to canvas tainting. Error modal guides users to `python3 start-server.py`.

### Edge Function Timeouts
SMS/email functions have 10s Supabase timeout. For debugging, check:
```bash
supabase functions logs send-sms --project-ref zlvnxvrzotamhpezqedr
```

## Key Files Reference
- `supabase/schema.sql` - Master database schema (582 lines)
- `js/supabase-config.js` - Supabase client singleton
- `css/admin-sidebar.css` - Shared admin UI component (include in all admin pages)
- `start-server.py` - Development server with CORS headers
- `WIRING-COMPLETE.md` - Data flow diagrams for applications/registrations
- `PERFORMANCE-OPTIMIZATIONS.md` - GPU/CPU optimization strategies
- `SMS-INTEGRATION-SUMMARY.md` - Twilio Edge Function setup
- `EMAIL-SYSTEM-SETUP.md` - Resend email configuration
