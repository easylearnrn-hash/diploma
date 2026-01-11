# Inbound Email Setup - Receive External Email Replies

This guide explains how to set up inbound email processing so external email replies (from Gmail, Outlook, etc.) appear in your email system inbox.

## Overview

When students reply to your emails using their email client (Gmail, Outlook, etc.), those replies need to be forwarded to your system. Resend provides inbound email support that sends incoming emails to a webhook.

## What's Already Done ✅

1. **Edge Function Created**: `receive-email` function deployed
   - URL: `https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/receive-email`
   - Receives incoming emails from Resend webhook
   - Saves them to `email_history` table with `status='received'`

## Setup Steps

### 1. Configure Resend Inbound Email

Go to your Resend Dashboard: https://resend.com/domains

#### A. Add Your Domain (if not already added)
- Click "Add Domain"
- Enter your domain: `acnhs.am`
- Follow the DNS verification steps

#### B. Enable Inbound Email Processing
1. Go to your domain settings in Resend
2. Click on "Inbound" or "Email Forwarding"
3. Enable inbound email processing
4. Set the webhook URL to:
   ```
   https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/receive-email
   ```
5. Choose which email addresses to forward (or forward all @acnhs.am emails)

#### C. Configure MX Records (if needed)
Resend will provide MX records to add to your DNS. Add these to your domain's DNS settings:
```
Priority: 10
Value: inbound-smtp.resend.com
```

### 2. Update Email System to Show Received Emails

The inbox filter is already set to show emails where recipient is an ACNHS address. Received emails will automatically appear in the Inbox tab.

### 3. Test the Setup

1. Send an email from the email system to your personal email (Gmail, etc.)
2. Reply to that email from your personal email
3. Check the email system Inbox - the reply should appear there
4. Check Edge Function logs to verify webhook is working:
   ```
   https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/functions/receive-email/logs
   ```

## How It Works

```
Student Gmail → Resend MX Records → Resend Webhook → receive-email Function → Database → Email System Inbox
```

1. Student replies to your email from Gmail/Outlook
2. Email is sent to @acnhs.am address
3. Resend receives the email (via MX records)
4. Resend forwards email data to webhook (receive-email function)
5. Function extracts sender, recipient, subject, body
6. Function saves to `email_history` table with `status='received'`
7. Email appears in Inbox tab (filtered by ACNHS recipient addresses)

## Email History Table Structure

- **recipient**: ACNHS email address (e.g., student-services@acnhs.am)
- **sender**: External email address (e.g., student@gmail.com)
- **subject**: Email subject line
- **body**: Plain text preview (500 chars)
- **status**: 'received' for inbound emails, 'sent' for outbound
- **sent_at**: Timestamp when received

## Inbox vs Sent Logic

- **Inbox**: `recipient` is an ACNHS email (emails TO you)
- **Sent**: `sender` is an ACNHS email OR old emails with status='sent' (emails FROM you)

## Troubleshooting

### Emails not appearing in inbox
1. Check Edge Function logs for errors
2. Verify MX records are configured correctly
3. Test webhook is receiving data (check Resend logs)
4. Verify email_history table has the received emails

### Webhook authentication
The receive-email function is currently public (no auth). To add security:
1. Generate a webhook secret in Resend
2. Update the function to verify the webhook signature
3. Add the secret to Supabase secrets

## Cost Considerations

- Resend inbound emails: Check Resend pricing for inbound email limits
- May need paid Resend plan for high volume

## Alternative: Manual Email Forwarding

If you can't configure MX records:
1. Set up email forwarding rules in your email provider
2. Forward emails to a special address
3. Parse forwarded email format in the receive-email function

## Notes

- The function strips HTML from emails for preview
- Full email content could be stored in a separate table if needed
- Consider adding spam filtering
- Consider adding attachment support in the future
