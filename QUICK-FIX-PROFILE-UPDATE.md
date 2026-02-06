# 🚀 QUICK FIX - Run This SQL Now!

## Problem
- ❌ Error: "column update_type does not exist"
- ❌ Supporting documents dropdown empty
- ❌ Modal opens in top-left instead of center

## ✅ Solutions Applied

### 1. Database Fix (RUN THIS SQL)
```sql
-- Copy and paste ADD-PROFILE-UPDATE-COLUMNS.sql into Supabase SQL Editor
-- URL: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor
```

This script will:
- ✅ Add missing columns (update_type, urgency, reason, form_data, supporting_documents_files)
- ✅ Add proper constraints and indexes
- ✅ Work even if some columns already exist (uses IF NOT EXISTS checks)

### 2. Modal Centering Fixed ✅
Added to CSS:
```css
.modal {
  position: relative;
  margin: 0;
  border: none;
}

.modal::backdrop {
  display: none;
}
```

Modal now perfectly centered using flexbox on `.modal-backdrop.active{display:flex}`

### 3. Supporting Documents Fixed ✅
- Documents dropdown now hidden by default (`display:none`)
- Shows only when update type is selected
- Populated dynamically with relevant documents for each type

## Testing Steps

### Step 1: Run SQL Migration
1. Open: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor
2. Copy entire content of `ADD-PROFILE-UPDATE-COLUMNS.sql`
3. Paste into SQL Editor
4. Click **RUN**
5. You should see a table showing all columns

### Step 2: Test the Form
1. Open Student Portal: http://localhost:8000/Student-page.html
2. Click "Request Official Update" button
3. **Check modal position:** Should be centered on screen ✅
4. Select "Name Change" from dropdown
5. **Check documents dropdown:** Should show marriage cert, passport, etc. ✅
6. Upload a test file (PDF or image)
7. Fill out form and submit

### Step 3: Verify Database
```sql
-- Check that columns exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profile_update_requests'
ORDER BY ordinal_position;

-- Test insert
INSERT INTO profile_update_requests (
  student_id, student_email, update_type, urgency, reason,
  form_data, description
) VALUES (
  'ACNHS-TEST',
  'test@acnhs.am',
  'name_change',
  'standard',
  'Test request',
  '{"current_name":"Test User"}'::jsonb,
  'TEST: Name change request'
);

-- View result
SELECT * FROM profile_update_requests ORDER BY submitted_at DESC LIMIT 1;
```

## What Each Update Type Shows

| Update Type | Supporting Documents Dropdown |
|-------------|------------------------------|
| **Name Change** | Marriage Certificate (required), Divorce Decree, Court Order, Passport, ID Card |
| **Name Correction** | Passport (required), Birth Certificate (required), National ID, Baptism Certificate |
| **Contact Info** | Utility Bill, Phone Bill, Email Verification |
| **Emergency Contact** | Contact ID, Relationship Proof |
| **Address** | Utility Bill (required), Bank Statement, Lease Agreement, Residence Certificate |
| **Citizenship** | Passport (required), Citizenship Certificate, Naturalization Certificate, ID Card |
| **Date of Birth** | Birth Certificate (required), Passport (required), Baptism Certificate, ID Card |
| **Other** | Relevant Document, Official Letter, Other |

## Troubleshooting

### If modal still opens in top-left:
1. Hard refresh browser (Cmd+Shift+R or Ctrl+Shift+R)
2. Clear browser cache
3. Check browser console for CSS errors

### If documents still not showing:
1. Open browser console (F12)
2. Type: `SUPPORTING_DOCS_MAP`
3. Should show object with all document types
4. Type: `handleUpdateTypeChange()`
5. Should hide/show relevant sections

### If SQL fails:
- Error about existing columns? That's OK - the script handles it
- Error about existing constraints? Run this first:
```sql
ALTER TABLE profile_update_requests 
DROP CONSTRAINT IF EXISTS profile_update_requests_update_type_check;

ALTER TABLE profile_update_requests 
DROP CONSTRAINT IF EXISTS profile_update_requests_urgency_check;

ALTER TABLE profile_update_requests 
DROP CONSTRAINT IF EXISTS profile_update_requests_status_check;
```

Then re-run `ADD-PROFILE-UPDATE-COLUMNS.sql`

---

## Files to Use
1. **RUN IN SUPABASE:** `ADD-PROFILE-UPDATE-COLUMNS.sql` ← RUN THIS NOW!
2. **Reference:** `CREATE-PROFILE-UPDATE-REQUESTS-TABLE.sql` (for new tables)
3. **Student-page.html** - Already updated with centering fix

**Status:** Ready to test! 🎉
**Estimated time:** 2 minutes to run SQL + test
