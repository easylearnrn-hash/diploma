-- Check applications table structure
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'applications'
AND column_name IN ('student_id', 'control_number', 'date_of_birth', 'id')
ORDER BY ordinal_position;

-- Find Narine's application record
SELECT 
    id,
    control_number,
    full_name,
    date_of_birth,
    email
FROM applications
WHERE control_number = 'ACNHS-ADM-2026011'
   OR email = 'narineavetisyan7788@gmail.com';
