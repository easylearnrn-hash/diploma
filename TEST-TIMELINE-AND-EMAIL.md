# Testing Timeline and Email System Issues

## Issue 1: Application Timeline Not Working

### Problem
The timeline dots (Submitted, Under Review, Decision Made) are not updating based on application status in `application-status.html`.

### Root Cause
The `updateTimeline()` function is called at line 1143, but the function logic may not be matching statuses correctly.

### Test Steps
1. Open `application-status.html` in browser with valid login
2. Open browser console (Cmd+Option+I)
3. Check for any JavaScript errors
4. Verify the status value: `console.log('Current status:', document.getElementById('statusText').textContent)`
5. Manually test timeline update: `updateTimeline('UNDER REVIEW')`
6. Check if dots update: 
   - `document.getElementById('dot-submitted').classList`
   - `document.getElementById('dot-review').classList`
   - `document.getElementById('dot-decision').classList`

### Expected Behavior
- **SUBMITTED**: Only first dot active
- **UNDER REVIEW/ACTIVELY REVIEWING/RFE PREPARING/RFE SENT**: First two dots active
- **APPROVED/DENIED**: All three dots active

### Code Location
- Function: `updateTimeline(status)` at line 1371-1403
- Called from: `displayApplicationStatus()` at line 1143

---

## Issue 2: Email System Not Saving Sent Emails

### Problem
Emails sent through the system are not being saved to the `email_history` table.

### Root Cause Analysis
The Edge Function (`supabase/functions/send-email/index.ts`) tries to insert into `email_history` with these columns:
- `recipient` ✅ (exists in CREATE-EMAIL-HISTORY-TABLE.sql)
- `sender` ❓ (added via ADD-SENDER-COLUMN.sql)
- `subject` ✅ (exists)
- `body` ✅ (exists)
- `html_body` ❓ (added via ADD-HTML-BODY-COLUMN.sql)
- `status` ✅ (exists)
- `sent_at` ✅ (exists)
- `resend_id` ✅ (exists)

### Database Column Verification Needed
Run this SQL in Supabase SQL Editor:

```sql
-- Check if all required columns exist
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'email_history' 
ORDER BY ordinal_position;
```

Expected columns:
1. `id` (UUID, PRIMARY KEY)
2. `recipient` (TEXT, NOT NULL)
3. `subject` (TEXT, NOT NULL)
4. `body` (TEXT, NOT NULL)
5. `status` (TEXT, NOT NULL)
6. `sent_at` (TIMESTAMP WITH TIME ZONE)
7. `resend_id` (TEXT)
8. `error` (TEXT)
9. `created_at` (TIMESTAMP WITH TIME ZONE)
10. `sender` (TEXT) - **Must exist**
11. `html_body` (TEXT) - **Must exist**

### Missing Columns Fix
If `sender` or `html_body` columns don't exist, run:

```sql
-- Add sender column
ALTER TABLE email_history 
ADD COLUMN IF NOT EXISTS sender TEXT;

-- Add html_body column
ALTER TABLE email_history 
ADD COLUMN IF NOT EXISTS html_body TEXT;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_email_history_sender ON email_history(sender);
```

### Test Email Sending
1. Open `application-status.html`
2. Click "Contact Admissions" button
3. Fill out contact form
4. Submit email
5. Check Supabase Edge Function logs:
   ```bash
   supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr
   ```
6. Check database:
   ```sql
   SELECT * FROM email_history ORDER BY sent_at DESC LIMIT 5;
   ```

### Expected Behavior
- Email should be sent via Resend API
- Record should be inserted into `email_history` table
- No database errors in Edge Function logs
- Email should appear in admin email system

---

## Issue 3: Email System Not Receiving Incoming Emails

### Problem
Incoming emails are not showing up in the email system.

### Root Cause
The system currently only tracks **outgoing** emails sent through the Edge Function. There is no incoming email webhook or fetching mechanism implemented.

### Current Architecture
```
Student/Admin → Frontend Form → Edge Function → Resend API → Recipient
                                      ↓
                                email_history (outgoing only)
```

### Missing Components
1. **Inbound Email Handler**: No webhook to receive incoming emails
2. **Email Polling**: No mechanism to fetch emails from inbox
3. **Thread Tracking**: No `in_reply_to` or `thread_id` columns

### Solutions

#### Option 1: Resend Inbound Webhooks (Recommended)
Resend can forward incoming emails to a webhook endpoint:

1. Create new Edge Function: `supabase/functions/receive-email/index.ts`
2. Configure Resend webhook to point to this function
3. Parse incoming email and save to `email_history`
4. Update `email_history` table schema to support inbound emails:
   ```sql
   ALTER TABLE email_history ADD COLUMN direction TEXT DEFAULT 'outbound';
   ALTER TABLE email_history ADD COLUMN in_reply_to TEXT;
   ALTER TABLE email_history ADD COLUMN thread_id TEXT;
   ```

#### Option 2: Manual Email Import
Admin can manually add incoming emails through the UI (interim solution).

### Recommended Next Steps
1. ✅ Fix timeline rendering (JavaScript logic)
2. ✅ Verify email_history table has all columns
3. ✅ Test outgoing email saving
4. 🔲 Implement inbound email webhook
5. 🔲 Add email threading/conversation view

---

## Quick Test Commands

### Check Email History Table Schema
```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
cat CREATE-EMAIL-HISTORY-TABLE.sql
cat ADD-SENDER-COLUMN.sql
cat ADD-HTML-BODY-COLUMN.sql
```

### View Edge Function Logs
```bash
supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr
```

### Test Timeline in Browser Console
```javascript
// Check current status
console.log('Status:', document.getElementById('statusText').textContent);

// Test timeline update
updateTimeline('SUBMITTED'); // Should activate only dot 1
updateTimeline('UNDER REVIEW'); // Should activate dots 1-2
updateTimeline('APPROVED'); // Should activate all 3 dots

// Check dot states
console.log('Dot 1:', document.getElementById('dot-submitted').classList.contains('inactive'));
console.log('Dot 2:', document.getElementById('dot-review').classList.contains('inactive'));
console.log('Dot 3:', document.getElementById('dot-decision').classList.contains('inactive'));
```

### Check Email History Records
```sql
-- In Supabase SQL Editor
SELECT 
  id,
  sender,
  recipient,
  subject,
  status,
  sent_at,
  LENGTH(html_body) as html_length
FROM email_history 
ORDER BY sent_at DESC 
LIMIT 10;
```
