-- COMPREHENSIVE DATABASE CHECK FOR NARINE AVETISYAN
-- Run this to understand the actual database structure

-- 1. CHECK WHAT TABLES EXIST
SELECT '=== ALL TABLES ===' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. CHECK APPLICATIONS TABLE FOR NARINE
SELECT '=== NARINE IN APPLICATIONS ===' as info;
SELECT 
    id,
    reference_number,
    applicant_name,
    email,
    status
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- 3. CHECK STUDENTS TABLE STRUCTURE
SELECT '=== STUDENTS TABLE COLUMNS ===' as info;
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'students' AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. TRY TO FIND NARINE IN STUDENTS TABLE (using application id)
SELECT '=== NARINE IN STUDENTS (by application_id) ===' as info;
SELECT s.*
FROM students s
WHERE s.application_id = (
    SELECT id FROM applications WHERE reference_number = 'ACNHS-ADM-20260108-970'
);

-- 5. TRY TO FIND NARINE IN STUDENTS TABLE (by email)
SELECT '=== NARINE IN STUDENTS (by email) ===' as info;
SELECT s.*
FROM students s
WHERE s.email LIKE '%avetisyan%' OR s.email IN (
    SELECT email FROM applications WHERE reference_number = 'ACNHS-ADM-20260108-970'
);

-- 6. CHECK IF TRANSFER_CREDITS TABLE EXISTS
SELECT '=== TRANSFER_CREDITS TABLE EXISTS? ===' as info;
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'transfer_credits'
) as table_exists;

-- 7. IF TRANSFER_CREDITS EXISTS, CHECK ITS FOREIGN KEY
SELECT '=== TRANSFER_CREDITS FOREIGN KEY ===' as info;
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'transfer_credits'
    AND tc.table_schema = 'public';
