-- DIAGNOSTIC: Check applications table access and structure
-- Run this in Supabase SQL Editor to diagnose the 500 error

-- 1. Check if table exists and is accessible
SELECT 
  table_name, 
  table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name = 'applications';

-- 2. Check RLS policies on applications table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'applications';

-- 3. Try a simple count query (what admin-home.html is doing)
SELECT COUNT(*) FROM applications;

-- 4. Check if there are any problematic columns that might cause 500 error
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'applications'
ORDER BY ordinal_position;

-- 5. Check for any recent errors in the table
-- Try to select with a limit to see if data is corrupt
SELECT * FROM applications LIMIT 1;

-- SOLUTION QUERIES:

-- If RLS is blocking access, you can temporarily disable it:
-- ALTER TABLE applications DISABLE ROW LEVEL SECURITY;

-- Or add a permissive SELECT policy for anon users:
-- CREATE POLICY "anon_select_applications" ON applications
-- FOR SELECT TO anon, authenticated
-- USING (true);

-- If a specific column is causing issues, check the recent migrations
-- and ensure all columns exist with correct data types
