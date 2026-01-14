# Add "ACCEPTANCE LETTER SENT" Status to Database

## Problem
When trying to set application status to "ACCEPTANCE LETTER SENT", you get this error:
```
❌ Update Failed
new row for relation "applications" violates check constraint "applications_status_check"
```

This happens because the database has a CHECK constraint that only allows specific status values, and "ACCEPTANCE LETTER SENT" wasn't included.

## Solution
Run the SQL migration to update the constraint.

## Steps

### 1. Open Supabase SQL Editor
Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor

### 2. Run the Migration
Copy and paste this SQL:

```sql
-- Drop the existing constraint
ALTER TABLE applications 
DROP CONSTRAINT IF EXISTS applications_status_check;

-- Recreate with new status
ALTER TABLE applications 
ADD CONSTRAINT applications_status_check 
CHECK (status IN (
  'SUBMITTED',
  'UNDER REVIEW',
  'ACTIVELY REVIEWING',
  'RFE PREPARING',
  'RFE SENT',
  'ADDITIONAL DOCUMENTS REQUESTED',
  'DOCUMENTS RECEIVED',
  'FINAL REVIEW',
  'APPROVED',
  'ACCEPTANCE LETTER SENT',
  'DENIED',
  'ON HOLD',
  'WITHDRAWN'
));
```

### 3. Verify
Run this to confirm the constraint was updated:

```sql
SELECT 
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'applications'::regclass
  AND conname = 'applications_status_check';
```

You should see "ACCEPTANCE LETTER SENT" in the list of allowed values.

### 4. Test
Try updating an application status to "ACCEPTANCE LETTER SENT" in the admin dashboard. It should now work! ✅

## Technical Details

**Constraint Name:** `applications_status_check`  
**Table:** `applications`  
**Column:** `status`  
**Type:** CHECK constraint (validates enum-like values)

**New Status Added:** `ACCEPTANCE LETTER SENT`  
**Icon:** 📬  
**Purpose:** Indicates that the official acceptance letter has been emailed to the student

## Related Files
- `ADD-ACCEPTANCE-LETTER-SENT-STATUS.sql` - The migration file
- `application-status.html` - Frontend status definitions
- `admin-applications.html` - Admin dashboard status options and templates
