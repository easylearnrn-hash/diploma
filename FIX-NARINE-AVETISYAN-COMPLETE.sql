-- ============================================================================
-- FIX NARINE AVETISYAN - Update BOTH applications AND students tables
-- ============================================================================
-- Problem: Student record shows Dec 24, 1986 but passport shows Dec 25, 1986
-- Student ID: ACNHS-7022395
-- Reference: ACNHS-ADM-20260108-970
-- ============================================================================

-- STEP 1: Update the applications table
UPDATE applications
SET payload = jsonb_set(
  jsonb_set(
    jsonb_set(
      payload::jsonb,
      '{rawDob}',
      to_jsonb('1986-12-25'::text)
    ),
    '{dobIso}',
    to_jsonb('1986-12-25'::text)
  ),
  '{dob}',
  to_jsonb('December 25, 1986'::text)
)
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- STEP 2: Update the students table (THIS IS KEY!)
UPDATE students
SET date_of_birth = '1986-12-25'
WHERE student_id = 'ACNHS-7022395';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify applications table
SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as dob_display,
  payload->>'rawDob' as raw_dob,
  payload->>'dobIso' as dob_iso
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';
-- Expected: December 25, 1986 / 1986-12-25 / 1986-12-25

-- Verify students table
SELECT 
  student_id,
  full_name,
  date_of_birth,
  email,
  status
FROM students
WHERE student_id = 'ACNHS-7022395';
-- Expected date_of_birth: 1986-12-25

-- Cross-check both tables together
SELECT 
  s.student_id,
  s.full_name,
  s.date_of_birth as student_table_dob,
  a.payload->>'dob' as application_dob,
  a.payload->>'rawDob' as application_raw_dob,
  CASE 
    WHEN s.date_of_birth::text = a.payload->>'dobIso' THEN '✓ Match'
    ELSE '✗ MISMATCH'
  END as consistency_check
FROM students s
LEFT JOIN applications a ON a.id = s.application_id
WHERE s.student_id = 'ACNHS-7022395';
-- All should show 1986-12-25 and consistency_check should be '✓ Match'

-- ============================================================================
-- NOTES
-- ============================================================================
-- The admin student page displays from the `students` table, not `applications`
-- That's why the fix wasn't showing up - we only updated applications
-- Now both tables are synchronized with the correct DOB from passport
