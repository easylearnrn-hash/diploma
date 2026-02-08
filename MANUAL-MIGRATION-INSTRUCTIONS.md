# CRITICAL: Manual Migration Instructions

## Problem
The OLD project (zlvnxvrzotamhpezqedr) returns 401 Unauthorized - either:
1. The anon key has expired/changed
2. RLS policies are blocking anonymous access
3. The project has been locked/restricted

## Solution: SQL Export/Import

### Step 1: Export from OLD Project (zlvnxvrzotamhpezqedr)

1. Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr
2. Click **SQL Editor** (left sidebar)
3. Run this query to export ALL applications:

```sql
-- Get ALL applications
SELECT * FROM applications ORDER BY submission_date DESC;
```

4. Click the **Download as CSV** button in the results
5. Save the file as `applications_export.csv`

### Step 2: Repeat for Other Tables

Export these tables in the same way:

```sql
-- Export registrations (waiting list)
SELECT * FROM registrations ORDER BY registration_date DESC;
```
Save as: `registrations_export.csv`

```sql
-- Export students
SELECT * FROM students ORDER BY created_at DESC;
```
Save as: `students_export.csv`

```sql
-- Export enrollment questionnaires
SELECT * FROM enrollment_questionnaires ORDER BY created_at DESC;
```
Save as: `questionnaires_export.csv`

### Step 3: Import to NEW Project (eyhksbiceueoiamwnqpr)

1. Go to: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr
2. Click **Table Editor** (left sidebar)
3. Select the `applications` table
4. Click **Insert** → **Insert from CSV**
5. Upload `applications_export.csv`
6. Map the columns (should auto-detect)
7. Click **Import**

### Step 4: Repeat Import for Other Tables

Repeat Step 3 for:
- `registrations_export.csv` → `registrations` table
- `students_export.csv` → `students` table  
- `questionnaires_export.csv` → `enrollment_questionnaires` table

### Step 5: Verify Migration

Run this in NEW project SQL Editor:

```sql
-- Count records in each table
SELECT 'applications' as table_name, COUNT(*) as count FROM applications
UNION ALL
SELECT 'registrations', COUNT(*) FROM registrations
UNION ALL
SELECT 'students', COUNT(*) FROM students
UNION ALL
SELECT 'enrollment_questionnaires', COUNT(*) FROM enrollment_questionnaires;
```

### Alternative: Get Correct OLD Project Anon Key

If you want to use the automated migration tool:

1. Go to OLD project: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr
2. Click **Settings** → **API** (left sidebar)
3. Copy the **anon public** key
4. Update `migrate-applications.html` line 138 with the correct key
5. Reload page and try migration again

## Current Status

- ✅ NEW project accessible (52 applications already exist)
- ❌ OLD project returns 401 (need correct anon key or use CSV export)
