-- ========================================
-- FINAL LOGIN VERIFICATION
-- ========================================
-- Verify the exact login flow for a.arutyunyan@acnhs.am
-- ========================================

-- Simulate the exact login query from login.html line 1380-1396
-- Test 1: Search by email field (personal email)
SELECT 
  '1. Search by email field' as query_step,
  id, applicant_name, username, email, password_hash,
  'a.arutyunyan@acnhs.am' as searching_for,
  CASE 
    WHEN password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' THEN '✅ Hash matches - login will succeed'
    ELSE '❌ Hash mismatch - login will fail'
  END as result
FROM applications
WHERE email = 'a.arutyunyan@acnhs.am'
LIMIT 1;

-- Test 2: Search by username field (this is what should match!)
SELECT 
  '2. Search by username field' as query_step,
  id, applicant_name, username, email, password_hash,
  'a.arutyunyan@acnhs.am' as searching_for,
  CASE 
    WHEN password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' THEN '✅ Hash matches - login will succeed'
    ELSE '❌ Hash mismatch - login will fail'
  END as result
FROM applications
WHERE username = 'a.arutyunyan@acnhs.am'
LIMIT 1;

-- Test 3: Show complete login data
SELECT 
  '3. Complete login verification' as query_step,
  a.id,
  a.applicant_name,
  a.username as login_username,
  a.email as personal_email,
  a.password_hash,
  a.plain_password,
  a.status,
  s.email as campus_email,
  s.student_id,
  CASE 
    WHEN a.password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' THEN '✅ READY TO LOGIN'
    ELSE '❌ WRONG HASH'
  END as login_ready
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE a.username = 'a.arutyunyan@acnhs.am'
   OR s.email = 'a.arutyunyan@acnhs.am';

-- ========================================
-- LOGIN INSTRUCTIONS
-- ========================================
-- If all tests show ✅, students can now log in with:
-- Username: a.arutyunyan@acnhs.am
-- Password: Welcome2026!
-- ========================================
