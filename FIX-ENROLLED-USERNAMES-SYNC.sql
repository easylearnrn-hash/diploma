-- =====================================================
-- FIX ENROLLED STUDENTS USERNAMES TO CAMPUS EMAILS
-- =====================================================
-- This script syncs usernames for ALL enrolled students
-- to match their campus email addresses from students table
-- =====================================================

-- Step 1: Show current mismatches
SELECT 
  a.id,
  a.applicant_name,
  a.status,
  a.username AS old_username,
  s.email AS campus_email,
  s.student_id
FROM applications a
JOIN students s ON a.id = s.application_id
WHERE a.status = 'ENROLLED'
  AND (a.username IS NULL OR a.username != s.email)
ORDER BY a.applicant_name;

-- Step 2: Update usernames to match campus emails
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
  AND a.status = 'ENROLLED'
  AND (a.username IS NULL OR a.username != s.email);

-- Step 3: Verify the fix
SELECT 
  a.id,
  a.applicant_name,
  a.status,
  a.username,
  s.email AS campus_email,
  s.student_id,
  CASE 
    WHEN a.username = s.email THEN '✅ SYNCED'
    ELSE '❌ MISMATCH'
  END AS sync_status
FROM applications a
JOIN students s ON a.id = s.application_id
WHERE a.status = 'ENROLLED'
ORDER BY a.applicant_name;

-- Step 4: Count results
SELECT 
  COUNT(*) AS total_enrolled,
  SUM(CASE WHEN a.username = s.email THEN 1 ELSE 0 END) AS synced_count,
  SUM(CASE WHEN a.username != s.email OR a.username IS NULL THEN 1 ELSE 0 END) AS mismatch_count
FROM applications a
JOIN students s ON a.id = s.application_id
WHERE a.status = 'ENROLLED';
