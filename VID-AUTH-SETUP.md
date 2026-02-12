# 🔐 VID Authentication Setup

## ✅ What's Been Added

VID now requires login to access! Features:
- ✅ Secure login screen with email/password
- ✅ Session management (stays logged in)
- ✅ Logout button in navigation
- ✅ Shows logged-in user's email
- ✅ Uses Supabase Auth (secure & reliable)

## 🚀 Setup Steps

### Step 1: Enable Email Auth in Supabase

1. Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/auth/providers
2. Click on **"Email"** provider
3. Make sure these are enabled:
   - ✅ **Enable Email provider**
   - ✅ **Enable Email Signup** (if you want to create users via signup form)
4. Under **Email Templates**, you can customize the confirmation email (optional)

### Step 2: Create Your First Admin User

#### Option A: Via Supabase Dashboard (Easiest)

1. Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/auth/users
2. Click **"Add user"** → **"Create new user"**
3. Fill in:
   - **Email:** `Hrachfilm@gmail.com` (or your email)
   - **Password:** Choose a strong password (min 6 characters)
   - **Auto Confirm User:** ✅ YES (check this!)
4. Click **"Create user"**

#### Option B: Via SQL (Advanced)

Run this in Supabase SQL Editor (https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new):

```sql
-- Create admin user (replace with your email/password)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  confirmation_token,
  is_sso_user
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'Hrachfilm@gmail.com',  -- Your email
  crypt('YourSecurePassword123', gen_salt('bf')),  -- Your password
  NOW(),
  NOW(),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  '',
  false
);
```

### Step 3: Test VID Login

1. Open VID: https://easylearnrn-hash.github.io/diploma/VID.html
2. You should see a login screen 🔐
3. Enter your email and password
4. Click **"Sign In"**
5. You should see the VID dashboard!

### Step 4: Add More Users (Optional)

To add more authorized users, repeat Step 2 with different emails.

**Recommended users:**
- Your email: `Hrachfilm@gmail.com`
- Backup admin: `admin@acnhs.edu`
- Other staff members as needed

## 🔧 How It Works

### Security Flow:
1. User opens VID → Checks if logged in
2. **Not logged in** → Shows login screen
3. **Logged in** → Shows dashboard with student data
4. Session persists (stays logged in even after closing browser)
5. **Logout button** → Clears session and redirects to login

### What's Protected:
- ✅ All student data
- ✅ Student notes
- ✅ Export functionality
- ✅ Full VID dashboard

### Session Management:
- Sessions last **1 week** by default
- Auto-refresh (stays logged in)
- Secure token-based authentication
- Works across devices (login once per device)

## 📱 Mobile Experience

### iOS Safari:
1. Open: https://easylearnrn-hash.github.io/diploma/VID.html
2. Login with credentials
3. Add to Home Screen for app-like experience
4. Stays logged in!

### Password Manager Support:
- Works with iCloud Keychain
- Works with 1Password, LastPass, etc.
- Browser auto-fill enabled

## 🔒 Security Features

✅ **Encrypted passwords** - Uses bcrypt hashing
✅ **Secure sessions** - Token-based auth
✅ **HTTPS only** - GitHub Pages enforces SSL
✅ **Rate limiting** - Built into Supabase Auth
✅ **No data leakage** - Must login to see anything

## ⚙️ Advanced Configuration

### Change Session Duration

In Supabase Dashboard → Authentication → Settings:
- **JWT Expiry:** Default is 3600 seconds (1 hour)
- **Refresh Token Rotation:** Enabled for security

### Email Confirmation (Optional)

If you want users to confirm email before login:
1. Go to: Auth → Providers → Email
2. Uncheck **"Confirm email"**
3. Users get confirmation email before they can login

### Password Requirements

Default Supabase requirements:
- Minimum 6 characters
- No maximum length
- Can contain any characters

To enforce stronger passwords, add validation in login form.

## 🧪 Testing

### Test Login Flow:
```bash
# 1. Open VID (should show login)
open https://easylearnrn-hash.github.io/diploma/VID.html

# 2. Try logging in with your credentials

# 3. Check browser console for auth logs
```

### Test Logout:
1. Click the 🚪 **Logout** button in top-right
2. Should return to login screen
3. Try accessing VID again (should require login)

### Test Session Persistence:
1. Login to VID
2. Close browser completely
3. Open VID again (should still be logged in!)

## 🐛 Troubleshooting

### Issue: "Invalid email or password"
**Solutions:**
- Check email is correct (case-sensitive)
- Check password is correct
- Verify user exists in Supabase Auth → Users
- Make sure **"Auto Confirm User"** was checked when creating

### Issue: Login screen loops back to login
**Solutions:**
- Clear browser cookies/cache
- Check Supabase project is running
- Check browser console for errors
- Verify Supabase URL is correct in `js/supabase-config.js`

### Issue: "Session not found"
**Solutions:**
- User may have been deleted from Supabase
- Session expired (login again)
- Browser blocking cookies (check settings)

### Issue: Can't see logout button
**Solutions:**
- Check if `logoutBtn` element exists in HTML
- Clear cache and reload
- Check browser console for JavaScript errors

## 🔄 Updating VID

After making changes to VID.html:

```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
git add VID.html
git commit -m "Update VID with auth"
git push origin main
```

Changes go live in 1-2 minutes on:
https://easylearnrn-hash.github.io/diploma/VID.html

## 📋 Quick Reference

### Admin URLs:
- **Supabase Dashboard:** https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr
- **Auth Users:** https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/auth/users
- **Auth Settings:** https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/auth/providers

### VID URLs:
- **Live Site:** https://easylearnrn-hash.github.io/diploma/VID.html
- **GitHub Repo:** https://github.com/easylearnrn-hash/diploma

### Default Credentials (After Setup):
```
Email: Hrachfilm@gmail.com
Password: [The password you set in Step 2]
```

---

**🎉 VID is now secure! Only authorized users can access it from anywhere in the world!**
