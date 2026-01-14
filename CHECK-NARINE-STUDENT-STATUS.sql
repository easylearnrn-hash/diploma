-- CHECK IF NARINE EXISTS IN STUDENTS TABLE AND HER APPLICATION STATUS
-- Run this in Supabase SQL Editor

-- 1. Check applications table (we know she's here)
SELECT 
  reference_number,
  full_name,
  status,
  control_number,
  created_at
FROM applications 
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- 2. Check if she has a student record
SELECT 
  student_id,
  full_name,
  date_of_birth,
  application_id
FROM students 
WHERE application_id = 'ACNHS-ADM-20260108-970';

-- 3. Check all students to see pattern
SELECT COUNT(*) as total_students FROM students;

-- 4. Check if there are any students from January 2026 applications
SELECT 
  s.student_id,
  s.full_name,
  a.reference_number,
  a.created_at
FROM students s
JOIN applications a ON s.application_id = a.reference_number
WHERE a.created_at >= '2026-01-01'
ORDER BY a.created_at DESC;
