-- FIX CORRUPTED DATE OF BIRTH VALUES IN EXISTING APPLICATIONS
-- This script repairs dobIso values that were corrupted by timezone conversion bug
-- Run this AFTER deploying the DOB fix to admission-form.html

-- ============================================================================
-- STEP 1: AUDIT - Check how many records are affected
-- ============================================================================
SELECT 
  COUNT(*) as total_applications,
  COUNT(CASE WHEN payload->>'rawDob' IS NOT NULL THEN 1 END) as has_raw_dob,
  COUNT(CASE WHEN payload->>'dobIso' IS NOT NULL THEN 1 END) as has_dob_iso,
  COUNT(CASE 
    WHEN payload->>'rawDob' IS NOT NULL 
    AND payload->>'dobIso' IS NOT NULL 
    AND payload->>'rawDob' != payload->>'dobIso' 
    THEN 1 
  END) as corrupted_coun
FROM applications;

-- ============================================================================
-- STEP 2: VIEW CORRUPTED RECORDS
-- ============================================================================
SELECT 
  reference_number,
  applicant_name,
  payload->>'rawDob' as raw_dob_correct,
  payload->>'dobIso' as dob_iso_corrupted,
  payload->>'dob' as dob_display,
  submission_date,
  EXTRACT(DAY FROM (payload->>'rawDob')::date) - EXTRACT(DAY FROM (payload->>'dobIso')::date) as day_difference
FROM applications
WHERE 
  payload->>'rawDob' IS NOT NULL
  AND payload->>'dobIso' IS NOT NULL
  AND payload->>'rawDob' != payload->>'dobIso'
ORDER BY submission_date DESC;

-- ============================================================================
-- STEP 3: FIX - Repair dobIso to match rawDob (the correct value)
-- ============================================================================
-- ⚠️ IMPORTANT: Review the audit results above before running this!
-- This will overwrite dobIso with the correct value from rawDob

UPDATE applications
SET payload = jsonb_set(
  payload::jsonb,
  '{dobIso}',
  to_jsonb(payload->>'rawDob'),
  true
)
WHERE 
  payload->>'rawDob' IS NOT NULL
  AND payload->>'dobIso' IS NOT NULL
  AND payload->>'rawDob' != payload->>'dobIso';

-- Verify the fix
SELECT 
  COUNT(*) as fixed_records
FROM applications
WHERE 
  payload->>'rawDob' IS NOT NULL
  AND payload->>'dobIso' IS NOT NULL
  AND payload->>'rawDob' = payload->>'dobIso';

-- ============================================================================
-- STEP 4: ADVANCED - Fix dob display field if corrupted
-- ============================================================================
-- This recalculates the display format from the corrected rawDob

-- First, create a helper function to format dates properly
CREATE OR REPLACE FUNCTION format_date_display(iso_date TEXT)
RETURNS TEXT AS $$
BEGIN
  IF iso_date IS NULL OR iso_date = '' THEN
    RETURN '—';
  END IF;
  
  -- Parse ISO date and format as "Month Day, Year"
  RETURN TO_CHAR(iso_date::DATE, 'FMMonth DD, YYYY');
EXCEPTION
  WHEN OTHERS THEN
    RETURN iso_date; -- Return as-is if parsing fails
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Now update the display field
UPDATE applications
SET payload = jsonb_set(
  payload::jsonb,
  '{dob}',
  to_jsonb(format_date_display(payload->>'rawDob')),
  true
)
WHERE 
  payload->>'rawDob' IS NOT NULL
  AND payload->>'dob' IS NOT NULL;

-- ============================================================================
-- STEP 5: VERIFY FINAL STATE
-- ============================================================================
SELECT 
  'All DOB fields should now be consistent' as status,
  COUNT(*) as total_checked,
  COUNT(CASE 
    WHEN payload->>'rawDob' = payload->>'dobIso' 
    THEN 1 
  END) as consistent_records,
  COUNT(CASE 
    WHEN payload->>'rawDob' IS NOT NULL 
    AND payload->>'dobIso' IS NULL 
    THEN 1 
  END) as missing_iso,
  COUNT(CASE 
    WHEN payload->>'rawDob' IS NOT NULL 
    AND payload->>'dobIso' IS NOT NULL 
    AND payload->>'rawDob' != payload->>'dobIso' 
    THEN 1 
  END) as still_corrupted
FROM applications
WHERE payload->>'rawDob' IS NOT NULL;

-- ============================================================================
-- NOTES
-- ============================================================================
-- * This migration is SAFE to run multiple times (idempotent)
-- * rawDob is the source of truth (entered by student, never timezone-converted)
-- * dobIso should always equal rawDob after this fix
-- * dob (display format) is recalculated from rawDob
-- * Records where rawDob is NULL are left untouched
-- * No data is deleted, only corrected
