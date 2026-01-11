# Resend Inbound Email Configuration

## Current Issue
The Resend webhook (`email.received` event) only sends metadata (from, to, subject) but **NOT the email body content**.

## Solutions to Get Email Body

### Option 1: Check Resend Dashboard Settings (Try This First)

1. Go to: https://resend.com/domains
2. Click on your domain `acnhs.am`
3. Go to **"Inbound"** tab
4. Look for settings like:
   - "Include email body in webhook"
   - "Send full email content"
   - "Parse email content"
5. **Enable** any options related to sending body/content

### Option 2: Create Resend API Key with Read Permissions

Your current API key is **send-only**. You need to create a new one:

1. Go to: https://resend.com/api-keys
2. Click **"Create API Key"**
3. Set permissions:
   - ✅ **Sending access** (to send emails)
   - ✅ **Reading access** (to retrieve inbound emails) ← **IMPORTANT**
4. Copy the new API key
5. Update the secret:
   ```bash
   npx supabase secrets set RESEND_API_KEY_DIPLOMA=<new_api_key> --project-ref zlvnxvrzotamhpezqedr
   ```

### Option 3: Contact Resend Support

If neither option works, contact Resend support and ask:
- "How do I receive the full email body (text/html) in the `email.received` webhook?"
- "My webhook only receives metadata, not the actual email content"

## Alternative: Use Contact Form Only

The simplest solution is to **disable external email replies** and have students use the contact form on the application status page:

**Pros:**
- ✅ Already works perfectly
- ✅ Saves full message to database
- ✅ Shows in Inbox tab
- ✅ No configuration needed

**Cons:**
- ❌ Students can't reply directly from their email client

To implement this:
1. Remove "Reply-To" header from outgoing emails
2. Add note: "Please do not reply to this email. Use the contact form in your student portal."

## What's Currently Working

✅ Webhook receives email events (from, to, subject)
✅ Saves sender and recipient to database
✅ Shows in Inbox tab
✅ Contact form emails save with full body
❌ External email replies missing body content

## Next Steps

Try **Option 1** first (check Resend dashboard for body settings).
If that doesn't work, try **Option 2** (create read-enabled API key).
If both fail, use **Option 3** (contact Resend) or switch to contact form only.
