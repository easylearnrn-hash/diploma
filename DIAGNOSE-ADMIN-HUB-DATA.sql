-- Diagnostic script to check why admin-hub.html shows no data

-- 1. Check current RLS policies on students table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'students'
ORDER BY policyname;

-- 2. Check if RLS is enabled on students table
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'students';

-- 3. Check what permissions anon role has
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'students' AND grantee IN ('anon', 'authenticated', 'service_role');

-- 4. Count students (this should work with service_role)
SELECT 
  COUNT(*) as total_students,
  COUNT(*) FILTER (WHERE enrollment_status = 'active') as active_students,
  COUNT(*) FILTER (WHERE enrollment_status = 'inactive') as inactive_students
FROM public.students;

-- 5. Show sample student data (first 3 records)
SELECT id, student_id, full_name, email, enrollment_status, created_at
FROM public.students
ORDER BY created_at DESC
LIMIT 3;

-- 6. Test if anon can actually query (run this in browser console)
-- This is just for reference, copy to browser console:
/*
const { data, error } = await supabase.from('students').select('*').limit(1);
console.log('Data:', data);
console.log('Error:', error);
*/
