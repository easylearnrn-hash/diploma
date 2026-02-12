# VID Quick Setup Guide

## 🚀 First Time Setup

### Step 1: Create the Notes Table

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard
   - Select project: `zlvnxvrzotamhpezqedr`

2. **Open SQL Editor**
   - Click "SQL Editor" in left sidebar
   - Click "New query"

3. **Copy & Run VID-SETUP.sql**
   - Open `VID-SETUP.sql` in this project
   - Copy all the SQL code
   - Paste into Supabase SQL Editor
   - Click "Run" button

4. **Verify Setup**
   - You should see: "Success. No rows returned"
   - Table `admin_private_notes` is now created

### Step 2: Start Using VID

1. **Start Local Server**
   ```bash
   python3 start-server.py
   ```

2. **Open VID**
   ```
   http://localhost:8000/VID.html
   ```

3. **You're Ready!**
   - All students will load automatically
   - Click any student card to add private notes
   - Notes are saved to your account only (hrachfilm@gmail.com)

---

## 🔧 Troubleshooting

### Error: "Notes table not found"
**Solution:** Run VID-SETUP.sql in Supabase (see Step 1 above)

### Error: "Failed to load students"
**Solution:** Check your internet connection and Supabase status

### No students showing
**Solution:** 
1. Check if `students` table has data in Supabase
2. Open browser console (F12) to see detailed errors

---

## 📝 Features

- ✅ View all students with search & filters
- ✅ Add private notes (visible only to you)
- ✅ Filter by: All, Active, Inactive, Has Notes, No Notes
- ✅ Real-time statistics dashboard
- ✅ Premium toast notifications
- ✅ Responsive design for all devices

---

## 🔒 Security

- **Git Safe**: VID.html is in .gitignore (never committed)
- **Local Only**: Runs on your laptop only
- **Private Notes**: RLS ensures only your email can see/edit notes
- **No Links**: No navigation links from other pages

---

## 🎯 Quick Commands

```bash
# Start server
python3 start-server.py

# Open VID
open http://localhost:8000/VID.html

# View SQL setup file
cat VID-SETUP.sql
```

---

Need help? Check `VID-SYSTEM-DOCUMENTATION.md` for full details.
