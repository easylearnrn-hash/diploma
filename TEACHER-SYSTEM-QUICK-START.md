# Teacher System - Quick Deployment Guide

## 🚀 Deployment Steps (5 Minutes)

### 1. Database Setup
```bash
# Open Supabase SQL Editor
https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

# Copy and paste: ADD-TEACHERS-SYSTEM.sql
# Click "Run"
```

### 2. Verify Installation
```sql
-- Check tables exist
SELECT COUNT(*) FROM teachers;
SELECT COUNT(*) FROM teacher_group_assignments;
```

### 3. Test Teacher Login
```
URL: http://localhost:8000/teacher.html
Username: test.teacher
Password: Teacher123!
```

### 4. Admin Operations
```
1. Login as admin
2. Navigate to "👨‍🏫 Teachers" section
3. Create new teacher account
4. Assign groups (A, B, C, D)
5. Set role title
```

---

## ✅ What's Implemented

### Files Created
- ✅ `ADD-TEACHERS-SYSTEM.sql` - Database schema & RLS policies
- ✅ `teacher.html` - Teacher login page
- ✅ `admin-hub.html` (updated) - Teacher management UI + role restrictions
- ✅ `TEACHER-SYSTEM-SETUP.md` - Comprehensive documentation

### Features
- ✅ Teacher login at `/teacher`
- ✅ Role-based access control
- ✅ Group-based student filtering
- ✅ Teacher CRUD operations (Admin only)
- ✅ Automatic email copying to teachers
- ✅ Session management
- ✅ Permission enforcement

---

## 🔑 Test Credentials

### Teacher Account
```
URL: /teacher
Username: test.teacher
Password: Teacher123!
Group: A
```

### Admin Account
```
URL: /login
Email: hrachfilm@gmail.com or s.gharibyan@acnhs.am
```

---

## 🎯 Key URLs

- **Teacher Login:** `https://www.acnhs.am/teacher`
- **Admin Hub:** `https://www.acnhs.am/admin-hub`
- **Database:** https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr

---

## 📊 Database Schema

```
teachers
├── id (UUID)
├── full_name (TEXT)
├── email (TEXT UNIQUE)
├── username (TEXT UNIQUE)
├── password_hash (TEXT)
├── plain_password (TEXT)
├── active (BOOLEAN)
├── created_at (TIMESTAMPTZ)
├── updated_at (TIMESTAMPTZ)
├── created_by (TEXT)
└── last_login (TIMESTAMPTZ)

teacher_group_assignments
├── id (UUID)
├── teacher_id (UUID → teachers.id)
├── group_id (TEXT)
├── role_title (TEXT)
├── assigned_at (TIMESTAMPTZ)
└── assigned_by (TEXT)
```

---

## 🔒 Permissions Matrix

| Feature | Admin | Teacher |
|---------|-------|---------|
| View all students | ✅ | ❌ (Only assigned groups) |
| Manage teachers | ✅ | ❌ |
| Add/edit grades | ✅ | ✅ (Assigned groups only) |
| Manage attendance | ✅ | ✅ (Assigned groups only) |
| Post notes | ✅ | ✅ |
| System settings | ✅ | ❌ |
| View applications | ✅ | ❌ |
| Generate reports | ✅ | ❌ |

---

## 🎓 Teacher Workflow

1. **Teacher receives credentials** from admin
2. **Logs in at** `/teacher`
3. **Redirected to** `/admin-hub`
4. **Sees only assigned groups** in all views
5. **Can manage** grades, attendance, notes for their groups
6. **Receives email copies** when emails sent to their groups

---

## 📧 Email Integration

When sending emails to a group:
```javascript
// Automatically includes assigned teachers
Group A → 25 students + 2 teachers = 27 total recipients
From: hub@acnhs.am
```

---

## 🐛 Troubleshooting

### Teacher can't login
```sql
-- Check account status
SELECT username, active, plain_password FROM teachers WHERE username = 'test.teacher';

-- Solution: Verify active = true
```

### Teacher sees wrong groups
```javascript
// Clear session and re-login
sessionStorage.clear();
window.location.href = 'teacher.html';
```

### Teachers not receiving emails
```sql
-- Verify assignments
SELECT * FROM teacher_group_assignments WHERE group_id = 'A';

-- Check active status
SELECT email, active FROM teachers WHERE active = true;
```

---

## 📞 Quick Reference

**Documentation:** `TEACHER-SYSTEM-SETUP.md`  
**SQL Migration:** `ADD-TEACHERS-SYSTEM.sql`  
**Teacher Login:** `teacher.html`  
**Admin Hub:** `admin-hub.html`

---

**Status:** ✅ Ready for Production  
**Version:** 1.0  
**Date:** February 17, 2026
