# Email System Setup Guide

## ✅ Email System Created Successfully!

The email system has been integrated with your admin panel and is ready to use with Resend and Supabase.

---

## 📧 Resend Configuration (Already Done)

Your Resend API key is already configured in the system:
- **API Key**: `re_XAWzoABQ_JEFQTya8NiHdwb4MRgEtcT3X`
- **From Email**: `admissions@acnhs.am`

### ⚠️ Important: Verify Domain in Resend

You need to verify your domain `acnhs.am` in Resend:

1. Go to [Resend Dashboard](https://resend.com/domains)
2. Add your domain: `acnhs.am`
3. Add the DNS records provided by Resend to your domain registrar
4. Wait for verification (usually 15-30 minutes)

**Until domain is verified**, you can only send emails to verified email addresses in Resend.

---

## 🗄️ Supabase Setup Required

You need to create a new table in Supabase to store email history.

### Step 1: Create Email History Table

Run this SQL in your Supabase SQL Editor:

```sql
-- Create email_history table
CREATE TABLE email_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  recipient TEXT NOT NULL,
  subject TEXT NOT NULL,
  body TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('sent', 'failed', 'pending')),
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resend_id TEXT,
  error TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX idx_email_history_recipient ON email_history(recipient);
CREATE INDEX idx_email_history_status ON email_history(status);
CREATE INDEX idx_email_history_sent_at ON email_history(sent_at DESC);

-- Enable Row Level Security
ALTER TABLE email_history ENABLE ROW LEVEL SECURITY;

-- Create policy to allow authenticated users to read all email history
CREATE POLICY "Allow authenticated users to read email history"
  ON email_history
  FOR SELECT
  TO authenticated
  USING (true);

-- Create policy to allow authenticated users to insert email history
CREATE POLICY "Allow authenticated users to insert email history"
  ON email_history
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Grant permissions
GRANT ALL ON email_history TO authenticated;
GRANT ALL ON email_history TO service_role;
```

### Step 2: Verify Table Creation

After running the SQL:
1. Go to your Supabase Dashboard
2. Navigate to Table Editor
3. Verify the `email_history` table exists with these columns:
   - `id` (uuid, primary key)
   - `recipient` (text)
   - `subject` (text)
   - `body` (text)
   - `status` (text)
   - `sent_at` (timestamptz)
   - `resend_id` (text)
   - `error` (text)
   - `created_at` (timestamptz)

---

## 🎯 Features Included

### Email Templates
- ✅ **Acceptance Letter** - Send acceptance notifications
- ❌ **Rejection Letter** - Send rejection notifications
- 📅 **Interview Invitation** - Schedule interviews
- 📄 **Document Request** - Request missing documents
- ⏰ **Reminder** - Send application reminders
- ✏️ **Custom** - Write your own message

### Recipient Options
- **Single Applicant** - Send to one email address
- **By Status** - Send to all applicants with specific status (pending, accepted, etc.)
- **By Program** - Send to all applicants in a specific program
- **All Applicants** - Send to everyone (use with caution!)

### Email History & Stats
- View all sent emails
- Track success/failure rates
- See daily statistics
- Monitor pending emails

---

## 🚀 How to Use

1. **Access Email System**:
   - Click "Email System" in the admin sidebar
   - Or navigate to: `http://localhost:8000/email-system.html`

2. **Compose Email**:
   - Select a template or write custom message
   - Choose recipients (single, by status, by program, or all)
   - Preview before sending
   - Click "Send Email"

3. **Track Results**:
   - View stats at the top (Total Sent, Success Rate, Today's Sent)
   - Check email history at the bottom
   - See status of each email (sent/failed)

---

## 🔧 Testing

### Test with Resend Development Mode

Before domain verification, test with these steps:

1. **Add Test Email in Resend**:
   - Go to Resend Dashboard → Settings → API Keys
   - Add your email as a verified sender
   - Send test emails to your own email

2. **Send Test Email**:
   - Open Email System
   - Select "Single Applicant"
   - Enter your verified email
   - Choose template or write custom message
   - Click "Send Email"

3. **Check Results**:
   - Check your inbox (and spam folder)
   - View email in "Recent Emails" section
   - Verify stats updated correctly

---

## 📝 Next Steps

1. ✅ **Run Supabase SQL** to create email_history table
2. 🌐 **Verify Domain** in Resend (acnhs.am)
3. 📧 **Test Sending** with your own email first
4. 🎯 **Start Using** for real applicants

---

## ⚠️ Important Notes

1. **Domain Verification Required**: 
   - You can only send to verified emails until domain is verified
   - This protects against spam and ensures deliverability

2. **Rate Limits**:
   - Resend free tier: 100 emails/day
   - Upgrade for more: https://resend.com/pricing

3. **Email Content**:
   - Always preview before sending to multiple recipients
   - Personalize with [Applicant Name] placeholder
   - Test with single recipient first

4. **Data Privacy**:
   - Email history is stored in Supabase
   - Only authenticated admins can access
   - Consider GDPR/privacy compliance

---

## 🆘 Troubleshooting

### "Failed to send email"
- Check if domain is verified in Resend
- Verify API key is correct
- Check recipient email is valid

### "No recipients selected"
- Make sure applicants exist in the database
- Check filter criteria (status/program)
- Verify applications table has email addresses

### "Error saving to history"
- Verify email_history table exists in Supabase
- Check RLS policies are enabled
- Ensure user is authenticated

---

## 🎉 You're All Set!

Once you've completed the Supabase setup and domain verification, your email system will be fully operational!

Access it at: **http://localhost:8000/email-system.html**
