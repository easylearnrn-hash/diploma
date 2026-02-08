-- ========================================
-- CHECK CURRENT PASSWORD HASHES
-- ========================================
-- This script shows what password hashes are currently in the database
-- Expected hash for "Welcome2026!": a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
-- ========================================

SELECT 
  a.id as application_id,
  a.applicant_name,
  a.username,
  a.password_hash,
  a.plain_password,
  CASE 
    WHEN a.password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3' THEN '✅ Has Welcome2026! password'
    WHEN a.password_hash IS NULL THEN '❌ NO PASSWORD HASH'
    ELSE '❌ Has OLD random password'
  END as password_status,
  s.email as campus_email,
  s.student_id
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE s.email LIKE '%@acnhs.am'
ORDER BY 
  CASE 
    WHEN a.password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3' THEN 1
    WHEN a.password_hash IS NULL THEN 2
    ELSE 3
  END,
  a.applicant_name;

-- ========================================
-- SUMMARY COUNT
-- ========================================
SELECT 
  COUNT(*) as total_students,
  COUNT(*) FILTER (WHERE a.password_hash = 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3') as has_welcome2026,
  COUNT(*) FILTER (WHERE a.password_hash IS NULL) as no_password,
  COUNT(*) FILTER (WHERE a.password_hash IS NOT NULL AND a.password_hash != 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3') as has_old_password
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE s.email LIKE '%@acnhs.am';

-- ========================================
-- NEXT STEP
-- ========================================
-- If you see "Has OLD random password", run:
-- SET-DEFAULT-PASSWORD-ALL-STUDENTS.sql
-- ========================================
