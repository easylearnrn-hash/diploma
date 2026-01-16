-- Fix Hrach Vardan Student Record
-- The student record exists but has incorrect data:
-- 1. Wrong email: h.vardanyan@confeto.com → should be h.vardan@acnhs.am
-- 2. Missing portal_username: null → should be hrach.vardan.5789
-- 3. Duplicate name: "Hrach Vardan Vardan" → should be "Hrach Vardan"

-- Step 1: Verify current state
SELECT 
  id,
  student_id,
  full_name,
  email AS current_email,
  enrollment_status,
  metadata->'portal'->>'username' AS portal_username,
  metadata->'portal'->>'institutional_email' AS metadata_email,
  created_at
FROM acnhs_students
WHERE student_id = 'ACNHS-6504659';

-- Step 2: Get correct data from application
SELECT 
  id AS app_id,
  applicant_name,
  email AS personal_email,
  username,
  password_hash,
  payload->>'firstName' AS first_name,
  payload->>'lastName' AS last_name
FROM applications
WHERE username = 'hrach.vardan.5789';

-- Step 3: Update student record with correct data
UPDATE acnhs_students
SET 
  full_name = 'Hrach Vardan',  -- Remove duplicate last name
  email = 'h.vardan@acnhs.am',  -- Correct institutional email
  metadata = jsonb_build_object(
    'personal_email', 'h.vardanyan@confeto.com',
    'portal', jsonb_build_object(
      'username', 'hrach.vardan.5789',
      'institutional_email', 'h.vardan@acnhs.am',
      'provisioned_at', NOW()::TEXT
    )
  )
WHERE student_id = 'ACNHS-6504659';

-- Step 4: Update application payload to sync with student record
UPDATE applications
SET 
  payload = jsonb_set(
    jsonb_set(
      jsonb_set(
        COALESCE(payload, '{}'::jsonb),
        '{studentId}',
        '"ACNHS-6504659"'::jsonb
      ),
      '{institutionalEmail}',
      '"h.vardan@acnhs.am"'::jsonb
    ),
    '{studentPortal}',
    jsonb_build_object(
      'institutionalEmail', 'h.vardan@acnhs.am',
      'studentId', 'ACNHS-6504659',
      'username', 'hrach.vardan.5789',
      'provisionedAt', NOW()::TEXT
    )
  )
WHERE username = 'hrach.vardan.5789';

-- Step 5: Verify the fix
SELECT 
  s.id,
  s.student_id,
  s.full_name,
  s.email AS institutional_email,
  s.enrollment_status,
  s.metadata->'portal'->>'username' AS portal_username,
  s.metadata->'portal'->>'institutional_email' AS metadata_email,
  a.applicant_name,
  a.username AS app_username,
  a.email AS personal_email,
  a.payload->>'studentId' AS payload_student_id,
  a.payload->>'institutionalEmail' AS payload_email
FROM acnhs_students s
JOIN applications a ON s.application_id = a.id
WHERE s.student_id = 'ACNHS-6504659';

-- Expected output:
-- full_name: "Hrach Vardan" (no duplicate)
-- institutional_email: "h.vardan@acnhs.am"
-- portal_username: "hrach.vardan.5789"
-- metadata_email: "h.vardan@acnhs.am"
-- payload_student_id: "ACNHS-6504659"
-- payload_email: "h.vardan@acnhs.am"
