-- ========================================
-- STATUS HISTORY COLUMN SETUP & FIX
-- ========================================
-- This script will:
-- 1. Create the status_history column if it doesn't exist
-- 2. Initialize status_history for ALL existing applications
-- 3. Fix any NULL values
--
-- Run this in Supabase SQL Editor
-- ========================================

-- Step 1: Create the column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'applications' 
        AND column_name = 'status_history'
    ) THEN
        -- Create the column
        ALTER TABLE applications 
        ADD COLUMN status_history JSONB DEFAULT '[]'::jsonb;
        
        -- Add comment
        COMMENT ON COLUMN applications.status_history IS 
        'Timeline of status changes with messages, timestamps, and admin info';
        
        RAISE NOTICE 'Created status_history column';
    ELSE
        RAISE NOTICE 'status_history column already exists';
    END IF;
END $$;

-- Step 2: Initialize status_history for applications where it's NULL or empty
UPDATE applications
SET status_history = jsonb_build_array(
  jsonb_build_object(
    'status', COALESCE(status, 'SUBMITTED'),
    'message', CASE 
      WHEN status_message IS NOT NULL AND status_message != '' 
      THEN status_message
      ELSE 'Application status: ' || COALESCE(status, 'SUBMITTED')
    END,
    'changed_at', COALESCE(status_updated_at, created_at, NOW())::text,
    'changed_by', 'system'
  )
)
WHERE status_history IS NULL 
   OR status_history = '[]'::jsonb
   OR jsonb_array_length(status_history) = 0;

-- Step 3: Verify the fix
SELECT 
    reference_number,
    status,
    CASE 
        WHEN status_history IS NULL THEN 'NULL'
        WHEN status_history = '[]'::jsonb THEN 'EMPTY ARRAY'
        ELSE 'HAS DATA (' || jsonb_array_length(status_history)::text || ' entries)'
    END as history_status,
    status_history
FROM applications
ORDER BY created_at DESC
LIMIT 10;

-- Expected result: All applications should show "HAS DATA (1 entries)" or more
