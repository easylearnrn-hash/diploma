-- ========================================
-- DEBUG SPECIFIC STUDENT: h.vardan@acnhs.am
-- ========================================

-- Check if this student exists in acnhs_students
SELECT 
    id,
    student_id,
    application_id,
    full_name,
    email,
    metadata
FROM acnhs_students
WHERE email ILIKE '%vardan%'
   OR metadata->>'institutional_email' ILIKE '%vardan%'
   OR metadata->'portal'->>'institutional_email' ILIKE '%vardan%';

-- Check if application exists with username h.vardan
SELECT 
    id,
    applicant_name,
    email,
    username,
    status,
    submission_date
FROM applications
WHERE username ILIKE '%vardan%'
   OR email ILIKE '%vardan%';

-- If the student exists but metadata is wrong, fix it manually:
UPDATE acnhs_students
SET metadata = COALESCE(metadata, '{}'::jsonb) || 
    jsonb_build_object(
        'institutional_email', 'h.vardan@acnhs.am',
        'personal_email', email,
        'portal', jsonb_build_object(
            'institutional_email', 'h.vardan@acnhs.am',
            'username', 'h.vardan',
            'created_at', NOW()
        )
    )
WHERE student_id = 'ACNHS-6504659'
   OR id = 'b1614ffb-67a3-4373-aa8d-17b678da8319';

-- Verify the fix
SELECT 
    student_id,
    full_name,
    email,
    metadata->>'institutional_email' as institutional_email,
    metadata->'portal'->>'username' as username
FROM acnhs_students
WHERE student_id = 'ACNHS-6504659'
   OR id = 'b1614ffb-67a3-4373-aa8d-17b678da8319';
