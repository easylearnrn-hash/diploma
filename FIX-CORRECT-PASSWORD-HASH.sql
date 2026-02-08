-- ========================================
-- FIX INCORRECT PASSWORD HASH
-- ========================================
--
-- PROBLEM: Database has WRONG hash for "Welcome2026!"
-- Database hash: a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
-- CORRECT hash:  a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213
--
-- This script updates all student passwords with the CORRECT hash
-- ========================================

-- Step 1: VERIFY - Show current incorrect hashes
SELECT 
  'BEFORE UPDATE' as status,
  id,
  applicant_name,
  username,
  password_hash,
  plain_password,
  CASE 
    WHEN password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' THEN '✅ CORRECT hash'
    WHEN password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3' THEN '❌ WRONG hash'
    ELSE '❓ Unknown hash'
  END as hash_status
FROM applications
WHERE id IN (SELECT application_id FROM students WHERE email LIKE '%@acnhs.am')
ORDER BY applicant_name;

-- Step 2: UPDATE with CORRECT hash
UPDATE applications
SET 
  password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213',
  plain_password = 'Welcome2026!',
  payload = COALESCE(payload, '{}'::jsonb) || 
    jsonb_build_object(
      'credentials', jsonb_build_object(
        'password', 'Welcome2026!',
        'password_hash', 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213',
        'default_password', true,
        'must_change_password', true,
        'password_set_date', NOW()::TEXT,
        'hash_corrected', true,
        'hash_corrected_date', NOW()::TEXT
      )
    )
WHERE id IN (SELECT application_id FROM students WHERE email LIKE '%@acnhs.am');

-- Step 3: Also update students table metadata
UPDATE students
SET metadata = COALESCE(metadata, '{}'::jsonb) || 
  jsonb_build_object(
    'credentials', jsonb_build_object(
      'default_password', true,
      'must_change_password', true,
      'password_last_changed', NOW()::TEXT,
      'hash_corrected', true
    )
  )
WHERE application_id IN (
  SELECT id FROM applications 
  WHERE password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213'
);

-- Step 4: VERIFY - Show corrected hashes
SELECT 
  'AFTER UPDATE' as status,
  a.id,
  a.applicant_name,
  a.username,
  a.password_hash,
  a.plain_password,
  CASE 
    WHEN a.password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' THEN '✅ CORRECT hash - login will work'
    ELSE '❌ Still wrong'
  END as hash_status,
  s.email as campus_email,
  s.student_id
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE s.email LIKE '%@acnhs.am'
ORDER BY a.applicant_name;

-- Step 5: Test query (simulates login lookup)
SELECT 
  'LOGIN TEST SIMULATION' as test,
  id,
  applicant_name,
  username,
  password_hash,
  CASE 
    WHEN password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' THEN '✅ Login will succeed'
    ELSE '❌ Login will fail'
  END as login_result
FROM applications
WHERE username = 'a.arutyunyan@acnhs.am';

-- ========================================
-- HASH VERIFICATION PROOF
-- ========================================
-- Command: echo -n 'Welcome2026!' | shasum -a 256
-- Result:  a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213
--
-- The previous hash (a665a45...) was for a DIFFERENT string!
-- ========================================

-- Step 6: Summary count
SELECT 
  COUNT(*) as total_students,
  COUNT(*) FILTER (WHERE password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213') as correct_hash,
  COUNT(*) FILTER (WHERE password_hash != 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213') as wrong_hash
FROM applications
WHERE id IN (SELECT application_id FROM students WHERE email LIKE '%@acnhs.am');
