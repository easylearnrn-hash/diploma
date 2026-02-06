# Test Enrollment Email - Troubleshooting Guide

## Problem
Enrollment welcome email is not being sent when changing student status to "ENROLLED".

## Debug Steps Added

I've added comprehensive debugging to `admin-applications.html` to help identify the issue:

### 1. Email Function Debug (lines ~5935-5948)
```javascript
console.log('📧 ===== EMAIL SENDING DEBUG =====');
console.log('📧 Recipient:', studentEmail);
console.log('📧 Status:', newStatus);
console.log('📧 Applicant Name:', applicantName);
console.log('📧 Reference:', referenceNumber);
console.log('📧 Institutional Email:', institutionalEmail);
console.log('📧 Student ID:', studentId);
console.log('📧 Full application.payload:', application.payload);
console.log('📧 Will use ENROLLED template?', newStatus === 'ENROLLED' && institutionalEmail);
```

### 2. Before Email Call Debug (lines ~6370-6373)
```javascript
console.log('🔍 DEBUG: About to send email notification');
console.log('🔍 currentApp.payload:', currentApp?.payload);
console.log('🔍 studentLinkResult:', studentLinkResult);
```

## How to Test

### Step 1: Open Browser Console
1. Open `admin-applications.html` in your browser
2. Open Developer Tools (F12 or Right-click → Inspect)
3. Go to the **Console** tab

### Step 2: Change Status to ENROLLED
1. Find an application in the admin panel
2. Click to open the application drawer
3. Change status to "ENROLLED"
4. Click "Update Status"

### Step 3: Check Console Output
Look for these log messages:

#### Expected Console Output:
```
🔍 DEBUG: About to send email notification
🔍 currentApp.payload: {institutionalEmail: "n.avetisyan@acnhs.am", studentId: "ACNHS-7022395", ...}
🔍 studentLinkResult: {...}
📧 ===== EMAIL SENDING DEBUG =====
📧 Recipient: narineavetisyan7788@gmail.com
📧 Status: ENROLLED
📧 Applicant Name: Narine Avetisyan
📧 Reference: APP-XXXXXX
📧 Institutional Email: n.avetisyan@acnhs.am
📧 Student ID: ACNHS-7022395
📧 Full application.payload: {institutionalEmail: "n.avetisyan@acnhs.am", ...}
📧 Will use ENROLLED template? true
✅ Status change email sent successfully: {...}
```

## Common Issues to Check

### Issue 1: No Institutional Email in Payload
**Symptom:**
```
📧 Institutional Email: null
📧 Will use ENROLLED template? false
```

**Cause:** The `ensureEnrollmentProvisioned()` function didn't create/update the institutional email in the payload.

**Solution:** Check if the enrollment provisioning function is working correctly.

### Issue 2: Email Not Sent At All
**Symptom:**
```
⚠️ Cannot send email: Missing application or email address
```
OR
```
⚠️ Cannot send email: Invalid email address
```

**Cause:** The student's email is missing or invalid.

**Solution:** Verify the application has a valid email address in `application.email` or `application.payload.email`.

### Issue 3: Email API Error
**Symptom:**
```
❌ Failed to send status change email: Error: Email API returned 500
```

**Cause:** The Supabase Edge Function is failing.

**Solution:** Check the Edge Function logs:
```bash
supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr
```

### Issue 4: Wrong Email Template Used
**Symptom:**
```
📧 Will use ENROLLED template? false
```
(Even though status is ENROLLED and institutional email exists)

**Cause:** The conditional check `newStatus === 'ENROLLED' && institutionalEmail` is failing.

**Solution:** Verify:
- `newStatus` is exactly the string `'ENROLLED'` (case-sensitive)
- `institutionalEmail` is not null/undefined/empty

## Manual Email Test

If you want to test the email sending without changing status, run this in the browser console:

```javascript
// Test email sending function
const testApp = {
  email: 'test@example.com',
  applicant_name: 'Test Student',
  reference_number: 'TEST-123',
  payload: {
    email: 'test@example.com',
    fullName: 'Test Student',
    institutionalEmail: 't.student@acnhs.am',
    studentId: 'ACNHS-TEST123'
  }
};

await sendStatusChangeEmail(testApp, 'ENROLLED', 'Welcome to ACNHS!');
```

## What to Report Back

Please copy and paste the console output, especially:

1. **The full email debug section** (starting with `📧 ===== EMAIL SENDING DEBUG =====`)
2. **Any error messages** (starting with `❌` or `⚠️`)
3. **The payload content** (starting with `🔍 currentApp.payload:`)

This will help identify exactly where the issue is occurring.

## Quick Fixes to Try

### Fix 1: If institutional email is null
The enrollment provisioning might not be working. Check line ~6276 for:
```javascript
if (newStatus === 'ENROLLED') {
  try {
    studentLinkResult = await ensureEnrollmentProvisioned(supabase, currentApp, studentLinkResult);
  } catch (provisionError) {
    throw new Error(provisionError?.message || 'Unable to provision student portal access for this enrollment.');
  }
}
```

### Fix 2: If email is failing silently
The email error is caught and logged but doesn't stop the status update. Check for:
```javascript
} catch (emailError) {
  console.error('Failed to send email notification:', emailError);
  // Don't fail the entire operation if email fails
}
```

Look for this error message in the console.

### Fix 3: If template is not used
Remove the `&& institutionalEmail` condition temporarily to test:

**Current (line ~5951):**
```javascript
if (newStatus === 'ENROLLED' && institutionalEmail) {
```

**Temporary test (to see if email sends at all):**
```javascript
if (newStatus === 'ENROLLED') {  // Removed && institutionalEmail check
```

This will send the welcome email even without an institutional email (it will just show as undefined in the template).

---

**Next Steps:**
1. Refresh the admin page
2. Try changing a student status to ENROLLED
3. Check the browser console for the debug output
4. Share the console output so we can diagnose the exact issue
