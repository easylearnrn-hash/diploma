# Status History Debugging Guide

## Issue: Status History Not Showing

The console logs show:
```
🔍 DEBUG: loadStatusHistory called – {hasContainer: true, historyLength: 0, history: [], appStatus: "UNDER REVIEW"}
⚠️ No status history found for application
```

This means `status_history` is **empty or NULL** in the database for Vladislav's application.

## Why This Happens

### Scenario 1: Status Updated Before History Feature
- Vladislav's status was changed to "UNDER REVIEW" BEFORE the `status_history` column existed
- The old status update only saved to the `status` column, not `status_history`
- Solution: Update the status again (even to the same status) to create the first history entry

### Scenario 2: Column Doesn't Exist in Database
- The `status_history` column might not exist in your Supabase table
- Check SQL migration file: `ADD-STATUS-HISTORY-COLUMN.sql`
- Solution: Run the SQL migration in Supabase dashboard

### Scenario 3: NULL Value in Database
- Column exists but has NULL value instead of empty array `[]`
- PostgreSQL treats NULL differently from empty JSON array
- Solution: Initialize with empty array or update status

## Testing Steps

### 1️⃣ Test Status Update NOW
Try updating Vladislav's status right now:

1. **Open Vladislav's application** in the drawer
2. **Scroll to "📊 Status Management"** section
3. **Select any status** (can even select "UNDER REVIEW" again)
4. **Add a message**: "Testing status history - We are currently reviewing your application"
5. **Click "Update Status & Notify Applicant"**
6. **Watch the console** for these logs:

```
🔍 DEBUG: Updating application status {
  currentApplicationId: "...",
  newStatus: "UNDER REVIEW",
  statusMessage: "Testing status history...",
  currentHistoryLength: 0,    <-- Should be 0 initially
  currentHistory: []
}

🔍 DEBUG: New history entry created {
  historyEntry: {
    status: "UNDER REVIEW",
    message: "Testing status history...",
    changed_at: "2026-01-08T...",
    changed_by: "admin"
  },
  updatedHistoryLength: 1     <-- Should now be 1
}

✅ DEBUG: Status update saved to database

🔄 DEBUG: Refreshing application drawer
🔍 DEBUG: Fetched fresh status data: {
  status: "UNDER REVIEW",
  historyLength: 1,           <-- Should now be 1!
  history: [{...}]
}

🔍 DEBUG: loadStatusHistory called – {
  hasContainer: true,
  historyLength: 1,           <-- Should now show 1!
  history: [{...}],
  appStatus: "UNDER REVIEW"
}

✅ Status history rendered with 1 entries
```

7. **Check the Status History section** - should now show the timeline

### 2️⃣ Check Database Directly

Go to your Supabase dashboard:

1. Navigate to **Table Editor**
2. Open the **applications** table
3. Find Vladislav's row (reference: ACNHS-ADM-20260107-799)
4. Check the **status_history** column:
   - ❌ If it shows `NULL` → Column exists but not initialized
   - ❌ If column doesn't exist → Run SQL migration
   - ✅ If it shows `[]` or `[{...}]` → Should work after status update

### 3️⃣ Verify Column Exists

Run this query in Supabase SQL Editor:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'applications' 
AND column_name = 'status_history';
```

**Expected result:**
| column_name    | data_type |
|----------------|-----------|
| status_history | jsonb     |

**If empty:** Column doesn't exist - need to run migration

### 4️⃣ Check Current Value

Run this query to see Vladislav's current status_history:

```sql
SELECT 
  reference_number,
  status,
  status_history
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260107-799';
```

**Possible results:**
- `status_history: null` → Need to update status to initialize
- `status_history: []` → Empty array, need to add first entry
- `status_history: [{...}]` → Has data, check why UI not showing

## Solutions

### Solution A: Update Status to Initialize History
**Easiest and recommended:**

1. Open Vladislav's application
2. Update status to any value (even same one)
3. Add a message
4. Click "Update Status & Notify Applicant"
5. This creates the first history entry

### Solution B: Manually Initialize in Database
**If you want to add historical data:**

Run in Supabase SQL Editor:

```sql
UPDATE applications
SET status_history = jsonb_build_array(
  jsonb_build_object(
    'status', status,
    'message', 'Application status set to ' || status,
    'changed_at', NOW()::text,
    'changed_by', 'admin'
  )
)
WHERE reference_number = 'ACNHS-ADM-20260107-799'
AND (status_history IS NULL OR status_history = '[]'::jsonb);
```

This creates a history entry with the current status.

### Solution C: Run Migration If Column Missing
**If column doesn't exist:**

1. Open Supabase dashboard
2. Go to SQL Editor
3. Run the migration from `ADD-STATUS-HISTORY-COLUMN.sql`:

```sql
-- Add status_history column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'applications' 
        AND column_name = 'status_history'
    ) THEN
        ALTER TABLE applications 
        ADD COLUMN status_history JSONB DEFAULT '[]'::jsonb;
        
        COMMENT ON COLUMN applications.status_history IS 
        'Timeline of status changes with messages and timestamps';
    END IF;
END $$;

-- Initialize status_history for existing applications
UPDATE applications
SET status_history = jsonb_build_array(
  jsonb_build_object(
    'status', COALESCE(status, 'SUBMITTED'),
    'message', 'Initial status',
    'changed_at', COALESCE(status_updated_at, created_at)::text,
    'changed_by', 'system'
  )
)
WHERE status_history IS NULL;
```

## What to Report Back

After trying Solution A (update status), please share:

1. **Console logs** showing the complete flow
2. **Did status history appear?** Yes/No
3. **Screenshot** of the Status History section
4. **Any errors** in console

If it still doesn't work, share:
- Result of database query from Step 4️⃣
- Result of column check from Step 3️⃣

---

**Most likely cause**: Status was updated before `status_history` column existed, so it's NULL or empty. Simply updating the status now should fix it! 🎯
