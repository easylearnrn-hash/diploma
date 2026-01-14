# EMAIL SYSTEM EMERGENCY - Emails Being Deleted

## 🚨 CRITICAL FINDINGS

### Database Statistics Reveal:
```
total_inserts: 2   ← 2 emails were created
total_updates: 0   ← No modifications
total_deletes: 1   ← 1 EMAIL WAS DELETED! 🚨
current_rows: 1    ← Only 1 email remains
dead_rows: 1       ← Deleted row not cleaned up
```

## Problems Identified:

### 1. **Emails Are Being Deleted**
- You had "lots of sent emails"
- Now only 1 test email remains
- Database confirms 1 DELETE operation occurred

**Possible causes:**
- DELETE policy allows public/anon to delete
- Admin UI has delete button that was clicked
- Auto-cleanup script running
- Someone with admin access deleted records

### 2. **New Emails Not Saving**
- You send test emails but they don't appear
- Edge Function may be failing silently
- Or emails are being saved then immediately deleted

---

## 🔧 IMMEDIATE FIXES

### Fix 1: Check DELETE Policies
Run `CHECK-DELETE-POLICIES.sql` in Supabase to see if there's a DELETE policy.

**If you see:** "Allow public to delete email history" or similar
**Then run:**
```sql
DROP POLICY "Allow public to delete email history" ON email_history;
```

### Fix 2: Remove Public DELETE Access
Run this to ensure only service_role can delete:
```sql
-- Revoke DELETE from public roles
REVOKE DELETE ON email_history FROM anon;
REVOKE DELETE ON email_history FROM authenticated;
REVOKE DELETE ON email_history FROM public;

-- Only service_role should delete
GRANT DELETE ON email_history TO service_role;
```

### Fix 3: Check Edge Function Logs
1. Go to Supabase Dashboard: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/functions/send-email/logs
2. Send a test email from application-status.html
3. Look for these messages:
   - ✅ "Attempting to save email to database"
   - ✅ "Email saved to history successfully"
   - ❌ "Database save error: [ERROR MESSAGE]"

### Fix 4: Test Email Saving Right Now
```sql
-- Insert a test email manually
INSERT INTO email_history (
    recipient,
    sender,
    subject,
    body,
    html_body,
    status,
    sent_at,
    resend_id
) VALUES (
    'recovery-test@example.com',
    'admissions@acnhs.am',
    'Recovery Test - ' || NOW()::text,
    'Testing if emails can be saved after policy fix',
    '<p>Testing if emails can be saved after policy fix</p>',
    'sent',
    NOW(),
    'recovery-' || gen_random_uuid()::text
);

-- Check if it stays or gets deleted
SELECT COUNT(*) as total_emails FROM email_history;
-- If count increases and stays, problem is in Edge Function
-- If count goes back down, something is auto-deleting
```

---

## 🔍 Root Cause Analysis

### Scenario 1: RLS Policy Allows Deletes
**Problem:** `CREATE-EMAIL-HISTORY-TABLE.sql` may have created a DELETE policy
**Solution:** Remove DELETE policy, only allow SELECT and INSERT

### Scenario 2: Edge Function Not Saving
**Problem:** Edge Function sends email but database insert fails
**Solution:** Check Edge Function logs for errors

### Scenario 3: UI Delete Function
**Problem:** Email system UI has delete button that removes records
**Solution:** Check email-system.html for delete functions

---

## ✅ Action Plan

1. **FIRST:** Run `CHECK-DELETE-POLICIES.sql` → See if DELETE policy exists
2. **SECOND:** Revoke DELETE permissions from anon/authenticated
3. **THIRD:** Insert test email via SQL → See if it stays
4. **FOURTH:** Send email from UI → Check Edge Function logs
5. **FIFTH:** Check email count after 5 minutes → See if auto-deleted

---

## 🎯 Expected Outcome

After fixes:
- ✅ No DELETE policy for public users
- ✅ Only service_role can delete
- ✅ New emails save successfully
- ✅ Saved emails persist
- ✅ Edge Function logs show "Email saved to history successfully"

---

## 📋 Files to Check

- `CREATE-EMAIL-HISTORY-TABLE.sql` - May have DELETE policy
- `email-system.html` - May have delete button/function
- `supabase/functions/send-email/index.ts` - Email saving logic

**CRITICAL:** Fix the DELETE policy FIRST before sending more emails!
