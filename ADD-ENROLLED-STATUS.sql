-- ========================================
-- ADD ENROLLED/CONFIRMED APPLICATION STATUS SUPPORT
-- Run this in the Supabase SQL Editor for project zlvnxvrzotamhpezqedr
-- ========================================

BEGIN;

-- Normalize legacy values so they pass the new constraint
UPDATE public.applications
SET status = 'SUBMITTED'
WHERE status = 'Pending Review';

-- Ensure the default matches the statuses used by the application portal
ALTER TABLE public.applications
ALTER COLUMN status SET DEFAULT 'SUBMITTED';

-- Rebuild the status check constraint with the complete list of allowed values
ALTER TABLE public.applications
DROP CONSTRAINT IF EXISTS applications_status_check;

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

COMMIT;

-- Verify the constraint definition
SELECT 
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.applications'::regclass
  AND conname = 'applications_status_check';
