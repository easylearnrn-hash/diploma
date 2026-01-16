-- ========================================
-- FIX STUDENT PROFILE LOOKUP
-- Link institutional emails to student records
-- ========================================
-- Run this in Supabase SQL Editor
-- ========================================

-- Step 1: Check if institutional_email column exists in applications
-- Run this first to see the actual columns:
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'applications' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Step 2: Check which students are missing institutional email in metadata
SELECT 
    s.student_id,
    s.full_name,
    s.email as personal_email,
    s.metadata->>'institutional_email' as metadata_institutional,
    s.metadata->'portal'->>'institutional_email' as portal_institutional,
    a.username,
    a.email as application_email
FROM acnhs_students s
LEFT JOIN applications a ON s.application_id = a.id
WHERE s.metadata IS NULL 
   OR s.metadata->>'institutional_email' IS NULL
ORDER BY s.created_at DESC;

-- Step 3: If institutional_email column exists, use this update:
/*
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
*/

-- Step 4: If institutional_email column does NOT exist, we need to extract it from username
-- Most usernames are like "m.gevorgyan" which becomes "m.gevorgyan@acnhs.am"
UPDATE acnhs_students s
SET metadata = COALESCE(s.metadata, '{}'::jsonb) || 
    jsonb_build_object(
        'institutional_email', a.username || '@acnhs.am',
        'personal_email', s.email,
        'portal', jsonb_build_object(
            'institutional_email', a.username || '@acnhs.am',
            'username', a.username,
            'created_at', NOW()
        )
    )
FROM applications a
WHERE s.application_id = a.id
  AND a.username IS NOT NULL
  AND a.username != ''
  AND (s.metadata IS NULL OR s.metadata->>'institutional_email' IS NULL);

-- Step 5: Verify the update
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
