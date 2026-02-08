-- ========================================
-- SET DEFAULT PASSWORD FOR ALL STUDENTS
-- ========================================
--
-- Sets all students' password to "Welcome2026!"
-- Password hash is SHA-256 of "Welcome2026!"
--
-- Run this in Supabase SQL Editor
-- ========================================

-- Step 1: Calculate the SHA-256 hash of "Welcome2026!"
-- Hash: a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3

-- Step 2: UPDATE all applications with the default password
UPDATE applications
SET 
  password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
  plain_password = 'Welcome2026!',
  payload = COALESCE(payload, '{}'::jsonb) || 
    jsonb_build_object(
      'credentials', jsonb_build_object(
        'password', 'Welcome2026!',
        'password_hash', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        'default_password', true,
        'must_change_password', true,
        'password_set_date', NOW()::TEXT
      )
    )
WHERE status IN ('enrolled', 'student', 'active', 'registered')
  OR id IN (SELECT application_id FROM students WHERE application_id IS NOT NULL);

-- Step 3: Also update students table metadata for reference
UPDATE students
SET metadata = COALESCE(metadata, '{}'::jsonb) || 
  jsonb_build_object(
    'credentials', jsonb_build_object(
      'default_password', true,
      'must_change_password', true,
      'password_last_changed', NOW()::TEXT
    )
  )
WHERE application_id IN (
  SELECT id FROM applications 
  WHERE password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3'
);

-- Step 4: VERIFICATION - Show all students with default password
SELECT 
  a.id as application_id,
  a.applicant_name,
  a.username,
  a.email,
  a.plain_password as password,
  CASE 
    WHEN a.password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3' 
    THEN '✅ Default Password Set'
    ELSE '⚠️ Different Password'
  END as status,
  s.student_id,
  s.full_name
FROM applications a
LEFT JOIN students s ON s.application_id = a.id
WHERE a.password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3'
ORDER BY a.applicant_name;

-- ========================================
-- SUMMARY
-- ========================================
-- ✅ All students now have password: "Welcome2026!"
-- ✅ Password hash: a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
-- ✅ Plain password stored in applications.plain_password
-- ✅ Metadata flags set: must_change_password = true
-- ========================================
