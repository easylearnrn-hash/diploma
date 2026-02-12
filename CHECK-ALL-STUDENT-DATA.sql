-- Check all student/application data across tables
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new

-- 1. Check students table
SELECT 'students' as table_name, COUNT(*) as total_records, 
       COUNT(DISTINCT status) as distinct_statuses,
       string_agg(DISTINCT status, ', ') as all_statuses
FROM students;

-- 2. Check applications table (if exists)
SELECT 'applications' as table_name, COUNT(*) as total_records,
       COUNT(DISTINCT status) as distinct_statuses,
       string_agg(DISTINCT status, ', ') as all_statuses
FROM applications
WHERE EXISTS (SELECT FROM pg_tables WHERE tablename = 'applications');

-- 3. Check registrations table (waiting list - if exists)
SELECT 'registrations' as table_name, COUNT(*) as total_records,
       COUNT(DISTINCT status) as distinct_statuses,
       string_agg(DISTINCT status, ', ') as all_statuses
FROM registrations
WHERE EXISTS (SELECT FROM pg_tables WHERE tablename = 'registrations');

-- 4. Show sample data from each table
SELECT 'students' as source, student_id, full_name, email, status, created_at
FROM students
ORDER BY created_at DESC
LIMIT 5;

SELECT 'applications' as source, control_number as id, full_name, email, status, created_at
FROM applications
WHERE EXISTS (SELECT FROM pg_tables WHERE tablename = 'applications')
ORDER BY created_at DESC
LIMIT 5;

SELECT 'registrations' as source, id::text as id, full_name, email, status, created_at
FROM registrations
WHERE EXISTS (SELECT FROM pg_tables WHERE tablename = 'registrations')
ORDER BY created_at DESC
LIMIT 5;
