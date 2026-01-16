# 🚀 Email Forwarding - Quick Setup Guide

## ⚡ 3-Step Setup (5 minutes)

### Step 1: Run SQL Migration (2 min)
1. Open Supabase Dashboard: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor
2. Click **"SQL Editor"** in left sidebar
3. Click **"New Query"**
4. Copy contents of `ADD-EMAIL-FORWARDING-COLUMNS.sql`
5. Paste and click **"Run"** (or press `Ctrl+Enter`)
6. ✅ You should see: "Email forwarding columns added successfully!"

### Step 2: Verify Edge Function (Already Done! ✅)
The Edge Function has been deployed with auto-forwarding logic:
```bash
✅ Deployed Functions on project zlvnxvrzotamhpezqedr: send-email
```

### Step 3: Test the Feature (1 min)
1. Open `http://localhost:8000/email-system.html`
2. Click **"⤴️ Forwarding"** button in header
3. Enable forwarding and enter your email
4. Save settings
5. ✅ Done!

---

## 📧 How to Use After Setup

### Enable Forwarding
```
1. Click "⤴️ Forwarding" button
2. Check "Enable Email Forwarding"
3. Enter: your.personal@gmail.com
4. Click "💾 Save Settings"
```

### Test It Works
```
1. Send test email to your @acnhs.am address
2. Check your personal email inbox
3. You should receive forwarded email with "Fwd:" prefix
```

---

## 🔧 Files Created/Modified

- ✅ `ADD-EMAIL-FORWARDING-COLUMNS.sql` - Database migration
- ✅ `email-system.html` - UI modal and JavaScript functions
- ✅ `supabase/functions/send-email/index.ts` - Auto-forward logic (deployed)
- ✅ `EMAIL-FORWARDING-SYSTEM.md` - Full documentation

---

## 🎯 What This Does

**When Enabled:**
- Incoming emails to your @acnhs.am addresses are automatically forwarded
- You receive them in your personal inbox
- You can reply directly (reply goes to original sender)
- Original email still appears in ACNHS email system

**When Disabled:**
- Emails only appear in ACNHS email system
- No forwarding occurs

---

## ✅ Ready to Use!

The feature is **production-ready** after running Step 1 (SQL migration).

**Questions?** See full documentation in `EMAIL-FORWARDING-SYSTEM.md`
