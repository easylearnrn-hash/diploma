# 🚨 INCOMING EMAILS NOT APPEARING - Webhook Not Configured

## Problem
You can see incoming emails in **Resend Dashboard** (9 emails in "Receiving" tab), but they **don't appear in your email system** because the webhook is not configured.

---

## Current Status

### ✅ What's Working:
- `receive-email` Edge Function is **DEPLOYED** (version 25, active)
- Function URL: `https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/receive-email`
- Database has `email_history` table ready
- INBOX tab filters correctly for `status='received'`

### ❌ What's Missing:
- **Resend Inbound Webhook** not configured to forward emails to Edge Function
- Incoming emails stay in Resend but never reach your database

---

## How It Should Work

```
Student sends email to admissions@acnhs.am
          ↓
Resend receives email
          ↓
Resend webhook sends email data to Edge Function
          ↓
receive-email Edge Function saves to database
          ↓
Email appears in INBOX tab of email-system.html
```

**Currently stuck at step 3:** Resend doesn't know to forward emails to your Edge Function!

---

## FIX: Configure Resend Webhook

### Step 1: Get Your Webhook URL
```
https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/receive-email
```

### Step 2: Go to Resend Dashboard
1. Open: https://resend.com/emails
2. Click **"Webhooks"** in left sidebar (or go to Settings → Webhooks)
3. Click **"Add Endpoint"** or **"Create Webhook"**

### Step 3: Configure Webhook
**Webhook URL:**
```
https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/receive-email
```

**Events to Subscribe:**
- ✅ `email.received` (incoming emails)
- ✅ `email.delivered` (optional - for delivery tracking)
- ✅ `email.bounced` (optional - for bounce tracking)
- ✅ `email.opened` (optional - for open tracking)

**Important:** Make sure `email.received` is checked!

### Step 4: Save and Test
1. Click **"Create Endpoint"** or **"Save"**
2. Resend will send a test webhook
3. If successful, you'll see a ✅ checkmark

---

## Testing

### Test 1: Send Email to ACNHS
1. Use your personal Gmail: `hrachfilm@gmail.com`
2. Send email to: `admissions@acnhs.am`
3. Subject: "Webhook Test - Incoming Email"
4. Body: "Testing if incoming emails now appear in system"

### Test 2: Check Edge Function Logs
```bash
# Check logs to see if webhook was received
# (Unfortunately CLI --project-ref doesn't work, use Dashboard)
```
Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/functions/receive-email/logs

**Look for:**
- ✅ "Received inbound email webhook"
- ✅ "Saved email to database successfully"
- ❌ Errors about missing fields or database save failures

### Test 3: Check Database
Run this SQL in Supabase SQL Editor:
```sql
-- Check if incoming email was saved
SELECT 
  sender,
  recipient,
  subject,
  status,
  sent_at
FROM email_history
WHERE recipient LIKE '%@acnhs.am'
  AND status = 'received'
ORDER BY sent_at DESC
LIMIT 5;
```

**Expected:** Should show your test email with `status='received'`

### Test 4: Check Email System UI
1. Go to: `http://localhost:8000/email-system.html`
2. Click **INBOX** tab
3. Should see your incoming test email

---

## Troubleshooting

### Issue: Webhook shows error in Resend
**Check:** Edge Function logs for errors
**Fix:** Function might need CORS headers or authentication fix

### Issue: Webhook succeeds but email not in database
**Check:** Edge Function logs - might show database save error
**Fix:** Check RLS policies allow INSERT with `status='received'`

### Issue: Email in database but not showing in INBOX
**Check:** 
```sql
SELECT status, COUNT(*) FROM email_history GROUP BY status;
```
**Fix:** Run `FIX-EMAIL-STATUS.sql` to update status to 'received'

---

## Expected Outcome

After configuring webhook:
1. ✅ Incoming emails appear in Resend Dashboard
2. ✅ Webhook forwards email data to Edge Function
3. ✅ Edge Function saves with `status='received'`
4. ✅ Email appears in INBOX tab immediately
5. ✅ All 9 existing incoming emails should flow through

---

## Quick Checklist

- [ ] Copy webhook URL: `https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/receive-email`
- [ ] Go to Resend Dashboard → Webhooks
- [ ] Add new endpoint with URL
- [ ] Subscribe to `email.received` event
- [ ] Save webhook
- [ ] Send test email from Gmail → admissions@acnhs.am
- [ ] Check Edge Function logs
- [ ] Check database for new email with `status='received'`
- [ ] Verify email appears in INBOX tab

---

## Files Referenced
- `supabase/functions/receive-email/index.ts` - Webhook handler (deployed)
- `INBOUND-EMAIL-SETUP.md` - Complete setup guide
- `email-system.html` - INBOX tab filters for `status='received'`

**Next Step:** Configure the webhook in Resend Dashboard NOW!
