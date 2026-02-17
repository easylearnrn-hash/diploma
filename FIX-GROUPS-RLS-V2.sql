-- ============================================
-- FIX RLS POLICIES FOR STUDENT_GROUPS V2
-- Make absolutely sure admin can read the data
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Allow anon read student_groups" ON student_groups;
DROP POLICY IF EXISTS "Allow anon insert student_groups" ON student_groups;
DROP POLICY IF EXISTS "Allow anon update student_groups" ON student_groups;
DROP POLICY IF EXISTS "Allow anon delete student_groups" ON student_groups;
DROP POLICY IF EXISTS "Allow anon full access student_groups" ON student_groups;

-- Create ONE simple policy that allows everything for anon (admin auth is app-level)
CREATE POLICY "anon_full_access_student_groups" 
  ON student_groups 
  FOR ALL
  TO anon 
  USING (true)
  WITH CHECK (true);

-- Verify the policy
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'student_groups';

-- Test: Select from student_groups
SELECT 
  'TEST: Can we read?' as test,
  COUNT(*) as group_count
FROM student_groups;

-- Show actual data
SELECT 
  id,
  name,
  semester,
  created_at
FROM student_groups
ORDER BY created_at DESC;
