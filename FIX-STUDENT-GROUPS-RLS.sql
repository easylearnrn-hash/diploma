-- Check RLS policies on student_groups table

-- 1. Check if RLS is enabled
SELECT tablename, rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename = 'student_groups';

-- 2. Check what policies exist
SELECT policyname, permissive, roles, cmd as operation, qual
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename = 'student_groups'
ORDER BY policyname;

-- 3. Check permissions for anon role
SELECT grantee, privilege_type
FROM information_schema.role_table_grants 
WHERE table_name = 'student_groups' 
  AND grantee IN ('anon', 'authenticated', 'service_role');

-- 4. Grant permissions and create permissive policy
GRANT ALL ON public.student_groups TO anon;
GRANT ALL ON public.student_groups TO authenticated;

-- Drop existing restrictive policies if any
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.student_groups;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.student_groups;

-- Create permissive policy for all operations
CREATE POLICY "Allow all operations on student_groups" 
  ON public.student_groups 
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Verify the policy
SELECT policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'student_groups';
