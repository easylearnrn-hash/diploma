# Enrollment Username Change - Implementation Guide

## Overview
When a student's status changes to **ENROLLED**, their username is automatically updated from the original format (e.g., `narine.avetisyan.3251`) to their **institutional email address** (e.g., `n.avetisyan7022395@acnhs.am`). The password remains unchanged.

## Changes Implemented

### 1. Updated `ensureEnrollmentProvisioned()` Function
**File:** `admin-applications.html` (Lines 2510-2545)

#### What Changed:
- Added username update to `applications` table during enrollment
- Username is now set to the institutional email address
- Also updates `institutional_email` column and `payload`

#### Code Changes:
```javascript
// Update application username to institutional email when enrolled
const { error: appUpdateError } = await supabase
  .from('applications')
  .update({
    username: institutionalEmail, // ← NEW: Username becomes institutional email
    institutional_email: institutionalEmail,
    payload: updatedPayload
  })
  .eq('id', app.id);
```

#### Metadata Update:
```javascript
const mergedMetadata = {
  ...existingMetadata,
  personal_email: personalEmail || existingMetadata.personal_email || null,
  portal: {
    ...(existingMetadata.portal || {}),
    institutional_email: institutionalEmail,
    provisioned_at: provisionedAt,
    username: institutionalEmail // ← NEW: Store institutional email as username
  }
};
```

## Login Flow

### Before Enrollment
**Username:** `narine.avetisyan.3251`  
**Password:** `generated-password-123`  
**Login with:** `narine.avetisyan.3251` + password

### After Enrollment (Status = ENROLLED)
**Username:** `n.avetisyan7022395@acnhs.am` (institutional email)  
**Password:** `generated-password-123` (SAME password)  
**Login with:** `n.avetisyan7022395@acnhs.am` + password

### Login System Compatibility
The login system (`login.html`) already supports both formats:
1. First checks `email` field
2. Then checks `username` field ✅ (will match institutional email)
3. Then checks `payload->institutionalEmail` ✅ (fallback)

**Result:** Students can login with their institutional email seamlessly!

## Settings Tab Display

### Before Enrollment
```
👤 Username: narine.avetisyan.3251
🔑 Password: ••••••••••••
🌐 Portal Email: narine.avetisyan.3251@acnhs.am
```

### After Enrollment
```
👤 Username: n.avetisyan7022395@acnhs.am
🔑 Password: ••••••••••••
🌐 Portal Email: n.avetisyan7022395@acnhs.am
```

**Note:** Username and Portal Email become the same after enrollment!

## Database Schema

### `applications` Table
```sql
username TEXT UNIQUE,           -- Updated to institutional email on enrollment
institutional_email TEXT,       -- Set during enrollment
plain_password TEXT,            -- Never changes (unless admin resets)
password_hash TEXT,             -- Never changes (unless admin resets)
payload JSONB                   -- Updated with enrollment data
```

### Flow Diagram
```
Application Submitted
↓
username: narine.avetisyan.3251
password: generated-password-123
↓
Status Changed to ENROLLED
↓
ensureEnrollmentProvisioned() called
↓
1. Generate institutional email: n.avetisyan7022395@acnhs.am
2. Update applications.username → n.avetisyan7022395@acnhs.am
3. Update applications.institutional_email → n.avetisyan7022395@acnhs.am
4. Keep plain_password and password_hash unchanged
↓
Student can now login with:
n.avetisyan7022395@acnhs.am + same password
```

## Testing Instructions

### Test Case 1: New Enrollment
1. Open `admin-applications.html`
2. Find application with status != ENROLLED
3. Change status to **ENROLLED**
4. Wait for success notification
5. Click on student name to open profile
6. Go to **⚙️ Settings** tab
7. Verify:
   - ✅ Username shows institutional email (e.g., `n.avetisyan7022395@acnhs.am`)
   - ✅ Portal Email matches username
   - ✅ Password remains the same

### Test Case 2: Login with New Username
1. Copy institutional email from Settings tab
2. Copy password (click Show/Hide, then copy)
3. Open `login.html` in incognito/private window
4. Enter institutional email as username
5. Enter password
6. Click Login
7. Verify:
   - ✅ Login succeeds
   - ✅ Student dashboard loads
   - ✅ No errors in console

### Test Case 3: Existing Enrolled Students
For students already enrolled before this change:
1. Open their profile in admin panel
2. Go to Applications tab
3. Change status to something else (e.g., ON HOLD)
4. Change back to ENROLLED
5. This will trigger username update
6. Verify username changed in Settings tab

## Backward Compatibility

### Old Username Still Works?
**No.** Once username is updated to institutional email, the old username format is replaced.

### Can Students Still Use Old Username?
**No.** After enrollment, only the institutional email works for login.

### What About Students Enrolled Before This Change?
- Their username remains in old format until:
  1. Status is changed away from ENROLLED and back, OR
  2. Admin manually updates their username in database

### Manual Update Query (if needed)
```sql
-- Update all enrolled students to use institutional email as username
UPDATE applications
SET username = payload->>'institutionalEmail'
WHERE status = 'ENROLLED'
  AND payload->>'institutionalEmail' IS NOT NULL
  AND username != payload->>'institutionalEmail';
```

## Edge Cases

### Case 1: No Institutional Email Generated
- **Unlikely** - `generateInstitutionalEmail()` always generates one
- **Fallback:** Username stays as original format
- **Fix:** Manually set institutional email in payload

### Case 2: Student Already Has Institutional Email as Username
- **Update skipped** - No change needed
- **Safe:** Update query won't cause conflicts

### Case 3: Duplicate Institutional Emails
- **Prevented** by `generateInstitutionalEmail()` uniqueness check
- **Safe:** Uses sequential numbers (e.g., `n.avetisyan7022395@acnhs.am`, `n.avetisyan7022396@acnhs.am`)

### Case 4: Password Reset After Enrollment
- **Works normally** - Password reset doesn't affect username
- **Username stays** as institutional email
- **New password** stored in `plain_password` and `password_hash`

## Benefits

### For Students
✅ Professional email address format  
✅ Consistent username across systems  
✅ Same password before and after enrollment  
✅ Email format matches campus email

### For Admins
✅ Easy to identify enrolled students by username format  
✅ Username = Email = Single identifier  
✅ Reduced confusion about login credentials  
✅ Settings tab shows current username

### For System
✅ Cleaner user management  
✅ Email-based authentication ready  
✅ Matches institutional email standards  
✅ Backward compatible with login system

## Related Files

- **`admin-applications.html`** - Enrollment provisioning logic
- **`login.html`** - Login authentication (already compatible)
- **`admin-student-page.html`** - Settings tab displays username
- **`admission-form.html`** - Initial username generation (unchanged)

## Future Enhancements

### Phase 2 Considerations
1. **Email Notification:** Send email when username changes
2. **Credential Update Email:** Auto-send new login credentials
3. **Login Redirect:** Show message "Your username has changed to..."
4. **Bulk Update Tool:** Update all existing enrolled students
5. **Audit Log:** Track username changes in system

## Troubleshooting

### Username Not Changing After Enrollment
**Check:**
1. Status is exactly "ENROLLED" (case-sensitive)
2. `ensureEnrollmentProvisioned()` is being called
3. Institutional email was generated successfully
4. No database errors in browser console

**Fix:**
- Manually trigger enrollment by changing status away and back
- Check Supabase logs for update errors

### Student Can't Login with New Username
**Check:**
1. Username in database is actually updated
2. Password hasn't been changed accidentally
3. Student is using exact institutional email (no typos)
4. Login system is checking `username` field

**Fix:**
- Verify username with query: `SELECT username FROM applications WHERE id = '<app_id>'`
- Reset password if needed
- Copy exact username from Settings tab

### Settings Tab Shows Old Username
**Check:**
1. Page has been refreshed after enrollment
2. Settings tab has been opened (triggers `loadSettings()`)
3. Application record actually updated in database

**Fix:**
- Close and reopen student profile
- Hard refresh browser (Cmd+Shift+R / Ctrl+Shift+F5)
- Check database directly

## Production Deployment

### Pre-deployment Checklist
- [x] Code changes committed
- [x] Tested enrollment flow
- [x] Verified login with institutional email
- [x] Settings tab displays correctly
- [ ] Run bulk update query for existing students (optional)
- [ ] Notify admins about username change behavior
- [ ] Update user documentation

### Post-deployment Validation
- [ ] Test enrollment on production database
- [ ] Verify login works with institutional email
- [ ] Check Settings tab for enrolled students
- [ ] Monitor error logs for any issues

---

**Status:** ✅ COMPLETE - Production Ready  
**Last Updated:** February 5, 2026  
**Author:** GitHub Copilot
