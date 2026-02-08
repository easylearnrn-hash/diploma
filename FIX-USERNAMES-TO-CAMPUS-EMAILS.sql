-- ========================================
-- FIX USERNAMES TO MATCH CAMPUS EMAILS
-- ========================================
--
-- ISSUE: applications.username has old format (fullname.random)
-- CORRECT: applications.username should be campus email (a.lastname@acnhs.am)
--
-- This script synchronizes usernames with campus emails
-- ========================================

-- Step 1: AUDIT - Show current mismatches
SELECT 
  a.id as application_id,
  a.applicant_name,
  a.username as current_username,
  s.email as campus_email,
  a.email as personal_email,
  CASE 
    WHEN a.username = s.email THEN '✅ Username matches campus email'
    WHEN a.username LIKE '%@acnhs.am' THEN '⚠️ Has @acnhs.am but different from campus email'
    ELSE '❌ Username is NOT campus email'
  END as status,
  s.student_id,
  s.full_name
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE s.email LIKE '%@acnhs.am'
ORDER BY 
  CASE 
    WHEN a.username = s.email THEN 1
    ELSE 2
  END,
  a.applicant_name;

-- Step 2: UPDATE all applications - set username to campus email from students table
UPDATE applications a
SET 
  username = s.email,
  payload = COALESCE(a.payload, '{}'::jsonb) || 
    jsonb_build_object(
      'institutionalEmail', s.email,
      'studentPortal', COALESCE(a.payload->'studentPortal', '{}'::jsonb) || 
        jsonb_build_object(
          'username', s.email,
          'institutionalEmail', s.email
        ),
      'username_updated_at', NOW()::TEXT,
      'username_updated_reason', 'Synced with campus email from students table'
    )
FROM students s
WHERE s.application_id = a.id
  AND s.email LIKE '%@acnhs.am'
  AND a.username != s.email; -- Only update if different

-- Step 3: VERIFICATION - Show results
SELECT 
  a.id as application_id,
  a.applicant_name,
  a.username,
  s.email as campus_email,
  CASE 
    WHEN a.username = s.email THEN '✅ FIXED - Username matches campus email'
    ELSE '❌ Still mismatched'
  END as status,
  s.student_id,
  s.full_name
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE s.email LIKE '%@acnhs.am'
ORDER BY 
  CASE 
    WHEN a.username = s.email THEN 1
    ELSE 2
  END,
  a.applicant_name;

-- Step 4: COUNT summary
SELECT 
  COUNT(*) as total_students,
  COUNT(*) FILTER (WHERE a.username = s.email) as username_matches_email,
  COUNT(*) FILTER (WHERE a.username != s.email) as username_mismatch
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE s.email LIKE '%@acnhs.am';

-- Step 5: DETAILED REPORT - Show specific changes made
SELECT 
  'Username Sync Report' as report_type,
  a.applicant_name as student_name,
  a.username as login_username,
  s.email as campus_email,
  s.student_id,
  CASE 
    WHEN a.username = s.email THEN '✅ Ready for login'
    ELSE '❌ Needs manual check'
  END as login_status
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE s.email LIKE '%@acnhs.am'
ORDER BY a.applicant_name;

-- ========================================
-- EXPECTED RESULTS
-- ========================================
-- Username format BEFORE: alvard.ghukasyan.9725, armen.kalents.4292
-- Username format AFTER:  a.ghukasyan@acnhs.am, a.kalents@acnhs.am
--
-- Students can now log in with:
-- Username: {campus_email} (e.g., a.arutyunyan@acnhs.am)
-- Password: Welcome2026!
-- ========================================
