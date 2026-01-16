-- ========================================
-- CHECK STUDENT RECORD b1614ffb-67a3-4373-aa8d-17b678da8319
-- ========================================

-- Check the exact student record by ID
SELECT 
    id,
    student_id,
    application_id,
    full_name,
    email,
    phone,
    program,
    enrollment_status,
    metadata,
    created_at
FROM acnhs_students
WHERE id = 'b1614ffb-67a3-4373-aa8d-17b678da8319'::uuid;

-- Check if this student_id exists
SELECT 
    id,
    student_id,
    application_id,
    full_name,
    email,
    metadata->>'institutional_email' as institutional_email
FROM acnhs_students
WHERE student_id = 'ACNHS-6504659';

-- Maybe the student was deleted? Check all students named Mariam
SELECT 
    id,
    student_id,
    full_name,
    email,
    metadata->>'institutional_email' as institutional_email,
    enrollment_status
FROM acnhs_students
WHERE full_name ILIKE '%mariam%';

-- Check the application
SELECT 
    id,
    applicant_name,
    email,
    username,
    status
FROM applications
WHERE id = '82997e34-e5ec-4786-af36-31e31d289bc4'::uuid;
