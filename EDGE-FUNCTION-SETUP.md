# Supabase Edge Function Setup for Email Sending

## 📦 What We Created

A Supabase Edge Function that acts as a secure server-side proxy to send emails via Resend API.

**Files Created:**
- `supabase/functions/send-email/index.ts` - Main edge function
- `supabase/functions/_shared/cors.ts` - CORS headers helper

---

## 🚀 Deployment Steps

### Step 1: Install Supabase CLI

If you haven't already, install the Supabase CLI:

```bash
# macOS
brew install supabase/tap/supabase

# Or using npm
npm install -g supabase
```

### Step 2: Login to Supabase

```bash
supabase login
```

This will open your browser to authenticate.

### Step 3: Link Your Project

```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
supabase link --project-ref zlvnxvrzotamhpezqedr
```

### Step 4: Set the RESEND_API_KEY Secret

```bash
supabase secrets set RESEND_API_KEY=re_XAWzoABQ_JEFQTya8NiHdwb4MRgEtcT3X
```

This stores your API key securely in Supabase (not in code).

### Step 5: Deploy the Edge Function

```bash
supabase functions deploy send-email
```

### Step 6: Verify Deployment

After deployment, you'll get a URL like:
```
https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/send-email
```

Test it with:
```bash
curl -i --location --request POST 'https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/send-email' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"to":"test@example.com","subject":"Test","html":"<p>Test email</p>"}'
```

---

## 🔧 Frontend Integration

The email system has been updated to use the Edge Function instead of calling Resend directly.

**Changes Made:**
- Removed direct Resend API calls
- Added Edge Function endpoint
- Updated `sendEmailViaResend()` to call the Edge Function

---

## ✅ Benefits

1. **Secure** - API key is never exposed to the browser
2. **CORS-friendly** - No more CORS errors
3. **Serverless** - Automatic scaling, no server management
4. **Fast** - Deployed globally on Deno Deploy edge network
5. **Integrated** - Works seamlessly with existing Supabase setup

---

## 🧪 Testing

Once deployed:
1. Refresh http://localhost:8000/email-system.html
2. The system will automatically use the Edge Function
3. Send a test email
4. Check your inbox!

---

## 📊 Monitoring

View Edge Function logs in Supabase Dashboard:
https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/functions/send-email/logs

---

## 🐛 Troubleshooting

**"Function not found"**
- Make sure you deployed: `supabase functions deploy send-email`

**"Invalid API key"**
- Check secret: `supabase secrets list`
- Reset if needed: `supabase secrets set RESEND_API_KEY=your_key`

**"Authorization required"**
- Make sure you're passing the anon key in Authorization header

---

## 📝 Notes

- The Edge Function validates email addresses
- Handles CORS automatically
- Returns structured success/error responses
- Logs errors for debugging
