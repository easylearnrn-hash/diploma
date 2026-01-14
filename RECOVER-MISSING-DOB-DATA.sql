-- EMERGENCY: Recover correct DOB for applications missing rawDob/dobIso
-- This script helps identify and potentially fix DOB issues in older applications

-- ============================================================================
-- STEP 1: Identify all applications with missing rawDob
-- ============================================================================
SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as current_dob_display,
  submission_date,
  'MISSING rawDob - cannot verify accuracy' as status
FROM applications
WHERE 
  (payload->>'rawDob' IS NULL OR payload->>'rawDob' = '')
  AND payload->>'dob' IS NOT NULL
ORDER BY submission_date DESC;

-- ============================================================================
-- STEP 2: Check if students entered dates in a specific form field
-- ============================================================================
-- Check the HTML form - there might be TWO date inputs:
-- 1. name="dob" 
-- 2. name="dateOfBirth"
-- Let's see if the form captured the raw value somewhere else

SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as dob_formatted,
  payload->>'dateOfBirth' as date_of_birth_raw,
  -- Check if there's a form data backup
  payload->'formData'->>'dob' as form_dob,
  payload->'formData'->>'dateOfBirth' as form_date_of_birth,
  submission_date
FROM applications
WHERE payload->>'rawDob' IS NULL
ORDER BY submission_date DESC
LIMIT 10;

-- ============================================================================
-- STEP 3: CRITICAL - Manual verification required
-- ============================================================================
-- ⚠️ ACTION REQUIRED: Contact each student to verify their birth date
--
-- Send verification email/SMS to each student asking:
-- "Please confirm your date of birth as listed in your application: [DATE]"
--
-- Students to contact:
SELECT 
  reference_number,
  applicant_name,
  email,
  phone,
  payload->>'dob' as listed_dob,
  'Please verify your birth date with the student' as action_required
FROM applications
WHERE 
  payload->>'rawDob' IS NULL
  AND payload->>'dob' IS NOT NULL
ORDER BY submission_date DESC;

-- ============================================================================
-- STEP 4: Manual correction (after student verification)
-- ============================================================================
-- After verifying with each student, update their correct DOB:
-- 
-- Template for correction:
-- UPDATE applications
-- SET payload = jsonb_set(
--   jsonb_set(
--     jsonb_set(
--       payload::jsonb,
--       '{rawDob}',
--       to_jsonb('1983-10-17'::text)  -- Verified correct date
--     ),
--     '{dobIso}',
--     to_jsonb('1983-10-17'::text)
--   ),
--   '{dob}',
--   to_jsonb('October 17, 1983'::text)
-- )
-- WHERE reference_number = 'ACNHS-ADM-20260113-843';

-- ============================================================================
-- STEP 5: Prevention - Ensure all future applications capture rawDob
-- ============================================================================
-- The fix has been applied to admission-form.html
-- All NEW applications will have:
-- - rawDob: source of truth (YYYY-MM-DD from input)
-- - dobIso: same as rawDob (no timezone conversion)
-- - dob: formatted display value

-- Verify the fix is working:
SELECT 
  reference_number,
  applicant_name,
  payload->>'rawDob' as raw_dob,
  payload->>'dobIso' as dob_iso,
  payload->>'dob' as dob_display,
  CASE 
    WHEN payload->>'rawDob' = payload->>'dobIso' THEN '✓ Correct'
    WHEN payload->>'rawDob' IS NULL THEN '⚠ Old record'
    ELSE '✗ CORRUPTED'
  END as status,
  submission_date
FROM applications
WHERE submission_date > '2026-01-14 07:00:00'  -- After fix deployment
ORDER BY submission_date DESC;

-- ============================================================================
-- NOTES FOR ADMIN
-- ============================================================================
-- 
-- PROBLEM: Applications submitted before the DOB fix don't have rawDob/dobIso
-- 
-- IMPACT: We cannot automatically verify if dates are correct or off by 1 day
-- 
-- SOLUTION OPTIONS:
-- 
-- 1. CONTACT STUDENTS (RECOMMENDED)
--    - Send verification email/SMS to each affected student
--    - Ask them to confirm their birth date
--    - Manually correct any discrepancies
-- 
-- 2. ASSUME DATES ARE CORRECT
--    - If formatDateValue() was working correctly at submission time
--    - The displayed dates might already be correct
--    - But we have no way to verify without student confirmation
-- 
-- 3. CHECK PASSPORT/ID DOCUMENTS
--    - If students uploaded passport scans
--    - Compare DOB on passport to DOB in system
--    - This is the most reliable verification method
-- 
-- AFFECTED STUDENTS (from your query):
--    - Mari Melkonyan: October 17, 1983
--    - Anahit Hovhannisyan: April 2, 2007
--    - Varduhi Nersesyan: May 27, 1982
--    - Kristina Simonyan: February 18, 1986
--    - Lusine Hovhannisyan: April 23, 1990
--    - Narine Avetisyan: [date not provided]
--    - Plus additional students...
