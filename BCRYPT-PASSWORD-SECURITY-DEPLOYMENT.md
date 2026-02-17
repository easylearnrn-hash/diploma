# 🔐 Bcrypt Password Security - Complete Deployment Guide

## ⚠️ CRITICAL SECURITY UPDATE - DEPLOY IMMEDIATELY

Your teacher passwords are currently stored in **PLAIN TEXT** in the database. This deployment will secure them using industry-standard bcrypt hashing.

---

## 📋 Current Status

### Exposed Passwords (as shown in your database query):
```
Username: test.teacher
Password: Teacher123!

Username: maria.vardanyan  
Password: 010581188
```

**⚠️ These passwords are currently visible to anyone with database access!**

---

## 🚀 Deployment Steps (15 minutes)

### Step 1: Deploy the Hash-Password Edge Function (5 min)

The Edge Function provides secure bcrypt hashing services.

```bash
# Navigate to the function directory
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/supabase/functions/hash-password"

# Deploy to Supabase
supabase functions deploy hash-password --project-ref zlvnxvrzotamhpezqedr

# Verify deployment
supabase functions list --project-ref zlvnxvrzotamhpezqedr
```

**Expected output:**
```
✓ Deployed Function: hash-password
  URL: https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/hash-password
```

---

### Step 2: Test the Edge Function (2 min)

Test that password hashing works correctly:

```bash
# Test HASH action
curl -X POST \
  'https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/hash-password' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "hash",
    "password": "TestPassword123!"
  }'

# Expected response:
# {"hash":"$2a$10$randomsaltandhashvaluehere..."}

# Test VERIFY action (use the hash from above)
curl -X POST \
  'https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/hash-password' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "verify",
    "password": "TestPassword123!",
    "hash": "$2a$10$... (paste hash from above)"
  }'

# Expected response:
# {"match":true}
```

**Find your ANON_KEY:**
- Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/settings/api
- Copy the "anon public" key

---

### Step 3: Run the Database Security Migration (3 min)

This migration:
1. ⚠️ Removes the insecure `plain_password` column
2. ✅ Adds password reset token system
3. 📊 Reports which teachers need password resets

```bash
# Open Supabase SQL Editor
# https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor

# Copy and paste the entire contents of:
# SECURE-TEACHER-PASSWORDS.sql

# Click "Run" button
```

**Expected output in console:**
```
⚠️ WARNING: plain_password column exists and will be removed!
Current teachers and their plain passwords:
Username: test.teacher, Password: Teacher123!, Email: test.teacher@acnhs.am
Username: maria.vardanyan, Password: 010581188, Email: dr.mvardanyan@acnhs.am
✅ plain_password column removed successfully

ACTION REQUIRED:
1. Note down the teachers listed above
2. Use Admin Hub to reset their passwords
3. New passwords will be automatically hashed
```

**⚠️ SAVE THE PASSWORDS SHOWN BEFORE THEY'RE DELETED!**

---

### Step 4: Reset Teacher Passwords via Admin Hub (5 min)

Now that the system is secure, reset passwords for existing teachers:

1. **Login to Admin Hub:**
   ```
   http://localhost:8000/admin-hub.html
   ```

2. **Navigate to Teachers Section:**
   - Click "Teachers" in the sidebar
   - You'll see your 2 teachers listed

3. **Reset test.teacher password:**
   - Click the edit icon (✏️) next to "Test Teacher"
   - In the "New Password" field, enter: `Teacher123!`
   - Click "Save Changes"
   - ✅ Password will be bcrypt hashed automatically
   - Console will show: `✅ Password hashed successfully`

4. **Reset maria.vardanyan password:**
   - Click the edit icon (✏️) next to "Maria Vardanyan"
   - In the "New Password" field, enter: `010581188`
   - Click "Save Changes"
   - ✅ Password will be bcrypt hashed automatically

**Note:** You can give them new passwords if you prefer. They can change them later.

---

### Step 5: Verify Password Security (2 min)

Check that passwords are now properly hashed:

```sql
-- Run in Supabase SQL Editor:
SELECT 
    username,
    full_name,
    email,
    LEFT(password_hash, 10) as hash_preview,
    CASE 
        WHEN password_hash LIKE '$2%' THEN '✓ Bcrypt Hashed'
        ELSE '✗ Plain Text - INSECURE!'
    END as security_status,
    active
FROM teachers
ORDER BY username;
```

**Expected output:**
```
username         | hash_preview   | security_status
-----------------|----------------|------------------
maria.vardanyan  | $2a$10$abc   | ✓ Bcrypt Hashed
test.teacher     | $2a$10$xyz   | ✓ Bcrypt Hashed
```

**🚨 If you see "✗ Plain Text" for any teacher, repeat Step 4 for that account!**

---

### Step 6: Test Teacher Login (1 min)

Verify that teachers can login with their bcrypt-hashed passwords:

1. **Open Teacher Login:**
   ```
   http://localhost:8000/teacher
   ```

2. **Test login for test.teacher:**
   - Username: `test.teacher`
   - Password: `Teacher123!`
   - Click "Login"
   - ✅ Should successfully login and redirect to admin-hub

3. **Test login for maria.vardanyan:**
   - Username: `maria.vardanyan`
   - Password: `010581188`
   - Click "Login"
   - ✅ Should successfully login and redirect to admin-hub

**Check browser console for:**
```
✅ Password verified successfully
```

---

## 📊 What Changed

### Database Schema
| Before | After |
|--------|-------|
| `password_hash` (plain text) | `password_hash` (bcrypt $2a$10$...) |
| `plain_password` (plain text) ⚠️ | **REMOVED** ✅ |
| No reset tokens | `teacher_password_resets` table ✅ |

### Admin Hub (admin-hub.html)
- `handleAddTeacher()`: Now calls Edge Function to hash passwords before storing
- `handleEditTeacher()`: Hashes new passwords via Edge Function
- **No more plain text storage!**

### Teacher Login (teacher.html)
- Uses Edge Function to verify bcrypt hashes instead of plain text comparison
- Secure server-side verification

### Edge Function (hash-password)
- **Hash action:** Generates bcrypt hash with salt rounds = 10
- **Verify action:** Securely compares password against hash
- Deployed at: `https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/hash-password`

---

## 🔒 Security Improvements

| Aspect | Before | After |
|--------|--------|-------|
| **Password Storage** | Plain text visible in DB ❌ | Bcrypt hashed (irreversible) ✅ |
| **Database Breach** | All passwords exposed ⚠️ | Hashes only (must be cracked) ✅ |
| **Admin Access** | Can see all passwords 👁️ | Cannot see passwords 🙈 |
| **Password Strength** | Not enforced ❌ | Can add validation ✅ |
| **Login Security** | Plain text comparison ❌ | Bcrypt timing-safe comparison ✅ |
| **Audit Trail** | None ❌ | Password reset tokens logged ✅ |

---

## 🧪 Testing Checklist

After deployment, verify:

- [ ] Edge Function deployed successfully
- [ ] `plain_password` column removed from database
- [ ] `teacher_password_resets` table created
- [ ] test.teacher password hashed (starts with `$2a$` or `$2b$`)
- [ ] maria.vardanyan password hashed
- [ ] test.teacher can login successfully
- [ ] maria.vardanyan can login successfully
- [ ] New teachers get hashed passwords automatically
- [ ] Editing teacher password updates hash correctly
- [ ] Console shows "✅ Password hashed successfully" on create/edit
- [ ] Console shows "✅ Password verified successfully" on login

---

## 🆘 Troubleshooting

### Edge Function deployment fails
```bash
# Check if logged in to Supabase CLI
supabase login

# Try deploying with verbose output
supabase functions deploy hash-password --project-ref zlvnxvrzotamhpezqedr --debug
```

### "Failed to hash password" error in Admin Hub
- Check that Edge Function is deployed: `supabase functions list`
- Check browser console for detailed error
- Verify Supabase project ref is correct: `zlvnxvrzotamhpezqedr`
- Check that `hash-password` function appears in Supabase dashboard

### Teacher login fails after migration
1. Check if password is hashed:
   ```sql
   SELECT username, password_hash FROM teachers WHERE username = 'test.teacher';
   ```
2. If hash doesn't start with `$2`, re-run Step 4 to hash the password
3. Check browser console for verification errors

### Migration says "plain_password column already removed"
- Good! The column is already secure
- Continue with Step 4 to ensure passwords are hashed

---

## 📝 Next Steps (Optional Enhancements)

### Add Password Strength Requirements
In `admin-hub.html`, before calling hash function:
```javascript
function validatePassword(password) {
  if (password.length < 8) {
    throw new Error('Password must be at least 8 characters');
  }
  if (!/[A-Z]/.test(password)) {
    throw new Error('Password must contain uppercase letter');
  }
  if (!/[a-z]/.test(password)) {
    throw new Error('Password must contain lowercase letter');
  }
  if (!/[0-9]/.test(password)) {
    throw new Error('Password must contain number');
  }
  if (!/[!@#$%^&*]/.test(password)) {
    throw new Error('Password must contain special character');
  }
}
```

### Add Password Reset Email System
Create a new Edge Function to send password reset emails:
```typescript
// supabase/functions/send-password-reset/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { teacherId, resetToken } = await req.json()
  
  // Use generate_teacher_reset_token() function
  // Send email with reset link
  // Link to password reset page
})
```

### Add Password Change History
Track when passwords are changed:
```sql
CREATE TABLE teacher_password_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teachers(id),
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    changed_by TEXT
);
```

---

## 📚 Related Files

- `supabase/functions/hash-password/index.ts` - Bcrypt Edge Function
- `SECURE-TEACHER-PASSWORDS.sql` - Database migration
- `admin-hub.html` - Teacher management (lines 8127-8280)
- `teacher.html` - Teacher login (lines 275-320)
- `ADD-TEACHERS-SYSTEM.sql` - Original schema (now outdated)
- `PASSWORD-SECURITY-WARNING.md` - Security context
- `TEACHER-SYSTEM-SETUP.md` - Teacher system documentation

---

## ✅ Deployment Complete!

Once you complete all 6 steps:

1. ✅ Passwords are bcrypt hashed
2. ✅ Plain text storage removed
3. ✅ Teachers can login securely
4. ✅ New teachers get hashed passwords
5. ✅ Password resets are secure
6. ✅ System is production-ready

**🎉 Your teacher system is now SECURE!**

---

**Last Updated:** December 2024  
**System:** Teacher Authentication with Bcrypt  
**Project:** Armenian College of Nursing & Health Sciences
