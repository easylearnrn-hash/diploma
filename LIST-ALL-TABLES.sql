-- LIST ALL TABLES IN THE DATABASE
-- Run this first to see what actually exists

SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Count rows in each table
SELECT 
    'applications' as table_name, 
    COUNT(*) as row_count 
FROM applications
UNION ALL
SELECT 
    'students' as table_name, 
    COUNT(*) as row_count 
FROM students
UNION ALL
SELECT 
    'transfer_credits' as table_name, 
    COUNT(*) as row_count 
FROM transfer_credits;
