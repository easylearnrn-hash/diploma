-- ========================================
-- DIAGNOSTIC: Check Status History Column
-- ========================================
-- Run this in Supabase SQL Editor to check:
-- 1. Does the column exist?
-- 2. What data does it contain?
-- 3. Is it NULL or empty?
-- ========================================

-- Step 1: Check if column exists
SELECT 
    column_name, 
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name = 'applications' 
  AND column_name = 'status_history';

-- If you see a result, the column EXISTS
-- If empty, the column DOES NOT EXIST

-- ========================================
-- Step 2: Check current data in the column
-- ========================================

SELECT 
    reference_number,
    status,
    CASE 
        WHEN status_history IS NULL THEN '❌ NULL'
        WHEN status_history::text = '[]' THEN '⚠️ EMPTY ARRAY'
        WHEN jsonb_array_length(status_history) = 0 THEN '⚠️ EMPTY ARRAY'
        ELSE '✅ HAS DATA (' || jsonb_array_length(status_history)::text || ' entries)'
    END as history_status,
    jsonb_array_length(status_history) as entry_count,
    status_history
FROM applications
ORDER BY id DESC
LIMIT 10;

-- ========================================
-- Step 3: Specific check for Vladislav
-- ========================================

SELECT 
    reference_number,
    status,
    status_message,
    status_updated_at,
    CASE 
        WHEN status_history IS NULL THEN 'NULL - Need to initialize'
        WHEN status_history::text = '[]' THEN 'EMPTY ARRAY - Need to add first entry'
        ELSE 'HAS ' || jsonb_array_length(status_history)::text || ' entries'
    END as history_info,
    status_history
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260107-799';

-- ========================================
-- EXPECTED RESULTS:
-- ========================================
--
-- IF COLUMN EXISTS:
-- Step 1 will show: status_history | jsonb | '[]'::jsonb | YES
-- Step 2 will show 10 most recent applications with their history status
-- Step 3 will show Vladislav's specific data
--
-- IF COLUMN DOES NOT EXIST:
-- Step 1 will show: (empty - no rows)
-- Step 2 will show ERROR: column "status_history" does not exist
-- Step 3 will show ERROR: column "status_history" does not exist
--
-- ========================================
