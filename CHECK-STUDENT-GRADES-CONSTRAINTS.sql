-- Check constraints on student_grades table
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'student_grades'::regclass
AND contype = 'c';
