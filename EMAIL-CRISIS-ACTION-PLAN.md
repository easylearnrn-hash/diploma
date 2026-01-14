# CRITICAL EMAIL SYSTEM ISSUES - Action Plan

## 🚨 Issues Identified

### 1. Mass Email Deletion
**Problem:** User had "lots of sent emails" but now they're all gone
**Evidence:** 1 dead row in database = deleted records
**Impact:** Data loss - historical email communications lost

### 2. New Emails Not Saving
**Problem:** When sending test emails, they don't appear in database
**Evidence:** User reports sending emails but they don't show up
**Impact:** Email system non-functional

---

## 🔍 Immediate Investigation Steps

### Step 1: Run `FIND-EMAIL-DELETION-CAUSE.sql`
This will check for:
- DELETE triggers that auto-delete emails
- CASCADE rules that delete related records
- RLS policies allowing unauthorized deletes
- Scheduled jobs cleaning up old emails
- Insert/update/delete statistics

### Step 2: Check Edge Function Logs Manually
Since CLI command failed, check in Supabase Dashboard:

1. Go to https://supabase.com/dashboard
2. Select project `zlvnxvrzotamhpezqedr`
3. Navigate to **Edge Functions** → **send-email**
4. Click **Logs** tab
5. Look for:
   - ✅ "Email sent successfully" 
   - ✅ "Attempting to save email to database"
   - ✅ "Email saved to history successfully"
   - ❌ "Database save error" (THIS IS THE PROBLEM)
   - ❌ Any error messages

### Step 3: Test Email Sending with Console Logging

Send a test email from `application-status.html` and watch:
1. Browser console for response
2. Supabase Edge Function logs
3. Database immediately after: `SELECT COUNT(*) FROM email_history;`

---

## 🛠️ Possible Root Causes

### Cause A: RLS Policy Allowing Deletes
**Symptom:** Emails get deleted by mistake
**Fix:** Check `pg_policies` output - if DELETE policy too permissive, restrict it

```sql
-- Remove overly permissive DELETE policy
DROP POLICY IF EXISTS "Allow public to delete email history" ON email_history;

-- Or make it admin-only
CREATE POLICY "Admin only delete" ON email_history
  FOR DELETE TO authenticated
  USING (auth.jwt() ->> 'email' = 'admin@example.com');
```

### Cause B: Edge Function Failing to Save
**Symptom:** Email sends via Resend but doesn't save to DB
**Fix:** Check logs for "Database save error" 
**Common issues:**
- Missing `sender` or `html_body` columns (but we verified they exist)
- RLS policy blocking INSERT
- Timeout during save

### Cause C: Cascading Delete from Related Table
**Symptom:** Deleting something else deletes emails
**Fix:** Check foreign key output - if CASCADE exists, change to NO ACTION

### Cause D: Auto-cleanup Job
**Symptom:** Old emails automatically deleted
**Fix:** Find and disable the scheduled job

---

## 🚀 Immediate Actions Required

### Action 1: Protect Remaining Data
```sql
-- IMMEDIATELY revoke DELETE permissions until we figure this out
REVOKE DELETE ON email_history FROM anon;
REVOKE DELETE ON email_history FROM authenticated;

-- Keep only for service role
GRANT DELETE ON email_history TO service_role;
```

### Action 2: Enable Detailed Logging
Add to Edge Function (temporarily):
```typescript
console.log('📧 Attempting email save:', {
  recipient: to,
  sender: emailSender,
  timestamp: new Date().toISOString()
});

// After save attempt
console.log('✅ Save result:', { data, error });
```

### Action 3: Test Insertion Manually
```sql
-- Try inserting directly in Supabase
INSERT INTO email_history (
    recipient, sender, subject, body, html_body, status, sent_at
) VALUES (
    'manual-test@example.com',
    'admissions@acnhs.am',
    'Manual Insert Test',
    'Testing direct insertion',
    '<p>Testing direct insertion</p>',
    'sent',
    NOW()
) RETURNING *;

-- If this fails, RLS policy is blocking inserts
-- If this works, Edge Function is the problem
```

---

## 📋 Data Recovery

If emails were recently deleted:
```sql
-- Check if table has been vacuumed (can't recover after vacuum)
SELECT last_vacuum, last_autovacuum FROM pg_stat_user_tables WHERE relname = 'email_history';

-- If not vacuumed recently, dead rows might be recoverable
-- Contact Supabase support for point-in-time recovery
```

---

## 🎯 Next Steps (In Order)

1. ⚠️ **Run `FIND-EMAIL-DELETION-CAUSE.sql`** → Find what's deleting emails
2. ⚠️ **Revoke DELETE permissions** → Stop further data loss
3. ⚠️ **Check Edge Function logs** → See if emails reach save attempt
4. ⚠️ **Test manual INSERT** → Verify RLS allows inserts
5. ⚠️ **Send test email and watch logs** → Confirm save failure point
6. ✅ **Fix root cause** → Based on findings
7. ✅ **Re-enable proper permissions** → With safeguards

---

## 🔐 Recommended RLS Policies (After Fix)

```sql
-- SELECT: Anyone can read
CREATE POLICY "Allow public to read email history"
  ON email_history FOR SELECT TO public USING (true);

-- INSERT: Only service role (Edge Function) can insert
CREATE POLICY "Service role can insert"
  ON email_history FOR INSERT TO service_role WITH CHECK (true);

-- UPDATE: Admin only
CREATE POLICY "Admin can update"
  ON email_history FOR UPDATE TO authenticated
  USING (auth.jwt() ->> 'email' IN ('admin@example.com'));

-- DELETE: Admin only, not public!
CREATE POLICY "Admin can delete"
  ON email_history FOR DELETE TO authenticated
  USING (auth.jwt() ->> 'email' IN ('admin@example.com'));
```

---

**STATUS: CRITICAL DATA LOSS - NEEDS IMMEDIATE INVESTIGATION**
