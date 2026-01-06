# 🚨 REGISTRATIONS NOT SHOWING? HERE'S WHY

## The Problem
You successfully submitted a registration, but it's not appearing in the admin "Waiting List" tab.

## The Cause
The `registrations` table doesn't exist in your Supabase database yet. The registration data was submitted but had nowhere to be saved.

## The Solution

### ✅ Step 1: Run the SQL Setup
1. Open **RUN-THIS-SQL-FIRST.md** (in this folder)
2. Follow the instructions to create the table in Supabase
3. Takes less than 2 minutes!

### ✅ Step 2: Test Again
1. Go to `http://localhost:8000/login.html`
2. Click "Register" button
3. Fill out the form and submit
4. You should see a success modal
5. Close the modal (redirects to homepage)

### ✅ Step 3: Check Admin Panel
1. Go to `http://localhost:8000/admin-home.html`
2. Click "Applications" in the sidebar
3. Switch to "Waiting List" tab
4. Click "Refresh" button
5. You should now see your registration! 🎉

---

## Quick Links

- **SQL Instructions:** [RUN-THIS-SQL-FIRST.md](./RUN-THIS-SQL-FIRST.md)
- **Supabase Dashboard:** https://supabase.com/dashboard
- **Test Registration:** http://localhost:8000/login.html
- **Admin Panel:** http://localhost:8000/admin-home.html

---

## Important Notes

⚠️ **Old Registrations Won't Appear**
- Registrations submitted BEFORE running the SQL won't be saved
- Only NEW registrations (after running SQL) will appear

✅ **After Running SQL**
- Registration form will save data properly
- Admin panel will show all registrations
- Status can be changed (pending/contacted/approved/rejected)
- Full registration details in side drawer

🔄 **Already Ran SQL?**
- If you already ran the SQL and registrations still don't show:
  1. Open browser console (F12)
  2. Look for errors when clicking "Refresh"
  3. Check if error says "table doesn't exist" or something else
  4. Contact support if issue persists

---

## How to Tell If SQL Was Run

### Method 1: Check Admin Panel
- Go to Waiting List tab
- Click "Refresh"
- If you see "Table Not Found" → SQL not run yet
- If you see "0 registrations found" → SQL was run successfully!

### Method 2: Check Supabase
- Open Supabase Dashboard
- Go to "Table Editor"
- Look for "registrations" table in the list
- If it's there → SQL was run successfully!

---

Need help? Check the console logs or contact the administrator.
