-- ========================================
-- RESTORE MARIAM GEVORGYAN (h.vardan@acnhs.am)
-- ========================================

-- First, check if the application exists
SELECT 
    id,
    applicant_name,
    email,
    username,
    status,
    program,
    submission_date
FROM applications
WHERE username = 'h.vardan'
   OR id = '82997e34-e5ec-4786-af36-31e31d289bc4'::uuid
   OR applicant_name ILIKE '%gevorgyan%';

-- Step 1: Create the application if it doesn't exist
INSERT INTO applications (
    id,
    reference_number,
    barcode,
    applicant_name,
    email,
    username,
    password_hash,
    program,
    status,
    submission_date
)
VALUES (
    '82997e34-e5ec-4786-af36-31e31d289bc4'::uuid,
    'ACNHS-ADM-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || FLOOR(RANDOM() * 1000)::TEXT,
    'ACN' || TO_CHAR(NOW(), 'YYYY') || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0') || 'VERIFY',
    'Mariam Gevorgyan',
    'mariamgevorgyan@gmail.com',
    'h.vardan',
    '$2a$10$dummy.hash.for.testing',
    'Nursing',
    'ENROLLED',
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    status = 'ENROLLED';

-- Step 2: Now restore the student with the correct application_id
INSERT INTO acnhs_students (
    id,
    student_id,
    application_id,
    full_name,
    email,
    phone,
    program,
    enrollment_status,
    metadata,
    enrolled_at,
    created_at
)
VALUES (
    'b1614ffb-67a3-4373-aa8d-17b678da8319'::uuid,
    'ACNHS-6504659',
    '82997e34-e5ec-4786-af36-31e31d289bc4'::uuid,
    'Mariam Gevorgyan',
    'mariamgevorgyan@gmail.com',
    NULL,
    'Nursing',
    'active',
    jsonb_build_object(
        'institutional_email', 'h.vardan@acnhs.am',
        'personal_email', 'mariamgevorgyan@gmail.com',
        'portal', jsonb_build_object(
            'institutional_email', 'h.vardan@acnhs.am',
            'username', 'h.vardan',
            'created_at', NOW()
        )
    ),
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    metadata = EXCLUDED.metadata;

-- Verify the restoration
SELECT 
    id,
    student_id,
    full_name,
    email,
    metadata->>'institutional_email' as institutional_email,
    enrollment_status
FROM acnhs_students
WHERE id = 'b1614ffb-67a3-4373-aa8d-17b678da8319'::uuid
   OR student_id = 'ACNHS-6504659';
