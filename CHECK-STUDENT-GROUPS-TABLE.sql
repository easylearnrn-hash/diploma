-- Check if student_groups table exists and what it contains

-- 1. Check if table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'student_groups'
) as table_exists;

-- 2. If exists, show structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'student_groups'
ORDER BY ordinal_position;

-- 3. Count groups if table exists
SELECT COUNT(*) as total_groups
FROM student_groups;

-- 4. Show sample data if exists
SELECT id, name, semester, student_ids, created_at
FROM student_groups
ORDER BY created_at DESC
LIMIT 5;
