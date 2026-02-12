-- Check if admin-hub related tables exist

-- 1. Check what tables exist in the public schema
SELECT table_name, 
       table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'students',
    'courses', 
    'attendance',
    'grades',
    'student_groups',
    'groups',
    'enrollments',
    'course_enrollments'
  )
ORDER BY table_name;

-- 2. List ALL tables in public schema
SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 3. Check students table columns for grade/group data
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'students'
  AND column_name IN ('current_gpa', 'cumulative_gpa', 'group', 'academic_standing', 'total_credits_earned')
ORDER BY ordinal_position;
