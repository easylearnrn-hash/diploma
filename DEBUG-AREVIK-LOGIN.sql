-- ========================================
-- DEBUG LOGIN LOOKUP FOR a.arutyunyan@acnhs.am
-- ========================================
-- This shows exactly what the login code sees when searching
-- ========================================

-- Test 1: Search by email field (personal email lookup)
SELECT 
  'Test 1: email field' as test_name,
  id, applicant_name, username, email, password_hash,
  CASE 
    WHEN password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3' THEN '✅ Correct hash'
    ELSE '❌ Wrong hash: ' || password_hash
  END as password_check
FROM applications
WHERE email = 'a.arutyunyan@acnhs.am'
LIMIT 1;

-- Test 2: Search by username field (campus email lookup) 
SELECT 
  'Test 2: username field' as test_name,
  id, applicant_name, username, email, password_hash,
  CASE 
    WHEN password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3' THEN '✅ Correct hash'
    ELSE '❌ Wrong hash: ' || password_hash
  END as password_check
FROM applications
WHERE username = 'a.arutyunyan@acnhs.am'
LIMIT 1;

-- Test 3: Search by payload institutionalEmail
SELECT 
  'Test 3: payload->institutionalEmail' as test_name,
  id, applicant_name, username, email, password_hash,
  payload->>'institutionalEmail' as institutional_email,
  CASE 
    WHEN password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3' THEN '✅ Correct hash'
    ELSE '❌ Wrong hash: ' || password_hash
  END as password_check
FROM applications
WHERE payload->>'institutionalEmail' = 'a.arutyunyan@acnhs.am'
LIMIT 1;

-- Test 4: Show ALL data for Arevik's application
SELECT 
  'Test 4: Full Arevik record' as test_name,
  id,
  applicant_name,
  username,
  email,
  password_hash,
  plain_password,
  status,
  payload->>'institutionalEmail' as institutional_email,
  payload->'credentials'->>'password' as payload_password,
  payload->'credentials'->>'password_hash' as payload_password_hash
FROM applications
WHERE applicant_name ILIKE '%Arevik%Arutyunyan%'
   OR username = 'a.arutyunyan@acnhs.am'
   OR email = 'a.arutyunyan@acnhs.am';

-- Test 5: Check what students table has
SELECT 
  'Test 5: Students table' as test_name,
  s.student_id,
  s.full_name,
  s.email as campus_email,
  a.username,
  a.password_hash,
  a.plain_password
FROM students s
LEFT JOIN applications a ON s.application_id = a.id
WHERE s.email = 'a.arutyunyan@acnhs.am';
