-- ========================================
-- RESTORE ACCIDENTALLY DELETED STUDENTS
-- ========================================
-- Run this IMMEDIATELY in Supabase SQL Editor
-- This will restore students from the applications table
-- ========================================

-- First, let's see what applications exist that don't have corresponding students
SELECT 
    a.id as application_id,
    a.applicant_name,
    a.email,
    a.institutional_email,
    a.program,
    a.status,
    a.submission_date
FROM applications a
LEFT JOIN acnhs_students s ON a.id = s.application_id
WHERE a.status = 'ENROLLED'
  AND s.id IS NULL  -- No matching student record
ORDER BY a.submission_date DESC;

-- If you see students that should exist, we need to recreate them
-- This will require running the student creation logic again

-- EMERGENCY: Check if we can find the deleted students in any backup
-- (Supabase may have point-in-time recovery available)

-- To manually restore a student (example for h.vardan@acnhs.am):
/*
INSERT INTO acnhs_students (
    student_id,
    application_id,
    full_name,
    email,
    phone,
    program,
    enrollment_status,
    enrolled_at,
    created_at
)
SELECT 
    'ACNHS-' || LPAD(FLOOR(RANDOM() * 10000000)::TEXT, 7, '0'),
    a.id,
    a.applicant_name,
    a.institutional_email,
    a.phone,
    a.program,
    'active',
    NOW(),
    NOW()
FROM applications a
WHERE a.status = 'ENROLLED'
  AND a.institutional_email = 'h.vardan@acnhs.am'
  AND NOT EXISTS (
    SELECT 1 FROM acnhs_students WHERE application_id = a.id
  );
*/

-- Better approach: Restore ALL enrolled students that are missing
INSERT INTO acnhs_students (
    student_id,
    application_id,
    full_name,
    email,
    phone,
    program,
    enrollment_status,
    enrolled_at,
    created_at
)
SELECT 
    'ACNHS-' || LPAD(FLOOR(RANDOM() * 10000000)::TEXT, 7, '0'),
    a.id,
    a.applicant_name,
    COALESCE(a.institutional_email, a.email),
    a.phone,
    a.program,
    'active',
    NOW(),
    NOW()
FROM applications a
WHERE a.status = 'ENROLLED'
  AND NOT EXISTS (
    SELECT 1 FROM acnhs_students WHERE application_id = a.id
  )
ON CONFLICT (application_id) DO NOTHING;

-- Verify restoration
SELECT 
    student_id,
    full_name,
    email,
    enrollment_status,
    created_at
FROM acnhs_students
ORDER BY created_at DESC
LIMIT 20;
