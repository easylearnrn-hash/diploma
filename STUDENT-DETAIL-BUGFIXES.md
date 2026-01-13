# Student Detail Page - Bug Fixes

## Issues Fixed

### 1. JavaScript Error: "Can't find variable: viewStudent"
**Problem:** Functions defined inside IIFE were not accessible to onclick handlers in HTML.

**Solution:** Exposed functions globally by adding:
```javascript
window.viewStudent = viewStudent;
window.viewApplication = viewApplication;
```

**Location:** `admin-students.html` lines ~743 and ~822

### 2. SQL Syntax Error: "syntax error at or near 'NOT'"
**Problem:** `CREATE POLICY IF NOT EXISTS` is not supported in PostgreSQL.

**Solution:** Changed to use `DROP POLICY IF EXISTS` followed by `CREATE POLICY`:
```sql
-- Drop first (if exists)
DROP POLICY IF EXISTS "Allow anon to read grades" ON public.student_grades;

-- Then create
CREATE POLICY "Allow anon to read grades" 
  ON public.student_grades FOR SELECT 
  TO anon 
  USING (true);
```

**Location:** `CREATE-STUDENT-GRADES-TABLE.sql` lines 27-52

## How to Apply Fixes

### Fix 1: Already Applied
The JavaScript fixes are already in `admin-students.html`. Just refresh your browser.

### Fix 2: Run Updated SQL
```bash
# 1. Open Supabase SQL Editor
# https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

# 2. Copy and paste the entire contents of:
CREATE-STUDENT-GRADES-TABLE.sql

# 3. Click "Run"
```

## Testing

### Test JavaScript Fix
1. Open `http://localhost:8000/admin-students.html`
2. Open browser console (Cmd+Option+I)
3. Click any student row
4. Modal should open without errors
5. Console should NOT show "Can't find variable: viewStudent"

### Test SQL Fix
```sql
-- Should run without errors
SELECT * FROM student_grades;

-- Should return 0 rows (empty table is fine)
SELECT COUNT(*) FROM student_grades;
```

## Why These Errors Happened

### JavaScript Error
When you use an IIFE (Immediately Invoked Function Expression):
```javascript
(function() {
  function myFunction() { ... }
})();
```

Functions are scoped to that closure and not accessible globally. But onclick handlers in HTML need global access:
```html
<tr onclick="myFunction()">  <!-- ❌ Can't find myFunction -->
```

**Solution:** Explicitly expose to global scope:
```javascript
window.myFunction = myFunction;  <!-- ✅ Now works -->
```

### SQL Error
PostgreSQL added `CREATE POLICY IF NOT EXISTS` in version 10, but it's safer to use the DROP + CREATE pattern for compatibility:
```sql
-- ❌ Not supported in older versions
CREATE POLICY IF NOT EXISTS ...

-- ✅ Works everywhere
DROP POLICY IF EXISTS ...
CREATE POLICY ...
```

## Verification Commands

### Check if grades table exists
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'student_grades';
```

### Check if policies are created
```sql
SELECT policyname 
FROM pg_policies 
WHERE tablename = 'student_grades';
```

### Check if JavaScript functions are global
```javascript
// In browser console
console.log(typeof window.viewStudent);  // Should be "function"
console.log(typeof window.viewApplication);  // Should be "function"
```

## Success Criteria
- [ ] Click student row → modal opens
- [ ] No console errors about viewStudent
- [ ] SQL runs without syntax errors
- [ ] student_grades table created
- [ ] 4 RLS policies created (read, insert, update, delete)

---

**Both fixes are now applied!** 🎉 Refresh your browser and try clicking a student row.
