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

-- If application exists but status is not ENROLLED, manually restore the student:
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
    'b1614ffb-67a3-4373-aa8d-17b678da8319'::uuid,  -- Original ID from session
    'ACNHS-6504659',  -- Original student ID
    '82997e34-e5ec-4786-af36-31e31d289bc4'::uuid,  -- Application ID
    'Mariam Gevorgyan',
    'mariamgevorgyan@example.com',  -- Replace with actual email if known
    NULL,
    'Nursing',  -- Replace with actual program if known
    'active',
    jsonb_build_object(
        'institutional_email', 'h.vardan@acnhs.am',
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
