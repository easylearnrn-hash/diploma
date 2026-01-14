# 🚨 EMERGENCY: Email System Broken After Recent Changes

## Critical Issue
**Symptom:** No incoming or outgoing emails visible in email system  
**When Started:** After recent Edge Function changes (around commit 2fce854 - "Fix email HTML rendering")  
**Database Stats:** 2 inserts, 1 delete, 1 remaining → Emails are being DELETED

---

## 🔍 Root Cause Analysis

### What We Know:
1. **System worked perfectly before** recent changes
2. **Database statistics prove deletion occurred:**
   - `total_inserts: 2` (2 emails created)
   - `total_deletes: 1` (1 email DELETED!)
   - `current_rows: 1` (only 1 remains)
   - `dead_rows: 1` (deleted row not vacuumed)

3. **User confirms:** "lots of sent emails" now gone
4. **New emails not appearing** when sent

### Possible Causes:
- ❌ **BCC feature** (user mentioned this, but NO BCC code found in repo)
- ⚠️ **DELETE policy** allowing public/anon to delete emails
- ⚠️ **Edge Function failing** to save new emails
- ⚠️ **Auto-cleanup trigger** deleting old emails
- ⚠️ **UI delete button** accidentally used

---

## 🛠️ IMMEDIATE DIAGNOSTIC STEPS

### Step 1: Run Test Insert (DO THIS FIRST!)
**Purpose:** See if manually inserted emails stay or get auto-deleted

**Action:** Run `TEST-EMAIL-SAVE.sql` in Supabase SQL Editor

**Expected Results:**
- ✅ **BEFORE TEST:** Shows current count (should be 1)
- ✅ **INSERT:** Creates test email
- ✅ **AFTER INSERT:** Count increases to 2
- 🚨 **DELETE POLICY CHECK:** Shows if DELETE policy exists

**Critical Check:** Wait 30 seconds, then run:
```sql
SELECT COUNT(*) FROM email_history;
```
- If count drops back to 1 → **Auto-deletion happening!**
- If count stays at 2 → **Emails CAN be saved, problem is elsewhere**

---

### Step 2: Check DELETE Policies
Run `CHECK-DELETE-POLICIES.sql` to see what's allowing deletions.

**Look for:**
- Policy named "Allow public to delete email history" or similar
- Triggers on `email_history` table
- CASCADE deletes from related tables

---

### Step 3: Check Edge Function Logs
Since CLI doesn't work, use **Supabase Dashboard:**

1. Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/functions/send-email/logs
2. Send test email from `application-status.html` contact form
3. Look for these messages:
   - ✅ "Attempting to save email to database"
   - ✅ "Email saved to history successfully"
   - ❌ "Database save error: [ERROR]"

**If no logs appear:** Edge Function not being called at all!

---

### Step 4: Test Email Sending Flow
1. Open browser console (Cmd+Option+I)
2. Go to `application-status.html`
3. Fill out contact form
4. Click Send
5. Watch for:
   - ✅ "Email sent successfully" message
   - ❌ Network errors in Console → Network tab
   - ❌ Edge Function errors

---

## 🔧 FIXES (Apply Based on Findings)

### Fix A: Remove DELETE Policy
**If Step 2 found DELETE policy:**
```sql
-- Find the exact policy name from CHECK-DELETE-POLICIES.sql
-- Then drop it:
DROP POLICY "Allow public to delete email history" ON email_history;

-- Ensure only service_role can delete
REVOKE DELETE ON email_history FROM anon;
REVOKE DELETE ON email_history FROM authenticated;
REVOKE DELETE ON email_history FROM public;
GRANT DELETE ON email_history TO service_role;
```

---

### Fix B: Check Email System UI for Delete Buttons
**Search email-system.html for delete functions:**
```bash
grep -n "delete.*email\|remove.*email" email-system.html
```

**If found:** Check if Hrach accidentally clicked a delete button

---

### Fix C: Re-deploy Edge Function
**If logs show errors or no database save attempts:**
```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
supabase functions deploy send-email --project-ref zlvnxvrzotamhpezqedr
```

---

### Fix D: Check for Triggers
**If Step 1 shows auto-deletion:**
```sql
-- See all triggers on email_history
SELECT 
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'email_history';

-- If you find a cleanup trigger, drop it:
-- DROP TRIGGER [trigger_name] ON email_history;
```

---

## ✅ VERIFICATION STEPS

After applying fixes:

1. **Test manual insert:**
   ```sql
   INSERT INTO email_history (recipient, sender, subject, body, html_body, status, sent_at, resend_id)
   VALUES ('verify@test.com', 'admissions@acnhs.am', 'Verification Test', 'Test', '<p>Test</p>', 'sent', NOW(), gen_random_uuid()::text);
   
   -- Wait 1 minute, then check:
   SELECT COUNT(*) FROM email_history; -- Should NOT decrease
   ```

2. **Test UI email sending:**
   - Send email from `application-status.html`
   - Check Edge Function logs for "Email saved to history successfully"
   - Refresh `email-system.html` → Email should appear in SENT tab

3. **Check statistics again:**
   ```sql
   SELECT 
     n_tup_ins as total_inserts,
     n_tup_upd as total_updates,
     n_tup_del as total_deletes,
     n_live_tup as current_rows,
     n_dead_tup as dead_rows
   FROM pg_stat_user_tables
   WHERE relname = 'email_history';
   ```
   - `total_deletes` should NOT increase!

---

## 🎯 SUCCESS CRITERIA

- ✅ Manual INSERT stays in database (no auto-deletion)
- ✅ No DELETE policies for public/anon roles
- ✅ Edge Function logs show "Email saved to history successfully"
- ✅ New emails appear in `email-system.html` SENT tab
- ✅ Statistics show increasing `total_inserts` with NO new `total_deletes`
- ✅ `dead_rows` cleaned up with VACUUM

---

## 📋 Files to Check

- `TEST-EMAIL-SAVE.sql` - Test if inserts stay
- `CHECK-DELETE-POLICIES.sql` - Find what's deleting emails
- `supabase/functions/send-email/index.ts` - Email saving logic
- `email-system.html` - UI delete functions?
- `CREATE-EMAIL-HISTORY-TABLE.sql` - Original schema with policies

---

## 🚨 URGENT NEXT STEPS

1. **FIRST:** Run `TEST-EMAIL-SAVE.sql` → See if manual inserts stay
2. **SECOND:** Run `CHECK-DELETE-POLICIES.sql` → Find DELETE policy
3. **THIRD:** Apply Fix A (remove DELETE policy)
4. **FOURTH:** Test email sending from UI
5. **FIFTH:** Verify statistics show no new deletes

**START NOW!** User has lost historical email data - prevent further loss!
