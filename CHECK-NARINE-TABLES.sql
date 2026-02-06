-- CHECK WHERE NARINE'S DATA EXISTS
-- Application Reference: ACNHS-ADM-20260108-970

-- 1. Check applications table
SELECT 
    'applications' as table_name,
    id,
    reference_number,
    applicant_name,
    email,
    status
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- 2. Check students table (joined with applications)
SELECT 
    'students' as table_name,
    s.id,
    s.student_id,
    s.full_name,
    s.email,
    s.status,
    a.reference_number
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.reference_number = 'ACNHS-ADM-20260108-970';

-- 3. Check acnhs_students table if it exists
SELECT 
    'acnhs_students' as table_name,
    id,
    student_id,
    name as full_name,
    email,
    status
FROM acnhs_students
WHERE email IN (
    SELECT email FROM applications WHERE reference_number = 'ACNHS-ADM-20260108-970'
);

-- 4. Check if acnhs_students has application link
SELECT 
    'acnhs_students_by_ref' as table_name,
    a_s.*
FROM acnhs_students a_s
WHERE a_s.id IN (
    SELECT id FROM applications WHERE reference_number = 'ACNHS-ADM-20260108-970'
);
