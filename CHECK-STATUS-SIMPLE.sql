-- ========================================
-- SIMPLIFIED DIAGNOSTIC
-- ========================================
-- This will show exactly what columns exist
-- and what data is in status_history
-- ========================================

-- Step 1: Show all column names in applications table
SELECT column_name, data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name = 'applications'
ORDER BY ordinal_position;

-- Step 2: Check status_history column specifically
SELECT 
    EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public'
          AND table_name = 'applications' 
          AND column_name = 'status_history'
    ) as column_exists;

-- Step 3: Check data for all applications (simple query)
SELECT 
    id,
    reference_number,
    status,
    status_history
FROM applications
LIMIT 10;

-- Step 4: Check Vladislav specifically
SELECT 
    id,
    reference_number,
    status,
    status_message,
    status_history
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260107-799';
