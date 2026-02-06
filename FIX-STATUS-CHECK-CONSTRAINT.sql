-- ============================================================================
-- FIX STATUS CHECK CONSTRAINT - Update to include all current status values
-- ============================================================================
-- Problem: Status update fails with "applications_status_check" violation
-- Solution: Drop old constraint and recreate with complete status list
-- 
-- 🔗 Run in NEW Supabase SQL Editor:
-- https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql
-- ============================================================================

-- Step 1: Drop the existing check constraint
ALTER TABLE public.applications 
DROP CONSTRAINT IF EXISTS applications_status_check;

-- Step 2: Recreate the constraint with ALL status values
ALTER TABLE public.applications 
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
    'CONFIRMED',
    'ACCEPTANCE LETTER SENT',
    'ENROLLED',
    'DENIED',
    'ON HOLD',
    'WITHDRAWN'
));

-- Step 3: Verify the constraint exists
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.applications'::regclass
    AND conname = 'applications_status_check';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current status values in use
SELECT status, COUNT(*) as count
FROM public.applications
GROUP BY status
ORDER BY count DESC;

-- Test that RFE PREPARING is now allowed (should return 0 rows if successful)
SELECT COUNT(*) 
FROM public.applications 
WHERE status = 'RFE PREPARING';
