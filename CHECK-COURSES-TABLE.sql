-- Check if courses table exists

SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'courses'
) as courses_table_exists;

-- Show all tables that might be related to courses
SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND table_name LIKE '%course%'
ORDER BY table_name;
