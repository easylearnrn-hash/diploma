# Acceptance Letter System - Complete Documentation

## Overview
The acceptance letter system uses **ONE SINGLE TEMPLATE** (`acceptance-letter.html`) that is populated with student data from multiple sources. This ensures consistency across admin panel and student portal.

## Architecture

### Single Source of Truth: `acceptance-letter.html`

**File:** `acceptance-letter.html`

**Purpose:** A standalone HTML document with:
- Static CSS styling (A4 page, watermarks, QR codes, security features)
- Hardcoded placeholder data (Ani Hakobyan's information - **for development/fallback only**)
- `data-field` attributes on all dynamic content spans
- JavaScript that reads data and calls `renderAcceptanceLetter(data)`

**Key Elements:**
```html
<span data-field="fullName">Ani Hakobyan</span>
<span data-field="dob">12 May 2007</span>
<span data-field="applicationId">APP-2026-418</span>
<!-- ... all other fields ... -->
```

### Data Flow Patterns

#### Pattern 1: Admin Panel → Iframe Display
**File:** `admin-student-page.html` → `loadAcceptanceLetter()` function

**Flow:**
1. Admin clicks "Acceptance Letter" tab for a student
2. `loadAcceptanceLetter()` function:
   - Fetches application data from Supabase
   - Extracts DOB using `getDobFromApplication()` helper (checks 13+ locations)
   - Builds `letterData` object with all student information
   - Fetches `acceptance-letter.html` template via `fetch()`
   - Injects `window.ACCEPTANCE_LETTER_DATA = {...}` into template's `<head>`
   - Loads modified template into an `<iframe>`
3. Template's JavaScript reads `window.ACCEPTANCE_LETTER_DATA`
4. Calls `renderAcceptanceLetter(data)` to replace all `data-field` spans

**Console Logs Added (Jan 2026):**
```javascript
console.log('[loadAcceptanceLetter] Current student:', currentStudent);
console.log('[loadAcceptanceLetter] Application data:', applicationData);
console.log('[loadAcceptanceLetter] Extracted values:', { applicantName, dob, dobInfo, ... });
```

#### Pattern 2: Admin Panel → PDF Generation
**File:** `admin-student-page.html` → `generateAcceptanceLetter()` function

**Flow:**
1. Admin clicks "Generate PDF" button
2. `generateAcceptanceLetter()` function:
   - Same data extraction as Pattern 1 (uses `getDobFromApplication()`)
   - Loads html2pdf.js library
   - Fetches `acceptance-letter.html` OR builds inline HTML with `buildInlineAcceptanceLetterHTML()`
   - Creates hidden container with template + data
   - Converts to PDF using html2canvas + jsPDF
   - Downloads as `Acceptance_Letter_{StudentName}.pdf`

#### Pattern 3: Student Portal → New Window
**File:** `application-status.html` → `viewAcceptanceLetter()` function

**Flow:**
1. Student clicks "View Acceptance Letter" on their status page
2. `viewAcceptanceLetter()` function:
   - Reads `window.currentApplicationData` (already loaded)
   - Extracts DOB using `deriveApplicationDob()` helper (24+ candidate paths)
   - Builds `letterData` object
   - Stores in `localStorage.setItem('ACCEPTANCE_LETTER_DATA', JSON.stringify(letterData))`
   - Opens `acceptance-letter.html` in new window: `window.open('acceptance-letter.html', '_blank')`
3. New window's `acceptance-letter.html` loads:
   - Reads `localStorage.getItem('ACCEPTANCE_LETTER_DATA')`
   - Parses JSON
   - Calls `renderAcceptanceLetter(data)`
   - **Clears localStorage** after use

## DOB Extraction System

### Problem
Date of birth can be stored in 20+ different locations/formats:
- `applications.date_of_birth`
- `applications.dob`
- `applications.payload.dob`
- `applications.payload.rawDob`
- `applications.payload.dobIso`
- `applications.payload.dateOfBirth`
- `students.date_of_birth`
- And many nested paths...

### Solution: Helper Functions

#### Admin Panel: `getDobFromApplication(source)`
**Location:** `admin-student-page.html` (lines ~1900-1970)

**Strategy:**
```javascript
function getDobFromApplication(source) {
  if (!source) return { display: 'N/A', iso: null, raw: null };
  
  const candidates = [
    source.date_of_birth,
    source.dob,
    source.rawDob,
    source.dobIso,
    source.payload?.dob,
    source.payload?.rawDob,
    source.payload?.dobIso,
    source.payload?.dateOfBirth,
    source.metadata?.dob,
    source.student?.date_of_birth,
    // ... 13+ total paths
  ];
  
  for (const candidate of candidates) {
    if (candidate && candidate !== '—' && candidate !== '-') {
      // Parse and format
      return { raw, iso, display };
    }
  }
  
  return { display: 'N/A', iso: null, raw: null };
}
```

**Usage:**
```javascript
const dobInfo = getDobFromApplication({ ...applicationData, ...currentStudent, payload });
const dob = dobInfo.display; // "12 May 2007"
const dobIso = dobInfo.iso;  // "2007-05-12"
```

#### Student Portal: `deriveApplicationDob(source)`
**Location:** `application-status.html` (lines ~850-980)

**Strategy:** More comprehensive with:
- 24+ candidate paths (DOB_CANDIDATE_PATHS array)
- Regex pattern matching (DOB_KEY_PATTERNS)
- Recursive deep search with circular reference protection
- Multiple format normalizations (Date objects, numbers, strings, ISO 8601)

**Usage:**
```javascript
const dobInfo = deriveApplicationDob(app);
const formattedDOB = dobInfo.display; // "12 May 2007"
```

## Data Structure: `letterData` Object

Both admin and student portal build the same structure:

```javascript
const letterData = {
  // Identity
  documentId: 'ACNHS-ACC-{control_number}',
  studentId: 'ACNHS-2026-0001',
  hash: '74F9B4F2C1CBE0E6A5D6B3C9A3A1F8AF', // generateHash()
  
  // Dates
  issueDate: 'January 14, 2026',
  academicYear: '2026 - 2027',
  dob: '12 May 2007', // From getDobFromApplication() or deriveApplicationDob()
  dobIso: '2007-05-12', // ISO format for metadata
  startDate: 'September 09, 2026',
  
  // Personal
  fullName: 'Gayane Zadourian',
  lastName: 'Zadourian',
  salutation: 'Ms.', // or 'Mr.' based on gender
  
  // Academic
  applicationId: 'APP-2026-123',
  programName: 'Bachelor of Science in Nursing',
  credential: "Bachelor's Degree",
  mode: 'Hybrid / Full-Time',
  
  // Administrative
  authorizedOfficer: 'Dr. Hrachya A. Vardanyan',
  officerTitle: 'President and Founder',
  
  // Verification
  controlNumber: 'ACN-2026-661805',
  qrCodeUrl: 'https://api.qrserver.com/v1/create-qr-code/?...',
  
  // Flags
  isVoid: false
};
```

## Template Rendering Function

**Location:** `acceptance-letter.html` JavaScript section

```javascript
function renderAcceptanceLetter(data = {}) {
  const payload = { ...defaultLetterData, ...data };
  
  // Update all data-field spans
  setText('documentId', payload.documentId);
  setText('issueDate', payload.issueDate);
  setText('fullName', payload.fullName);
  setText('dob', payload.dob);
  // ... all other fields ...
  
  // Update meta tags
  updateMetaTag('acnhs-document-id', payload.documentId);
  updateMetaTag('acnhs-student-id', payload.studentId);
  updateMetaTag('acnhs-hash', payload.hash);
  
  // Update QR code
  const qrImg = document.getElementById('qrCodeImage');
  qrImg.src = payload.qrCodeUrl || generateQRUrl(payload.controlNumber);
  
  // Update microtext security line
  microtext.textContent = `ARMENIAN COLLEGE OF NURSING • DOCUMENT ${payload.documentId} • VERIFIED ${payload.hash} • DO NOT ALTER •`;
  
  // Toggle VOID watermark
  voidLayer.classList.toggle('is-active', Boolean(payload.isVoid));
}
```

**Helper:**
```javascript
function setText(field, value) {
  const el = document.querySelector(`[data-field="${field}"]`);
  if (el) el.textContent = value;
}
```

## Troubleshooting

### Issue: Wrong Student Data Displayed

**Symptoms:**
- Gayane Zadourian's letter shows Ani Hakobyan's name/DOB
- Wrong Application ID displayed

**Debugging Steps:**
1. Open browser console (Cmd+Option+I on Mac)
2. Navigate to student's admin page
3. Click "Acceptance Letter" tab
4. Check console logs:
   ```
   [loadAcceptanceLetter] Current student: { student_id: 'ACNHS-2026-XXX', full_name: '...', ... }
   [loadAcceptanceLetter] Application data: { id: XX, applicant_name: '...', ... }
   [loadAcceptanceLetter] Extracted values: { applicantName: '...', dob: '...', ... }
   ```

**Common Causes:**
- `currentStudent` global variable not set correctly on page load
- Application query timing out (returns stale/wrong data)
- Template cached with old data (hard refresh: Cmd+Shift+R)
- localStorage not cleared from previous student

### Issue: DOB Shows "N/A"

**Debugging:**
```javascript
// In console:
console.log('Application data:', window.currentApplicationData);
console.log('DOB check:', getDobFromApplication(window.currentApplicationData));
```

**Solutions:**
- Verify DOB was captured during admission form submission
- Check database: `SELECT date_of_birth, dob, payload->'dob', payload->'rawDob' FROM applications WHERE id = X`
- Run SQL to backfill: `UPDATE applications SET date_of_birth = payload->>'dob' WHERE date_of_birth IS NULL`

### Issue: Database Timeouts (HTTP 500)

**Symptoms:**
```
Failed to load resource: the server responded with a status of 500
Error: canceling statement due to statement timeout
```

**Solutions:**
1. **Check Supabase Dashboard:**
   - Navigate to Database → Query Performance
   - Look for slow `SELECT * FROM applications` queries

2. **Add Indexes:**
   ```sql
   CREATE INDEX IF NOT EXISTS idx_applications_student_id ON applications(student_id);
   CREATE INDEX IF NOT EXISTS idx_applications_control_number ON applications(control_number);
   ```

3. **Optimize Queries:**
   ```javascript
   // Instead of:
   .select('*')
   
   // Use:
   .select('id, applicant_name, date_of_birth, dob, reference_number, control_number, program, gender, payload')
   ```

4. **Increase Timeout (Supabase Dashboard):**
   - Settings → Database → statement_timeout
   - Default: 10s → Increase to 30s for complex queries

### Issue: Template Not Loading (file://)

**Symptoms:**
```
Running over file:// — using inline acceptance letter template.
```

**Solution:**
Must run local dev server:
```bash
python3 start-server.py
# Then open: http://localhost:8000/admin-student-page.html
```

**Why:** `fetch()` doesn't work on `file://` protocol due to CORS restrictions.

## Files Reference

| File | Purpose | Key Functions |
|------|---------|---------------|
| `acceptance-letter.html` | Single template with data-field attributes | `renderAcceptanceLetter(data)` |
| `admin-student-page.html` | Admin UI for viewing/generating letters | `loadAcceptanceLetter()`, `generateAcceptanceLetter()`, `getDobFromApplication()` |
| `application-status.html` | Student portal for viewing status | `viewAcceptanceLetter()`, `deriveApplicationDob()` |
| `admission-form.html` | Initial data capture | Stores `dob`, `rawDob`, `dobIso` in payload |

## Testing Checklist

### Before Deployment

- [ ] Test admin panel acceptance letter tab for 3+ students
- [ ] Verify all data-field values are replaced (no "Ani Hakobyan" placeholders)
- [ ] Test PDF generation with correct student name in filename
- [ ] Test student portal "View Acceptance Letter" button
- [ ] Verify localStorage is cleared after letter opens
- [ ] Check browser console for NO errors or warnings
- [ ] Test with hard refresh (Cmd+Shift+R) to clear cache
- [ ] Verify DOB displays correctly for students with various data formats
- [ ] Check QR code generates with correct control number
- [ ] Verify verification hash is unique per student

### Database Integrity

- [ ] Query: `SELECT COUNT(*) FROM applications WHERE date_of_birth IS NULL AND payload->>'dob' IS NOT NULL`
- [ ] If > 0, run backfill script
- [ ] Verify indexes exist on frequently queried columns
- [ ] Test query performance: `EXPLAIN ANALYZE SELECT * FROM applications WHERE student_id = 'ACNHS-2026-001'`

## Change Log

### January 14, 2026
- ✅ Added `getDobFromApplication()` helper to `admin-student-page.html`
- ✅ Updated `loadAcceptanceLetter()` to use DOB helper with console logging
- ✅ Updated `generateAcceptanceLetter()` to use DOB helper with console logging
- ✅ Added `dobIso` field to letterData object for metadata
- ⚠️ **Awaiting user testing:** Verify Gayane Zadourian's letter shows correct data after refresh

### Previous Changes
- ✅ Created `deriveApplicationDob()` in `application-status.html` (24+ candidate paths)
- ✅ Enhanced `admission-form.html` to capture `dob`, `rawDob`, `dobIso`
- ✅ Added comprehensive DOB extraction with circular reference protection

## Future Enhancements

1. **Cache Busting:** Add student_id to fetch URL to prevent cross-student caching
   ```javascript
   fetch(`acceptance-letter.html?student=${currentStudent.student_id}&cache=${Date.now()}`)
   ```

2. **Validation:** Add data completeness check before rendering
   ```javascript
   const requiredFields = ['fullName', 'dob', 'applicationId', 'programName'];
   const missing = requiredFields.filter(field => !letterData[field] || letterData[field] === 'N/A');
   if (missing.length > 0) {
     console.warn('Missing required fields:', missing);
   }
   ```

3. **Audit Trail:** Log every letter view/generation
   ```sql
   CREATE TABLE acceptance_letter_log (
     id SERIAL PRIMARY KEY,
     student_id TEXT,
     action TEXT, -- 'view' or 'generate'
     user_email TEXT,
     timestamp TIMESTAMPTZ DEFAULT NOW()
   );
   ```

4. **Email Integration:** Send acceptance letter via email system
   - Use existing `send-email` edge function
   - Attach PDF generated by `generateAcceptanceLetter()`
   - Store in `email_history` table with type 'acceptance_letter'

## Support

For issues or questions:
1. Check browser console logs (prefix: `[loadAcceptanceLetter]` or `[generateAcceptanceLetter]`)
2. Verify Supabase connection and query performance
3. Test with local dev server (`python3 start-server.py`)
4. Review this document's Troubleshooting section
5. Check `DIPLOMA/.github/copilot-instructions.md` for project context
