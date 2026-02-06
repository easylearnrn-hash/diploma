-- CHECK STUDENTS TABLE STRUCTURE
-- Run this to see what columns exist in students table

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'students'
ORDER BY ordinal_position;

-- Check if there's data for Narine
SELECT *
FROM students
WHERE id IN (
    SELECT id FROM applications WHERE reference_number = 'ACNHS-ADM-20260108-970'
)
OR email LIKE '%avetisyan%';
