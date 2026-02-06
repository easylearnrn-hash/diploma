-- FINAL PRE-FLIGHT CHECK BEFORE RUNNING ADD-NARINE-TRANSFER-CREDITS.sql
-- Run this first to confirm everything is ready

-- 1. Confirm Narine's student record exists
SELECT 
    '✅ STUDENT FOUND' as status,
    s.student_id as "Student ID (TEXT - this goes in transfer_credits)",
    s.id as "UUID (internal use only)",
    s.full_name,
    s.email,
    a.reference_number
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.reference_number = 'ACNHS-ADM-20260108-970';

-- 2. Confirm transfer_credits table exists and is empty for this student
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ READY - No existing transfer credits'
        ELSE '⚠️  WARNING - ' || COUNT(*)::TEXT || ' transfer credits already exist'
    END as status,
    COUNT(*) as existing_count
FROM transfer_credits tc
WHERE tc.student_id = (
    SELECT s.student_id 
    FROM students s
    JOIN applications a ON s.application_id = a.id
    WHERE a.reference_number = 'ACNHS-ADM-20260108-970'
);

-- 3. Show what student_id value will be used
SELECT 
    '📝 THIS VALUE WILL BE INSERTED' as info,
    s.student_id as "student_id value for transfer_credits table"
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.reference_number = 'ACNHS-ADM-20260108-970';
