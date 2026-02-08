-- =====================================================
-- DEBUG AND FIX: Alvard Ghukasyan Username
-- =====================================================
-- Student ID: ACNHS-3394133
-- Current username: alvard.ghukasyan.9725
-- Expected: a.ghukasyan@acnhs.am
-- =====================================================

-- Step 1: Check current state
SELECT 
  a.id,
  a.applicant_name,
  a.status,
  a.username,
  a.institutional_email,
  a.email AS personal_email,
  s.email AS campus_email,
  s.student_id,
  a.payload->'studentPortal'->>'username' AS payload_username
FROM applications a
LEFT JOIN students s ON a.id = s.application_id
WHERE s.student_id = 'ACNHS-3394133'
   OR a.applicant_name ILIKE '%Alvard%Ghukasyan%'
   OR a.username LIKE 'alvard.ghukasyan%';

-- Step 2: Fix the username
UPDATE applications a
SET 
  username = s.email,
  institutional_email = s.email,
  payload = jsonb_set(
    COALESCE(a.payload, '{}'::jsonb),
    '{studentPortal,username}',
    to_jsonb(s.email),
    true
  )
FROM students s
WHERE a.id = s.application_id
  AND s.student_id = 'ACNHS-3394133';

-- Step 3: Verify the fix
SELECT 
  a.id,
  a.applicant_name,
  a.status,
  a.username AS updated_username,
  a.institutional_email,
  s.email AS campus_email,
  s.student_id,
  CASE 
    WHEN a.username = s.email THEN '✅ USERNAME SYNCED'
    ELSE '❌ STILL MISMATCHED'
  END AS status
FROM applications a
LEFT JOIN students s ON a.id = s.application_id
WHERE s.student_id = 'ACNHS-3394133';
