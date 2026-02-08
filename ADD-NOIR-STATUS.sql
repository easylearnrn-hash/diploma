-- Add 'NOIR' (Notice of Intention to Refuse) status to applications table
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql

-- Step 1: Drop existing check constraint
ALTER TABLE applications 
DROP CONSTRAINT IF EXISTS applications_status_check;

-- Step 2: Add new check constraint with NOIR included
ALTER TABLE applications
ADD CONSTRAINT applications_status_check
CHECK (status IN (
    'SUBMITTED',
    'UNDER REVIEW',
    'ACTIVELY REVIEWING',
    'RFE PREPARING',
    'RFE SENT',
    'NOIR',
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

-- Verification query
SELECT DISTINCT status FROM applications ORDER BY status;
