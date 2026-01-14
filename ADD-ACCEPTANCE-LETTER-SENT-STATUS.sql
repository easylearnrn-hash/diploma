-- Add "ACCEPTANCE LETTER SENT" to the applications status check constraint
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor

-- First, drop the existing constraint
ALTER TABLE applications 
DROP CONSTRAINT IF EXISTS applications_status_check;

-- Recreate the constraint with the new status included
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

-- Verify the constraint was updated
SELECT 
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'applications'::regclass
  AND conname = 'applications_status_check';
