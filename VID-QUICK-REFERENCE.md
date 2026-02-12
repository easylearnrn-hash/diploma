# 🔒 VID System - Quick Reference

## 🚀 Quick Access

**Prerequisites:** Must be logged in as `hrachfilm@gmail.com`

1. Start server: `python3 start-server.py`
2. Login: `http://localhost:8000/login.html` (use hrachfilm@gmail.com)
3. Access VID: `http://localhost:8000/VID.html`

---

## 📋 One-Time Setup

### Database Setup
```sql
-- Run this in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql

-- Copy-paste entire VID-SETUP.sql file and click "Run"
```

### Verify Security
```bash
# Run security test
./test-vid-security.sh

# Expected: "✅ ALL SECURITY TESTS PASSED!"
```

---

## 🔐 Security Checklist

- ✅ VID.html in .gitignore
- ✅ Not tracked by Git
- ✅ No UI links to VID.html
- ✅ RLS policies active in Supabase
- ✅ Only hrachfilm@gmail.com can access

---

## 💡 Features

**Search:** Filter by name, ID, email, phone, program  
**Notes:** Private notes per student (unlimited length)  
**Indicators:** 📝 icon shows which students have notes  
**Auto-save:** Click "💾 Save Notes" to persist  
**Stats:** See total students and notes count  

---

## 🛠️ Common Tasks

### Create Note
1. Click student card
2. Type in textarea
3. Click "💾 Save Notes"

### Edit Note
1. Click student card (note loads automatically)
2. Modify text
3. Click "💾 Save Notes"

### Search Students
Type in search bar: name, ID, email, phone, or program

### View All Notes
Students with notes show 📝 icon in top-right corner

---

## 🐛 Quick Fixes

### Can't Access Page
- Go to `login.html` first
- Login as `hrachfilm@gmail.com`
- Then navigate to `VID.html`

### Notes Not Saving
- Check browser console (F12)
- Verify VID-SETUP.sql was run in Supabase
- Confirm server is running

### Access Denied
- Clear sessionStorage: `sessionStorage.clear()`
- Login again at `login.html`
- Must use exact email: `hrachfilm@gmail.com`

---

## 📊 Database Queries

### View All Your Notes
```sql
SELECT student_id, notes, updated_at
FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com'
ORDER BY updated_at DESC;
```

### Count Notes
```sql
SELECT COUNT(*) as total_notes
FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com';
```

### Delete Specific Note
```sql
DELETE FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com'
  AND student_id = 'ACNHS-XXXXXXXXX';
```

---

## ⚠️ Important Reminders

**NEVER:**
- Commit VID.html to Git
- Link VID.html in any UI
- Share VID.html URL
- Deploy to production
- Remove from .gitignore

**ALWAYS:**
- Keep it local only
- Verify .gitignore before commits
- Use for personal notes only
- Check Git status regularly

---

## 📞 Emergency Commands

### Remove from Git (if accidentally committed)
```bash
git rm --cached VID.html
git commit -m "Remove VID.html from tracking"
```

### Verify Git Ignores It
```bash
git status | grep VID.html
# Should return nothing
```

### Backup All Notes
```sql
-- Run in Supabase, then copy results
SELECT * FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com';
```

---

## 📁 Files Created

- `VID.html` - Main interface (🚫 NEVER COMMIT)
- `VID-SETUP.sql` - Database setup (✅ commit this)
- `VID-SYSTEM-DOCUMENTATION.md` - Full docs (✅ commit this)
- `VID-QUICK-REFERENCE.md` - This file (✅ commit this)
- `test-vid-security.sh` - Security test script (✅ commit this)

---

## 🎯 Keyboard Shortcuts

- **ESC** - Close student modal
- **Click outside modal** - Close modal
- **Type in search** - Auto-filter students

---

**System Version:** 1.0  
**Last Updated:** February 12, 2026  
**Access Level:** CONFIDENTIAL - hrachfilm@gmail.com ONLY
