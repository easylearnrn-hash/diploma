# Email System Debugging Notes

## Issues Reported
1. **Emails not coming through to student inbox** - Student can send but cannot receive
2. **Signature logo not showing** - Request to use base64 seal

## Analysis

### Issue 1: Email Receiving Problem
**Current State:**
- Student sends email successfully (confirmed by screenshot showing received email in external client)
- Inbox shows empty even though external users send emails
- Query uses `.or()` clause: `sender.eq.EMAIL,recipient.eq.EMAIL`
- Filter shows: `email.recipient === currentStudent.institutional_email`

**Possible Causes:**
1. Email records may not be created when external users send TO the student
2. The `email_history` table might only store emails sent BY students
3. Status field or other filters blocking received emails
4. Email format mismatch (institutional_email field)

**Solution Implemented:**
- Added extensive console logging to `loadEmails()` function:
  - Logs student email being queried
  - Logs raw count of emails fetched
  - Logs sample email structure
  - Logs inbox vs sent counts BEFORE security filter
  - Logs final count AFTER security filter
- This will help diagnose WHERE emails are being lost

**Debugging Steps for Admin:**
1. Open browser console (F12)
2. Navigate to student email page
3. Check console logs for:
   - "📧 Loading emails for: [email]"
   - "✅ Raw emails fetched: X"
   - "Inbox count: X" vs "Sent count: Y"
4. If raw fetch returns 0, check Supabase `email_history` table directly
5. If inbox count is 0 but database has emails, check recipient field format

### Issue 2: Logo Not Showing in Emails

**The Problem:**
- Current implementation: `<img src="assets/images/Seal.png">`
- Relative paths don't work in email clients
- Email needs absolute URL or base64 data URI

**Base64 Analysis:**
- File: `assets/images/Seal.png`
- Dimensions: 899x896 PNG RGBA
- Base64 size: **1,680,905 bytes (1.68MB)**
- **TOO LARGE** for practical email embedding

**Recommended Solutions (in order of preference):**

1. **Host logo on CDN/public URL** (BEST)
   ```html
   <img src="https://yourdomain.com/seal.png" width="64" height="64" />
   ```
   - Pros: Small HTML, fast loading, cacheable
   - Cons: Requires hosting setup

2. **Resize and optimize image first**
   ```bash
   # Resize to 128x128 (2x for retina)
   convert Seal.png -resize 128x128 Seal-small.png
   
   # Then base64 encode
   base64 -i Seal-small.png > seal-small-base64.txt
   ```
   - This would reduce base64 to ~20-50KB instead of 1.68MB
   - Much more practical for email embedding

3. **Use base64 inline (current 1.68MB version)** (NOT RECOMMENDED)
   - Will make HTML file massive
   - May cause email client issues
   - May be blocked by some email providers

**Current Status:**
- Logo kept as relative path with TODO comment
- Works in student portal preview
- **May not work in actual delivered emails**

## Testing Recommendations

### Test Email Receiving:
1. Have external user send email to student's institutional email
2. Check browser console for debug logs
3. Check Supabase `email_history` table:
   ```sql
   SELECT * FROM email_history 
   WHERE recipient = '[student-institutional-email]'
   ORDER BY sent_at DESC;
   ```
4. Verify Edge Function creates records for BOTH sender and recipient

### Test Logo in Emails:
1. Send test email to external Gmail/Outlook account
2. Open in actual email client (not just portal preview)
3. Check if logo appears or shows broken image
4. If broken, implement one of the recommended solutions above

## Files Modified
- `student-email.html` (lines 712-750): Added debugging logs to `loadEmails()`
- `student-email.html` (lines 918-924): Added TODO comment for logo issue

## Next Steps
1. **Immediate**: Use console logs to diagnose email receiving issue
2. **Short-term**: Implement logo hosting or resize/optimize seal image
3. **Long-term**: Consider implementing proper email relay system for bidirectional communication
