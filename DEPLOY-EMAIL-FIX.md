# Deploy Email Fix - Student-to-Student Email Issue

## The Problem
Students cannot see emails sent to them by other students because the Edge Function was skipping database records for student-to-student emails.

## The Fix
Updated `supabase/functions/send-email/index.ts` to create TWO database records for student-to-student emails:
- **Sender record** (status: 'sent') - Shows in sender's "Sent" folder  
- **Recipient record** (status: 'received') - Shows in recipient's "Inbox"

## Manual Deployment Steps

### Option 1: Via Supabase Dashboard (EASIEST)

1. **Go to**: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/functions

2. **Click on "send-email"** function

3. **Click "Deploy new version"** or **"Edit function"**

4. **Copy the entire contents** of:
   ```
   /Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/supabase/functions/send-email/index.ts
   ```

5. **Paste into the editor** in the dashboard

6. **Also update the shared CORS file** if needed:
   ```
   /Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/supabase/functions/_shared/cors.ts
   ```

7. **Click "Deploy"**

### Option 2: Via CLI (if you have proper access)

```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"

# Make sure you're logged in
supabase login

# Deploy the function
supabase functions deploy send-email --project-ref eyhksbiceueoiamwnqpr
```

## Testing After Deployment

1. **Login as Student 1** (e.g., narine.avetisyan@acnhs.am)
2. **Send email to Student 2** (e.g., another student's @acnhs.am address)
3. **Check Student 1's "Sent" folder** - email should appear ✅
4. **Login as Student 2**
5. **Check Student 2's "Inbox"** - email should appear ✅

## What Changed in the Code

### Before (Lines ~365-395):
```typescript
// Skip logging for internal routing
const isInternalRouting = 
  senderEmail?.toLowerCase().includes('acnhs.am') &&
  to?.toLowerCase().includes('acnhs.am') &&
  !!replyTo &&
  !replyTo?.toLowerCase().includes('acnhs.am')

if (isInternalRouting) {
  console.log('⏭️ Skipping database log...')
  return // ❌ Email never saved to database!
}
```

### After:
```typescript
// Check if this is student-to-student email
const senderIsAcnhs = emailSender?.toLowerCase().endsWith('@acnhs.am')
const recipientIsAcnhs = normalizedRecipient?.toLowerCase().endsWith('@acnhs.am')
const isStudentToStudent = senderIsAcnhs && recipientIsAcnhs

if (isStudentToStudent) {
  // Create TWO records:
  
  // 1. Sender record (status: 'sent')
  await supabase.from('email_history').insert([{
    recipient: normalizedRecipient,
    sender: emailSender,
    subject: subject,
    body: textPreview,
    html_body: html.substring(0, 50000),
    status: 'sent', // ✅ Shows in sender's Sent folder
    sent_at: new Date().toISOString(),
    resend_id: resendData.id,
    attachments: storedAttachments.length ? storedAttachments : null
  }])
  
  // 2. Recipient record (status: 'received')
  await supabase.from('email_history').insert([{
    recipient: normalizedRecipient,
    sender: emailSender,
    subject: subject,
    body: textPreview,
    html_body: html.substring(0, 50000),
    status: 'received', // ✅ Shows in recipient's Inbox
    sent_at: new Date().toISOString(),
    resend_id: resendData.id,
    attachments: storedAttachments.length ? storedAttachments : null
  }])
}
```

## Expected Console Logs

After deployment, when a student sends an email to another student, you should see:

```
🔍 Email type: { isStudentToStudent: true, senderIsAcnhs: true, recipientIsAcnhs: true }
📧 Student-to-student email detected - creating dual records
✅ Sender record created: [object]
✅ Recipient record created: [object]
```

## Troubleshooting

If emails still don't appear after deployment:

1. **Check Edge Function logs**: 
   - Dashboard → Functions → send-email → Logs
   - Look for "Student-to-student email detected" message

2. **Check database directly**:
   ```sql
   SELECT sender, recipient, subject, status, sent_at 
   FROM email_history 
   WHERE sender LIKE '%@acnhs.am' 
   AND recipient LIKE '%@acnhs.am'
   ORDER BY sent_at DESC
   LIMIT 10;
   ```

3. **Verify both records exist**:
   - One with `status = 'sent'`
   - One with `status = 'received'`
   - Same `resend_id`
   - Same timestamp

---

**Status**: Code updated, waiting for deployment  
**File modified**: `supabase/functions/send-email/index.ts`  
**Lines changed**: ~365-445  
**Deploy when ready**: See options above ⬆️
