-- ========================================
-- FIX STUDENT PROFILE LOOKUP
-- Link institutional emails to student records
-- ========================================
-- Run this in Supabase SQL Editor
-- ========================================

-- First, check which students are missing institutional email in metadata
SELECT 
    s.student_id,
    s.full_name,
    s.email as personal_email,
    s.metadata->>'institutional_email' as metadata_institutional,
    s.metadata->'portal'->>'institutional_email' as portal_institutional,
    a.institutional_email as application_institutional
FROM acnhs_students s
LEFT JOIN applications a ON s.application_id = a.id
WHERE s.metadata IS NULL 
   OR s.metadata->>'institutional_email' IS NULL
ORDER BY s.created_at DESC;

-- Update students to add institutional email from applications table to metadata
UPDATE acnhs_students s
SET metadata = COALESCE(s.metadata, '{}'::jsonb) || 
    jsonb_build_object(
        'institutional_email', a.institutional_email,
        'personal_email', s.email,
        'portal', jsonb_build_object(
            'institutional_email', a.institutional_email,
            'username', a.username,
            'created_at', NOW()
        )
    )
FROM applications a
WHERE s.application_id = a.id
  AND a.institutional_email IS NOT NULL
  AND a.institutional_email != ''
  AND (s.metadata IS NULL OR s.metadata->>'institutional_email' IS NULL);

-- Verify the update
SELECT 
    s.student_id,
    s.full_name,
    s.email as personal_email,
    s.metadata->>'institutional_email' as institutional_email,
    s.metadata->'portal'->>'institutional_email' as portal_email,
    s.metadata->'portal'->>'username' as username
FROM acnhs_students s
WHERE s.metadata->>'institutional_email' IS NOT NULL
ORDER BY s.created_at DESC
LIMIT 20;
