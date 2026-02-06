-- GET NARINE AVETISYAN STUDENT ID
-- Application Reference: ACNHS-ADM-20260108-970
-- Student ID: ACNHS-7022395

-- Check if student record exists
SELECT 
    s.id as uuid,
    s.student_id,
    s.full_name,
    s.email,
    s.phone,
    s.date_of_birth,
    s.program,
    s.start_term,
    s.status,
    s.application_id,
    a.reference_number,
    a.applicant_name
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.reference_number = 'ACNHS-ADM-20260108-970';

-- If no student record, check application only
SELECT 
    id,
    reference_number,
    applicant_name,
    email,
    status
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';
