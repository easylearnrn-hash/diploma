-- =====================================================
-- FIND THE REMAINING USERNAME MISMATCH
-- =====================================================
-- One student still has username mismatch after sync
-- This script identifies and fixes them
-- =====================================================

-- Step 1: Find the problematic student
SELECT 
  a.id AS application_id,
  a.applicant_name,
  a.status,
  a.username AS current_username,
  a.institutional_email,
  a.email AS personal_email,
  s.id AS student_id_pk,
  s.student_id,
  s.email AS campus_email,
  CASE 
    WHEN a.username = s.email THEN '✅ SYNCED'
    WHEN a.username IS NULL THEN '⚠️ NULL USERNAME'
    WHEN s.email IS NULL THEN '⚠️ NULL CAMPUS EMAIL'
    ELSE '❌ MISMATCH'
  END AS status_detail
FROM applications a
LEFT JOIN students s ON a.id = s.application_id
WHERE a.status = 'ENROLLED'
  AND (a.username IS NULL OR a.username != s.email OR s.email IS NULL)
ORDER BY a.applicant_name;

-- Step 2: Check if student record exists
SELECT 
  a.id AS application_id,
  a.applicant_name,
  a.status,
  CASE 
    WHEN s.id IS NULL THEN '❌ NO STUDENT RECORD'
    ELSE '✅ HAS STUDENT RECORD'
  END AS student_record_status,
  s.student_id,
  s.email
FROM applications a
LEFT JOIN students s ON a.id = s.application_id
WHERE a.status = 'ENROLLED'
  AND (s.id IS NULL OR s.email IS NULL OR a.username IS NULL OR a.username != s.email);

-- Step 3: Fix any student with NULL campus email (generate it)
-- First, let's see if there are any NULL campus emails
SELECT 
  s.id,
  s.student_id,
  s.full_name,
  s.email AS current_campus_email,
  a.applicant_name,
  a.email AS personal_email
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED'
  AND (s.email IS NULL OR s.email = '');

-- Step 4: If needed, manually fix the remaining student
-- (Run after identifying the issue from steps above)
-- Example fix for NULL campus email:
/*
UPDATE students s
SET email = 'CAMPUS_EMAIL_HERE'
WHERE s.student_id = 'ACNHS-XXXXXXX';

UPDATE applications a
SET 
  username = 'CAMPUS_EMAIL_HERE',
  institutional_email = 'CAMPUS_EMAIL_HERE'
FROM students s
WHERE a.id = s.application_id
  AND s.student_id = 'ACNHS-XXXXXXX';
*/
