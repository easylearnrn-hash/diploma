-- CHECK IF GRADES/COURSES DATA EXISTS FOR STUDENTS

-- 1. Check what grade-related tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%grade%' OR table_name LIKE '%course%' OR table_name LIKE '%enrollment%')
ORDER BY table_name;

-- 2. Check if transfer_credits should count toward GPA
SELECT 
    COUNT(*) as total_transfer_credits,
    SUM(credits) as total_credits,
    ROUND(SUM(credits * grade_points) / SUM(credits), 2) as transfer_gpa
FROM transfer_credits
WHERE student_id = 'ACNHS-7022395'
AND status = 'approved';

-- 3. Check for any other academic records
SELECT 
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'public'
AND (column_name LIKE '%gpa%' OR column_name LIKE '%grade%' OR column_name LIKE '%credit%')
ORDER BY table_name, ordinal_position;
