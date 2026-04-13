-- ============================================================
-- ADD ACTIVE STUDENT STATUS & RESPONSE TRACKING
-- Run this in the Supabase SQL Editor
-- Project: eyhksbiceueoiamwnqpr
-- ============================================================

-- 1. Add active_student_semester column
ALTER TABLE public.applications
  ADD COLUMN IF NOT EXISTS active_student_semester TEXT;

-- 2. Add active_student_response column (YES or NO, set by student)
ALTER TABLE public.applications
  ADD COLUMN IF NOT EXISTS active_student_response TEXT
  CHECK (active_student_response IN ('YES', 'NO'));

-- 3. Drop the existing status CHECK constraint so we can add ACTIVE STUDENT
DO $$
DECLARE
  v_constraint TEXT;
BEGIN
  SELECT conname INTO v_constraint
  FROM pg_constraint c
  JOIN pg_class t ON t.oid = c.conrelid
  WHERE t.relname = 'applications'
    AND c.contype = 'c'
    AND pg_get_constraintdef(c.oid) ILIKE '%SUBMITTED%'
    AND pg_get_constraintdef(c.oid) ILIKE '%status%';

  IF v_constraint IS NOT NULL THEN
    EXECUTE 'ALTER TABLE public.applications DROP CONSTRAINT ' || quote_ident(v_constraint);
    RAISE NOTICE 'Dropped status constraint: %', v_constraint;
  ELSE
    RAISE NOTICE 'No matching status CHECK constraint found — skipping drop';
  END IF;
END $$;

-- 4. Re-add status CHECK constraint with ACTIVE STUDENT included
ALTER TABLE public.applications
  ADD CONSTRAINT applications_status_check CHECK (status IN (
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
    'ACTIVE STUDENT',
    'DENIED',
    'ON HOLD',
    'WITHDRAWN'
  ));

-- 5. Allow anon reads to include the new columns (RLS SELECT already open for anon)
-- No RLS change needed — anon SELECT and UPDATE are already permitted.

-- Done.
SELECT 'Migration complete. active_student_semester and active_student_response columns added.' AS result;
