# 🔐 PASSWORD SECURITY - QUICK REFERENCE

## ⚡ Quick Deploy (Automated)

```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
./deploy-password-security.sh
```

**The script will:**
1. ✅ Check Supabase CLI
2. ✅ Deploy Edge Function
3. ✅ Test the function
4. ✅ Guide you through database migration
5. ✅ Guide you through password resets
6. ✅ Test teacher logins

**Time:** ~15 minutes

---

## 📋 Manual Deploy (Step by Step)

### 1. Deploy Edge Function
```bash
cd supabase/functions/hash-password
supabase functions deploy hash-password --project-ref zlvnxvrzotamhpezqedr
```

### 2. Run SQL Migration
- Open: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor
- Copy/paste: `SECURE-TEACHER-PASSWORDS.sql`
- Click "Run"

### 3. Reset Passwords in Admin Hub
- Go to: http://localhost:8000/admin-hub.html
- Teachers → Edit → Set new password → Save
- Repeat for both teachers

### 4. Test Login
- Go to: http://localhost:8000/teacher
- Login with username/password
- Check console for: `✅ Password verified successfully`

---

## 🆘 Quick Troubleshooting

### Edge Function not working?
```bash
supabase functions list --project-ref zlvnxvrzotamhpezqedr
# Should show: hash-password
```

### Teachers can't login?
```sql
-- Check if passwords are hashed
SELECT username, LEFT(password_hash, 10) as hash FROM teachers;
-- Hash should start with: $2a$ or $2b$
```

### Need to re-hash a password?
1. Admin Hub → Teachers → Edit teacher
2. Enter new password in "New Password" field
3. Save Changes
4. Password automatically hashed

---

## 📊 Current Teacher Passwords

**Before migration (save these):**
- `test.teacher` → `Teacher123!`
- `maria.vardanyan` → `010581188`

**After migration:**
- Reset using Admin Hub (Step 3 above)
- Use same passwords or create new ones

---

## ✅ Verification Checklist

- [ ] Edge Function deployed
- [ ] SQL migration completed
- [ ] `plain_password` column removed
- [ ] test.teacher password hashed
- [ ] maria.vardanyan password hashed
- [ ] test.teacher can login
- [ ] maria.vardanyan can login
- [ ] New teacher creation hashes password
- [ ] Password edit hashes password

---

## 📚 Full Documentation

| File | Purpose |
|------|---------|
| `BCRYPT-PASSWORD-SECURITY-DEPLOYMENT.md` | Complete step-by-step guide |
| `PASSWORD-SECURITY-COMPLETE.md` | Implementation summary |
| `SECURE-TEACHER-PASSWORDS.sql` | Database migration script |
| `supabase/functions/hash-password/index.ts` | Bcrypt Edge Function |
| `deploy-password-security.sh` | Automated deployment script |
| `PASSWORD-SECURITY-WARNING.md` | Original security issue |

---

## 🔒 Security Status

| Aspect | Status |
|--------|--------|
| Password Storage | Plain Text → Bcrypt Hashed ✅ |
| Database Column | `plain_password` removed ✅ |
| Teacher Creation | Auto-hashed ✅ |
| Teacher Login | Bcrypt verification ✅ |
| Password Edits | Auto-hashed ✅ |
| Production Ready | YES ✅ |

---

**Last Updated:** December 2024  
**Status:** Ready to Deploy  
**Priority:** CRITICAL SECURITY FIX
