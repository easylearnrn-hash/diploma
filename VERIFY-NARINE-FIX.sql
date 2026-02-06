-- ============================================================================
-- VERIFY NARINE CAMPUS EMAIL FIX
-- ============================================================================
-- Run this to confirm both tables are fixed
-- Student ID: ACNHS-7022395
-- Reference: ACNHS-ADM-20260108-970
-- ============================================================================

-- Check students table
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

-- Check applications table
SELECT 
  reference_number,
  applicant_name,
  email as campus_email,
  payload->>'institutionalEmail' as institutional_email,
  payload->>'personalEmail' as personal_email
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- Expected output:
-- campus_email: n.avetisyan@acnhs.am
-- institutional_email: n.avetisyan@acnhs.am
-- personal_email: narineavetisyan7788@gmail.com

-- ============================================================================
-- FINAL CHECK: Both should match
-- ============================================================================
SELECT 
  s.student_id,
  s.full_name,
  s.email as student_campus_email,
  a.email as application_campus_email,
  s.metadata->>'personal_email' as student_personal_email,
  a.payload->>'personalEmail' as application_personal_email,
  CASE 
    WHEN s.email = a.email AND s.email = 'n.avetisyan@acnhs.am' THEN '✅ FIXED'
    ELSE '❌ MISMATCH'
  END as status
FROM students s
LEFT JOIN applications a ON a.reference_number = 'ACNHS-ADM-20260108-970'
WHERE s.student_id = 'ACNHS-7022395';

-- Status should show: ✅ FIXED
