-- ============================================================================
-- FIX NARINE AVETISYAN CAMPUS EMAIL
-- ============================================================================
-- Problem: Personal email (narineavetisyan7788@gmail.com) showing as Campus Email
-- Student ID: ACNHS-7022395
-- Campus Email should be: n.avetisyan@acnhs.am (derived from Narine Avetisyan)
-- 
-- 🔗 Run in NEW Supabase SQL Editor:
-- https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql
-- ============================================================================

-- STEP 1: Check current state
SELECT 
  student_id,
  full_name,
  email as current_email_field,
  metadata->>'institutional_email' as metadata_institutional,
  metadata->'portal'->>'institutional_email' as portal_institutional,
  metadata->>'personal_email' as personal_email,
  metadata->'contact'->>'email' as contact_email
FROM students
WHERE student_id = 'ACNHS-7022395';

-- Expected issue: email field contains 'narineavetisyan7788@gmail.com' instead of 'n.avetisyan@acnhs.am'

-- STEP 2: Fix the record
-- The campus email format is: firstInitial.lastName@acnhs.am
-- For "Narine Avetisyan" -> n.avetisyan@acnhs.am
UPDATE students
SET 
  email = 'n.avetisyan@acnhs.am',
  metadata = jsonb_set(
    jsonb_set(
      jsonb_set(
        COALESCE(metadata, '{}'::jsonb),
        '{personal_email}',
        '"narineavetisyan7788@gmail.com"'::jsonb
      ),
      '{portal,institutional_email}',
      '"n.avetisyan@acnhs.am"'::jsonb
    ),
    '{institutional_email}',
    '"n.avetisyan@acnhs.am"'::jsonb
  )
WHERE student_id = 'ACNHS-7022395';

-- STEP 3: Verify the fix
SELECT 
  student_id,
  full_name,
  email as campus_email,
  metadata->>'personal_email' as personal_email,
  metadata->'portal'->>'institutional_email' as portal_institutional_email,
  metadata->>'institutional_email' as metadata_institutional_email
FROM students
WHERE student_id = 'ACNHS-7022395';

-- Expected output:
-- campus_email: n.avetisyan@acnhs.am
-- personal_email: narineavetisyan7788@gmail.com
-- portal_institutional_email: n.avetisyan@acnhs.am
-- metadata_institutional_email: n.avetisyan@acnhs.am

-- ============================================================================
-- STEP 4: Fix the applications table too
-- ============================================================================
SELECT 
  reference_number,
  applicant_name,
  email,
  payload->'contactInfo'->>'email' as contact_email,
  payload->>'email' as payload_email
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- Update the applications table
UPDATE applications
SET 
  email = 'n.avetisyan@acnhs.am',
  payload = jsonb_set(
    jsonb_set(
      COALESCE(payload, '{}'::jsonb),
      '{institutionalEmail}',
      '"n.avetisyan@acnhs.am"'::jsonb
    ),
    '{personalEmail}',
    '"narineavetisyan7788@gmail.com"'::jsonb
  )
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- ============================================================================
-- STEP 5: Verify applications table fix
-- ============================================================================
SELECT 
  reference_number,
  applicant_name,
  email as campus_email,
  payload->>'institutionalEmail' as institutional_email,
  payload->>'personalEmail' as personal_email
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- Expected:
-- campus_email: n.avetisyan@acnhs.am
-- institutional_email: n.avetisyan@acnhs.am
-- personal_email: narineavetisyan7788@gmail.com
