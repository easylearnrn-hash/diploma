# Quick Deployment Guide - Manual Steps

Since the CLI login is having issues, here's the manual deployment process:

## Option 1: Deploy via Supabase Dashboard (Easiest)

1. **Go to your Supabase Dashboard**:
   https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/functions

2. **Click "Deploy a new function"**

3. **Enter function details**:
   - Name: `send-email`
   - Copy the code from: `supabase/functions/send-email/index.ts`
   - Paste it into the editor

4. **Add the CORS helper**:
   - Create a new file `_shared/cors.ts`
   - Copy code from: `supabase/functions/_shared/cors.ts`

5. **Set the environment variable**:
   - Go to: Settings → Edge Functions → Secrets
   - Add: `RESEND_API_KEY` = `re_XAWzoABQ_JEFQTya8NiHdwb4MRgEtcT3X`

6. **Deploy!**

## Option 2: CLI Deployment with Access Token

1. **Get your access token**:
   - Go to: https://supabase.com/dashboard/account/tokens
   - Generate a new token
   - Copy it

2. **Set environment variable**:
   ```bash
   export SUPABASE_ACCESS_TOKEN=your_token_here
   ```

3. **Deploy**:
   ```bash
   cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
   supabase functions deploy send-email --project-ref zlvnxvrzotamhpezqedr
   ```

4. **Set the Resend API key secret**:
   ```bash
   supabase secrets set RESEND_API_KEY=re_XAWzoABQ_JEFQTya8NiHdwb4MRgEtcT3X --project-ref zlvnxvrzotamhpezqedr
   ```

## After Deployment:

Update `/email-system.html` line 747:
```javascript
const USE_EDGE_FUNCTION = true; // Change to true
```

Then test sending an email!

---

**Which option would you prefer?**
- Option 1 is easier (copy-paste in dashboard)
- Option 2 is faster if you have the token
